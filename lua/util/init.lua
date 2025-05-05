local M = {}

-- TODO: be able to choose what error types we want globally and on a per-function basis
-- either exceptions with error or error-as-values return values
-- with set_error_mode(function, "exception")

local cached_os_name = ""

function _get_os()
  if vim.fn.has("win32") == 1 then
    return "windows"
  end
  if vim.fn.has("mac") == 1 then
    return "mac"
  end
  if vim.fn.has("linux") ~= 1 then
    return "unknown"
  end

  local distro = ""
  local f = io.open("/etc/os-release", "r")
  if not f then
    vim.notify("Cannot open os-release", vim.log.levels.ERROR)
    return ""
  end
  for line in f:lines() do
    if line:match("^NAME=") then
      distro = line:match("^NAME=(.*)")
      distro = distro:gsub('"', '')
      distro = distro:lower()
      break
    end
  end
  f:close()

  if distro == nil or distro == "" then
    return "linux"
  end

  return distro
end

function M.get_os()
  if cached_os_name then
    return cached_os_name
  end
  local os = _get_os()
  cached_os_name = os
  return os
end

-- List of lua types mapped to their default values
local lua_types = {
  ["nil"] = nil,
  ["boolean"] = false,
  ["number"] = 0,
  ["string"] = "",
  ["table"] = {},
  ["function"] = nil,
  ["userdata"] = nil,
  ["thread"] = nil,
  ["any"] = nil,
}

-- Checks if value is of default value for its type
-- eg for boolean it's false, number it's 0, string it's "" and table it's {}
-- if strict is true, whitespace in empty strings isn't considered default
function M.is_default(value, strict)
  if value == nil then
    return true
  end
  local t = type(value)

  -- No default values for those
  if t == "function" or t == "userdata" or t == "thread" or t == "any" then
    return false
  end

  local is_default = {
    ["boolean"] = function(v) return not v end,
    ["number"] = function(v) return v == 0 end,
    ["string"] = function(v) return strict and v == "" or v:gsub("%s+", "") == "" end,
    ["table"] = function(v) return #v == 0 end
  }
  local success, result = pcall(is_default[t], value)
  return success and result or false
end

-- Checks if value is non-nil, of type t and non-default
-- t can be any lua type name, "any" or a union of types like "boolean|number"
-- If allow_default is true, will return true on default values
-- (empty string, table, zero etc)
-- optionally can have a func that validates the value
-- func takes value as an arg and returns a boolean
-- if value does not pass type check then func isn't called
function M.is_valid(value, t, allow_default, func)
  if value == nil then
    return false
  end
  if t == nil or type(t) ~= "string" or M.is_default(t) then
    error(string.format("Invalid argument 2 for is_valid, expected string that is a name of a lua-type, got %s with value %s", type(t), vim.inspect(t)))
    return false
  end

  -- Check type
  local result = type(value) == t
  if not result then return result end

  -- Check is default value
  -- If func wasn't provided stop here
  if allow_default then
    return true
  end
  if M.is_default(value) then
    return false
  end
  if func == nil then return result end

  if type(func) ~= "function" then
    error(string.format("Invalid argument 4 for is_valid, expected a function, got %s with value %s", type(func), vim.inspect(func)))
    return result
  end

  local success, func_result = pcall(func, value)
  if not success then
    error(string.format("Tried to call func parameter is is_valid call but it errored: %s", result))
    return result
  end
  if func_result ~= nil and type(func_result) ~= "boolean" then
    error(string.format("Invalid argument 4 for is_valid, it is a function but it doesn't return a boolean which it should. Got %s with value: %s", type(result), vim.inspect(result)))
    return result
  end
  return func_result
end


function M.make_globals()
  --- Creates a default plugin spec for language plugins
  _G.Lang = function (spec)
    if spec == nil then
      spec = {}
    end

    local new_spec = {}

    for key, val in pairs(spec) do
      table.insert(new_spec, {
        key,
        opts = val
      })
    end

    return new_spec
  end
end

return M
