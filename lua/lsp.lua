local util = require("util")

local map = vim.keymap.set
local function gh(text)
	return { src = "https://github.com/" .. text }
end

vim.filetype.add({
    extension = {
			hx = "haxe"
    },
})

vim.lsp.enable("luals")
vim.lsp.enable("haxedev")
-- vim.lsp.enable("haxe")
vim.lsp.enable("godot")

-- Mason (for windows only)
if util.get_os() == "windows" then
	vim.pack.add {
		gh("mason-org/mason.nvim"),
		gh("mason-org/mason-lspconfig.nvim"),
		gh("WhoIsSethDaniel/mason-tool-installer"),
	}

	require("mason").setup {}

	require("mason-tool-installer").setup {
		ensure_installed = {
			"stylua",
			"lua_ls",
			"shellcheck",
		},
		auto_update = true,
	}
end

vim.diagnostic.config({
  virtual_text = {
    current_line = true,
  },
	virtual_lines = false,
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "",
			[vim.diagnostic.severity.WARN] = "",
			[vim.diagnostic.severity.INFO] = "󰙎",
			[vim.diagnostic.severity.HINT] = "󰙎",
		}
	},
})

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client:supports_method('textDocument/completion') then
			vim.opt.completeopt = { 'menu', 'menuone', 'noinsert', 'fuzzy', 'popup' }
      -- vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
		end

		if Snacks ~= nil and Snacks.picker ~= nil then
			map("n","gd", function() Snacks.picker.lsp_definitions() end, {  desc = "Goto Definition" })
			map("n","gD", function() Snacks.picker.lsp_declarations() end, {  desc = "Goto Declaration" })
			map("n","gr", function() Snacks.picker.lsp_references() end, {  nowait = true, desc = "References" })
			map("n","gI", function() Snacks.picker.lsp_implementations() end, {  desc = "Goto Implementation" })
			map("n","gy", function() Snacks.picker.lsp_type_definitions() end, {  desc = "Goto T[y]pe Definition" })
			map("n","<leader>ss", function() Snacks.picker.lsp_symbols() end, {  desc = "LSP Symbols" })
			map("n","<leader>sS", function() Snacks.picker.lsp_workspace_symbols() end, {  desc = "LSP Workspace Symbols" })
		else
			map("n", "gd", vim.lsp.buf.definition, { desc = "Goto Definition" })
			map("n", "gr", vim.lsp.buf.references, { desc = "References" })
			map("n", "gI", vim.lsp.buf.implementation, { desc = "Goto Implementation" })
			map("n", "gy", vim.lsp.buf.type_definition, { desc = "Goto Type Definition" })
			map("n", "gD", vim.lsp.buf.declaration, { desc = "Goto Declaration" })
		end
		-- map("n","gc", function() vim.lsp.buf.incoming_calls() end, {  desc = "Incoming Calls" })
		-- map("n","gC", function() vim.lsp.buf.incoming_calls() end, {  desc = "Outgoing Calls" })
		map("n", "K", function() vim.lsp.buf.hover() end, { desc = "Show Documentation" })
		map("n", "gR", function() vim.lsp.buf.rename() end, { desc = "Rename Symbol"})
		map({"n", "v"}, "<leader>a", function() vim.lsp.buf.code_action() end, { desc = "Code Actions" })
		map({"n", "v"}, "gl", function() vim.lsp.codelens.run() end, { desc = "Codelens" })
		map({"n", "v"}, "gL", function() vim.lsp.codelens.refresh() end, { desc = "Refresh Codelens" })

		if client:supports_method('textDocument/formatting') then
			map({"n", "v"}, "<leader>=", function() vim.lsp.buf.format({bufnr = ev, id = client.id, timeout_ms = 1000 }) end, { desc = "Code Format" })
		end

		vim.notify("LSP Client Attached: " .. client.config.name, vim.log.levels.INFO)
	end,
})

