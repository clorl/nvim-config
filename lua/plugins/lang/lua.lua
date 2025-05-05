return {
	lsp = {
		servers = {
			lua_ls = {
				settings = {
					Lua = {
						workspace = {
							checkThirdParty = false,
						},
						codeLens = {
							enable = true,
						},
						completion = {
							callSnippet = "Replace",
						},
						doc = {
							privateName = { "^_" },
						},
						hint = {
							enable = true,
							setType = false,
							paramType = true,
							paramName = "Disable",
							semicolon = "Disable",
							arrayIndex = "Disable",
						},
					},
				},
			},
		},
	},
	mason = {
		ensure_installed = {
			"stylua",
		},
	},
	conform = {
		formatters_by_ft = {
			lua = { "stylua" },
		},
	},
	treesitter = {
		ensure_installed = {
			"lua",
		},
	},
}
