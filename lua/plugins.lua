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

	gh("Saghen/blink.cmp"),
	gh("rafamadriz/friendly-snippets"),
	gh("L3MON4D3/LuaSnip"),

	gh("stevearc/overseer.nvim"),
	gh("nvim-treesitter/nvim-treesitter"),
	gh("jdonaldson/vaxe")
})

-- Essential plugins
-- If anything breaks I'm happy to have them working before anything else

vim.cmd.colorscheme "catppuccin"

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
require("plugins.snacks")

-- Other plugins

require("plugins.treesitter")

local wk = require("which-key")
wk.setup {
	preset = "helix"
}
wk.add {
	{"<leader>s", group = "Search"}
}

require("mini.icons").setup {}

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

-- Completion

require("blink.cmp").setup {
	keymap = { preset = 'default' },

	appearance = {
		nerd_font_variant = 'mono'
	},

	completion = { documentation = { auto_show = false } },

	sources = {
		default = { 'lsp', 'path', 'snippets', 'buffer' },
	},

	fuzzy = { 
		implementation = "prefer_rust",
		prebuilt_binaries = {
			force_version = "latest"
		}
	}
}

-- Snippets

local ls = require("luasnip")
require("luasnip.loaders.from_vscode").lazy_load()


vim.keymap.set({"i"}, "<C-K>", function() ls.expand() end, {silent = true})
vim.keymap.set({"i", "s"}, "<C-L>", function() ls.jump( 1) end, {silent = true})
vim.keymap.set({"i", "s"}, "<C-J>", function() ls.jump(-1) end, {silent = true})

vim.keymap.set({"i", "s"}, "<C-E>", function()
	if ls.choice_active() then
		ls.change_choice(1)
	end
end, {silent = true})

-- Status line
local lualine_full_filename = false
Snacks.toggle
	.new({
		id = "filename",
		name = "Status Line File Path",
		get = lualine_full_filename,
		set = function()
			lualine_full_filename = not lualine_full_filename
		end,
	})
	:map("<leader>of")

require("lualine").setup {
	options = {
		theme = "catppuccin"
	},
	sections = {
		lualine_a = { 'mode' },
    lualine_b = {'branch', 'diagnostics'},
    lualine_c = {
			function()
				if lualine_full_filename then
					return vim.fn.expand("%:p")
				else
					return vim.fn.expand("%:t")
				end
			end
		},
    lualine_x = {'filetype', 'lsp_status'},
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
}
