return {
	"stevearc/conform.nvim",
	opts = {
          default_format_opts = {
			lsp_format = "fallback",
		},
	},
	name = "conform",
	cmd = { "ConformInfo" },
	init = function()
		vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
	end,
	keys = {
		{
			"<leader>=",
			function()
				require("conform").format({ async = true })
			end,
			{ desc = "Code Format" },
		},
	},
}
