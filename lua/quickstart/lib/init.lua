local M = {}

-- Proper error handling TODO
M.error = require("quickstart.lib.error")

local validate_default_opts = {}

-- Validates element e against the schema using vim.validate, except the value parameter is the default
-- e is usually a table, but maybe later I'll add support for other stuff
-- schema follows vim.validate table argument
-- opts is TODO
function M.validate(e, schema, opts)
  if opts == nil or type(opts) ~= "table" then
    opts = { parent_key = "" }
  end

  -- Ensure e is a table
  if type(e) ~= "table" then
    return -1  -- Not implemented yet
  end

  -- Ensure schema is a table
  if type(schema) ~= "table" then
    return -1  -- Invalid schema
  end

  local schema_copy = vim.deepcopy(schema)
  local not_in_schema = {}  -- In case we need it later

  for k, v in pairs(e) do
    if schema_copy[k] == nil or type(schema_copy[k]) ~= "table" then
      not_in_schema[k] = v
      goto continue
    end

    schema_copy[k][1] = v

    ::continue::
  end

  local res, err = pcall(vim.validate, schema_copy)
  if err then return -1
  else return 0
  end
end

return M
