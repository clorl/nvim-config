vim.api.nvim_create_user_command("LspLog", "e " .. vim.lsp.log.get_filename(), {})

vim.lsp.config["haxe_ls"] = {
  cmd = { 'node', "C:\\Users\\COrlandini\\.config\\nvim\\bin\\haxels\\server.js" },
  filetypes = { 'ts', 'haxe' },
  root_markers = {
    { "common.hxml", "wartales.hxml" },
    ".git"
  },
  settings = {
    haxe = {
      executable = 'C:\\Users\\COrlandini\\Documents\\shiroTools\\haxe\\haxe.exe',
    },
  },
  init_options = {},
  on_new_config = function(new_config, new_root_dir)
    if new_config.init_options.displayArguments then
      return
    end

    local hxml = vim.fs.find(function(name)
      return name:match '.hxml$'
    end, { path = new_root_dir, type = 'file' })[1]
    if hxml then
      vim.notify('Using HXML: ' .. hxml)
      new_config.init_options.displayArguments = { hxml }
    end
  end,
}
vim.lsp.enable("haxe_ls")
