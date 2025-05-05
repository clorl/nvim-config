--- This module loads all the files in plugins/lang
--- gets their spec and convert them to the lazy spec format

local module_path = vim.fs.normalize(vim.fs.joinpath(vim.fn.stdpath("config"), "lua/plugins/lang"))
local spec = {}
local new_spec = {}

for name, type in vim.fs.dir(module_path) do
  if type ~= "file" or not vim.endswith(name, ".lua") then
    goto continue
  end
  local module = "plugins.lang." .. name:sub(1, -5) -- Remove the ".lua" extension
  local ok, res = pcall(require, module)
  if not ok then
    vim.notify("Error requiring module '" .. module .. "': " .. res, vim.log.levels.ERROR)
    goto continue
  end

  table.insert(spec, res)
  ::continue::
end

for _, val in ipairs(spec) do
  local new_val = {}
  for key, val2 in pairs(val) do
    table.insert(new_val, {
      key,
      opts = val2
    })
  end
  table.insert(new_spec, new_val)
end

return new_spec
