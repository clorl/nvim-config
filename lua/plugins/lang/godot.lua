local server = nil

vim.api.nvim_create_autocmd({ "BufReadPre", "DirChanged", "VimEnter" }, {
  callback = function(_)
    local root = vim.fs.root(0, { "project.godot" })
    if not root then return end

    if require("util").get_os() == "windows" then
      -- TODO
    else
      local pipe = vim.fs.joinpath(vim.fn.stdpath("state"), "godot.pipe")
      if server then
        vim.fn.serverstop(server)
      end
      server = vim.fn.serverstart(pipe)
      vim.notify("Listening to Godot", vim.log.levels.INFO)
    end
  end
})

return {
	lsp = {
		servers = {
			gdscript = {},
			gdshader_lsp = {},
		},
	},
	mason = {
		ensure_installed = {
			"gdtoolkit"
		},
	},
	conform = {
		formatters_by_ft = {
			gdscript = { "gdformat" },
		},
	},
}
