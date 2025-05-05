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
