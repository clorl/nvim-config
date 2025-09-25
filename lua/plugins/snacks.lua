local map = vim.keymap.set
local pickers = {}
local layouts = {}

pickers.buffers = {
				current = false,
				focus = "list",
				win = {
					input = {
						keys = {
							["<c-x>"] = { "bufdelete", mode = { "n", "i" } },
						}
					},
					list = {
						keys = {
							["<Tab>"] = { "list_down", mode = { "n", "i" } },
							["<S-Tab>"] = { "list_up", mode = { "n", "i" } },
							["<c-x>"] = { "bufdelete", mode = { "n", "i" } },
						},
					},
				}
			}

layouts.select = 
{
	preview = false,
	layout = {
		backdrop = false,
		width = 0.5,
		min_width = 80,
		height = 0.4,
		min_height = 3,
		box = "vertical",
		border = "rounded",
		title = "{title}",
		title_pos = "center",
		{ win = "input", height = 1, border = "bottom" },
		{ win = "list", border = "none" },
		{ win = "preview", title = "{preview}", height = 0.4, border = "top" },
	},
}

require("snacks").setup {
	bigfile = { enabled = true },
	bufdelete = { enabled = true },
	indent = { enabled = true },
	input = { enabled = true },
	notifier = { enabled = true },
	toggle = { enabled = true },
	styles = {
		notification_history = {
			width = 0.95,
			height = 0.95,
			wo = {
				wrap = true
			}
		}
	},
	picker = {
		enabled = true,
		sources = {
			select = {
				layout = layouts.select
			}
		},
		win = {
			input = {
				keys = {
					["<c-p>"] = { "toggle_preview", mode = { "n", "i" } },
				},
			}
		},
		formatters = {
			filename_first = true,
		},
		layout = {
			preset = "sidebar",
			layout = {
				position = "right",
				width = 0.3,
			}
		},
		frecency = true,
		file = {
			filename_first = true,
		}
	}
}

map({"n", "v", "i"}, "<C-x>", function() Snacks.bufdelete() end, { desc = "Delete Buffer"})
map({"n", "v"}, "<leader>n", function() Snacks.notifier.show_history() end, { desc = "Notifications"})
map({"n", "v"}, "<Tab>", function() Snacks.picker.buffers(pickers.buffers) end, { desc = "Pick Buffers"})
map({"n", "v"}, "<leader>f", function() Snacks.picker.smart() end, { desc = "Files"})
map({"n", "v"}, "<leader>g", function() Snacks.picker.grep() end, { desc = "grep"})
map({"n", "v"}, "<leader>sc", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, { desc = "Config"})
map({ "n", "v" }, "<leader>sh", function() Snacks.picker.help({ layout = { preset = "dropdown" }}) end, { desc = "Help" })
map({ "n", "v" }, "<leader>si", function() Snacks.picker.icons() end, { desc = "Icons" })
map({ "n", "v" }, "<leader><space>", function() Snacks.picker.resume() end, { desc = "Last Picker" })
map({ "n", "v" }, "gs", function() Snacks.picker.lsp_symbols() end, { desc = "Document Symbols" })
map({ "n", "v" }, "gS", function() Snacks.picker.lsp_workspace_symbols() end, { desc = "Workspace Symbols" })

-- Notifier
vim.api.nvim_create_autocmd("LspProgress", {
	---@param ev {data: {client_id: integer, params: lsp.ProgressParams}}
	callback = function(ev)
		local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
		vim.notify(vim.lsp.status(), "info", {
			id = "lsp_progress",
			title = "LSP Progress",
			opts = function(notif)
				notif.icon = ev.data.params.value.kind == "end" and " "
				or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
			end,
		})
	end,
})
