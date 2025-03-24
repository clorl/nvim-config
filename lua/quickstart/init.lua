local fallback_specs = require("quickstart.plugins")

local reserved_keys = {
  "enable",
  "__generated"
}

local lazy_keys = {
}

local function get_spec(plugin_name)
	local path = "%s/lua/quickstart/plugins/%s.lua"
	path = string.format(path, vim.fn.stdpath("config"), plugin_name)
	if vim.fn.filereadable(path) == 0 then
		return 0 -- It's a "success" because we have a fallback (it's expected)
	end

	local success, res = pcall(require, module_name)
	if not success then
		vim.notify(string.format("Error while loading spec for %s: %s", plugin_name, err), vim.log.levels.ERROR)
		return -1
	elseif not res or type(res) ~= "table" then
		vim.notify(string.format("Spec for %s doesn't return a table, returned value: %s", plugin_name, vim.inspect(res)), vim.log.levels.ERROR)
		return -1
	end
	return res
end

local function init()
	-- Bootstrap lazy.nvim
	local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
	if not (vim.uv or vim.loop).fs_stat(lazypath) then
		local lazyrepo = "https://github.com/folke/lazy.nvim.git"
		local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
		if vim.v.shell_error ~= 0 then
			vim.api.nvim_echo({
				{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
				{ out, "WarningMsg" },
				{ "\nPress any key to exit..." },
			}, true, {})
			vim.fn.getchar()
			os.exit(1)
		end
	end
	vim.opt.rtp:prepend(lazypath)

	local spec = {}

	for k,v in pairs(Qs) do
		if Qs.enable ~= nil and not Qs.enable then
			goto continue
		end
		if k == "lazy" then
			goto continue
		end
		local plugin_spec = get_spec(k)
		if type(plugin_spec) == "number" and plugin_spec == 0 then
			plugin_spec = fallback_specs[k]
			if plugin_spec == nil and not v[url] then
				vim.notify(string.format("Unknown plugin %s", k), vim.log.levels.WARN)
				goto continue
			end
		end
		if type(plugin_spec) ~= "table" then
			vim.notify(string.format("Plugin spec for %s is of type %s instead of table. Here is the value:", k, type(plugin_spec), vim.inspect(plugin_spec)), vim.log.levels.WARN)
			goto continue
		end

		local user_spec = to_lazy_spec(v)
		plugin_spec = to_lazy_spec(plugin_spec)
		plugin_spec.opts = user_spec
		local final_spec = vim.tbl_deep_extend("force", plugin_spec, user_spec)
		table.insert(spec, final_spec)

		::continue::
	end

	local lazy_config = {}
	if Qs.lazy then
		lazy_config = Qs.lazy
	end
	lazy_config.spec = spec

	require("lazy").setup(lazy_config)
end

if not _G.Qs then
  vim.notify("You haven't setup your quickstart config before requiring the plugin", vim.log.levels.ERROR)
else
  return init()
end
