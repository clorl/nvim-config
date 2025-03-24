local M = {}

-- Apply given default_spec on a list of specs
-- Mode corresponds to vim.tbl_deep_expand mods
function M.apply_default_spec(specs, default_spec, mode)
  if specs == nil or type(specs) ~= table or #specs == 0 then
    return -1
  end

  if mode == nil or type(mode) ~= "string" or mode == "" then
  end

  -- If only one spec wrap it in a table
  if type(specs[1]) == "string" then
   specs = { specs }
  end

  for i,spec in ipairs(specs) do
  end
end


return M
