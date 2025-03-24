
local function on_cloned(source, target)
	local readme_path = source .. "/README.md"
	local srcfile = io.open(readme_path, "r")
	if not srcfile then
		print("README.md not found.")
		return
	end

	local file, err = io.open(target, "w")
	if not file then
		print(err)
		return
	end

	file:write("return {\n")
	for line in srcfile:lines() do
		local user, repo = line:match("github.com/([^/]*)/([^/%)#]*)[%)#]")
		if not user or not repo then
			goto continue
		end
		local name
		if repo:match("^n?vim$") then
			name = user
				:gsub("[%-.]", "_")
		else
			name = repo
				:gsub("[%-.]?n?vim[%-.]?", "")
				:gsub("[%-.]", "_")

		end

		file:write(string.format(
[[  %s = {
    "%s",
    opts = {}
  },
]], 
		name, user .. "/" .. repo))
		::continue::
	end
	file:write("}\n")
	file:close()
	srcfile:close()

	print("Lua file with plugin names created.")
end

_G.Build = function()
	local git = "git"
	local repo_dir = vim.fn.stdpath("data") .. "/quickstart/awnvim"
	local lua_file = vim.fn.stdpath("config") .. "/lua/quickstart/plugins.lua"

	if vim.uv.fs_stat(lua_file) then
		local res, err = os.remove(lua_file)
		if err then
			print(err)
		end
	end

	if not (vim.uv or vim.loop).fs_stat(repo_dir) then
		local repo = "https://github.com/rockerBOO/awesome-neovim"
		local out = vim.fn.system({ "git", "clone", "--filter=blob:none", repo, repo_dir })
		if vim.v.shell_error ~= 0 then
			vim.api.nvim_echo({
				{ "Failed to clone:\n", "ErrorMsg" },
				{ out, "WarningMsg" },
				{ "\nPress any key to exit..." },
			}, true, {})
			vim.fn.getchar()
			return
		end
	end

	on_cloned(repo_dir, lua_file)
end
