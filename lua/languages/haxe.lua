
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
  pattern = {"*.hx", "*.hxml"},
  callback = function()
    vim.bo.filetype = "haxe"
  end,
})

return {
  lsp = {
    haxe_language_server = {
      cmd = { "node", vim.fs.normalize("~/bin/server.js") },
      root_dir = vim.fs.root(0, {  "common.hxml", "wartales.hxml" })
    }
  },
  formatters = {
  },
  dap = {},
  ts = { "typescript" },
  tools = {},
  custom_formatters = {
    haxe_formatter = {
      command = "haxelib",
      args = { "run", "formatter", "--stdin", "--source", vim.fn.expand("%") }, -- Use current file as source for config detection
      stdin = function(buf)
        return vim.api.nvim_buf_get_lines(buf, 0, -1, true)
      end,
      cwd = function(buf)
        -- Find the project root, or use the current directory.
        local project_root = vim.loop.cwd() -- Default to current dir
        local current_file = vim.api.nvim_buf_get_name(buf)
        if current_file ~= "" then
          local root_markers = { "common.hxml", "haxelib.json", "build.hxml", ".git" } -- Adjust markers if needed
          local found_root = vim.fs.find(root_markers, { upward = true, path = vim.fn.expand(current_file) })
          if found_root and #found_root > 0 then
            project_root = vim.fs.dirname(found_root[1])
          end
        end
        return project_root
      end,
      try_node_modules = false,
      check_exit_code = function(exit_code)
        return exit_code == 0
      end,
      stdout = function(stdout)
        return vim.split(stdout, "\n", { trimempty = true })
      end,
    }
  }
}
