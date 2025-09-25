local function gh(text)
	return { src = "https://github.com/" .. text }
end

local map = vim.keymap.set

vim.pack.add({
	gh("catppuccin/nvim"),
	gh("nvim-mini/mini.nvim"),
	gh("nvim-lualine/lualine.nvim"),
	gh("stevearc/oil.nvim"),
	gh("folke/which-key.nvim"),
	gh("folke/trouble.nvim"),
	gh("folke/snacks.nvim"),

	gh("stevearc/overseer.nvim"),
	gh("nvim-treesitter/nvim-treesitter"),
	gh("jdonaldson/vaxe")
})

require("plugins.snacks")
require("plugins.treesitter")

local wk = require("which-key")
wk.setup {
	preset = "helix"
}
wk.add {
	--{"<leader>o", group = "Options"},
	{"<leader>s", group = "Search"}
}

vim.cmd.colorscheme "catppuccin"
require("mini.icons").setup {}

require("lualine").setup {}

require("oil").setup {
	show_hidden = true,
	keymaps = {
		["<bs>"] = "actions.parent",
		["<s-h>"] = "actions.toggle_hidden",
		["<s-bs>"] = "actions.open_cwd",
		["<s-enter>"] = "actions.cd",
		["<c-p>"] = ""
	}
}
map("n", "<bs>", "<cmd>Oil<cr>", { desc = "File Explorer" })

require("trouble").setup {}
map({ "n", "v" }, "<leader>x", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Diagnostics"})
map({ "n", "v" }, "<leader>X", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", { desc = "Diagnostics (Buffer)"})
map({ "n", "v" }, "<leader>c", "<cmd>Trouble qflist toggle<cr>", { desc = "Quickfix List"})

local os = require("overseer")
os.setup {
	component_aliases = {
		default = {
        { "open_output", direction = "dock", on_start = "always"},
		}
	}
}

map({ "n", "v" }, "<F5>", "<cmd>OverseerRun<cr>", { desc = "Run"})
map({ "n", "v" }, "<S-F5>", "<cmd>OverseerQuickAction<cr>", { desc = "Run Quick Action"})
map({ "n", "v" }, "<C-F5>", "<cmd>OverseerToggle<cr>", { desc = "Toggle Run Panel"})
