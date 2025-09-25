return {
	cmd = { "node", vim.fs.normalize(vim.fn.stdpath("config") .. "/lsp/haxe_server.js") },
	filetypes = { "haxe", "hx" },
	root_markers = { "common.hxml", "wartales.hxml" }
}
