local M = {}

M.ensure_installed = {
	ts = {},
	tools = {},
	dap = {}
}

M.lsp = {
	formatters = {},
	configs = {}
}

local function validate_language_spec(spec)
	if not spec or type(spec) ~= "table" then
		return false, nil
	end
	local success, err = pcall(vim.validate, {
		ts = { spec.ts, "table", true },
		formatters = { spec.formatters, "t", true },
		dap = {spec.dap, "t", true },
		tools = { spec.tools, "t", true },
		lsp = { spec.lsp, "t", true },
	})

	if not success then
		return false, err
	end

	return true, nil
end

local function _setup(modname)
	-- Load all language files and merge their specs
	local language_dir = vim.fs.normalize(vim.fn.stdpath("config") .. "/lua/" .. modname .. "/")
	for _, file in ipairs(vim.fn.readdir(language_dir)) do
		if file:match("%.lua$") then
			local lang_module = require(modname .. "." .. file:gsub("%.lua$", ""))
			if not lang_module then goto continue end
			local valid, errors = validate_language_spec(lang_module)
			if not valid then
				--vim.notify("Error in " .. modname .. "." .. file:gsub("%.lua$", "") .. ": " .. table.concat(errors, ", "), vim.log.levels.ERROR)
				goto continue
			end
			for k, v in pairs(lang_module) do
				if v ~= nil then
					if k == "ts" and #v > 0 then
						M.ensure_installed.ts = vim.list_extend(M.ensure_installed.ts, v)
					elseif k == "formatters" then
						for ft, formatter in pairs(v) do
							M.lsp.formatters[ft] = formatter
							table.insert(M.ensure_installed.tools, formatter)
						end
					elseif k == "dap" and #v > 0 then
						M.ensure_installed.dap = vim.tbl_deep_extend("force", M.ensure_installed.dap, v)
					elseif k == "tools" and #v > 0 then
						M.ensure_installed.tools = vim.tbl_deep_extend("force", M.ensure_installed.tools, v)
					elseif k == "lsp" then
						M.lsp.configs = vim.tbl_deep_extend("force", M.lsp.configs, v)
					end
				end
			end
			::continue::
		end
	end
end

function M.setup(modname)
	local success, res = pcall(_setup, modname)
	if not success then
		vim.notify("Error while loading languages " .. res, vim.log.levels.ERROR)
		return false, res
	else
		return true, nil
	end
end

return M
