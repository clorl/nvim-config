local success, ftspec = pcall(require, "config.filetypes")

if not success or not ftspec or type(ftspec) ~= "table" then
  return
end

local default_filetype_callback = function(filetype)
  vim.bo.filetype = filetype
end

local function make_filetype_callback(filetype, callback)
  if callback and type(callback) == "function" then
    return function()
      default_filetype_callback(filetype)
      _, _ = pcall(callback, opts)
    end
  else
    return function()
      default_filetype_callback(filetype)
    end
  end
end

for key, ft in pairs(ftspec) do
  if not ft.pattern then
    goto continue
  end

  vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
    pattern = ft.pattern,
    callback = make_filetype_callback(key, ft.callback),
  })
  ::continue::
end
