local client = vim.lsp.start({
	name = "haxels_dev",
	cmd = { "hl", "\\Users\\COrlandini\\Documents\\haxels\\build.hl" },
})

if client == nil then
	print("Haxe dev ls not started")
	return
end

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "*.hx", "haxe" },
	callback = function(ev)
		vim.lsp.buf_attach_client(0, client)
	end
})
