local util = require("util")
local listen_port = 6008
local pipe = util.get_os() == "windows" and "todo" or vim.fs.normalize(vim.fn.stdpath("state") .. "/godot.pipe")

local function on_attach(bufnr)
  if vim.g.lsp.on_attach then
    pcall(vim.g.lsp.on_attach, bufnr)
  end
  if server then
    vim.fn.serverstop(server)
  end
  vim.fn.serverstart(pipe)
end

return {
  lsp = {
    gdscript =  {
      cmd = {},
      root_dir = vim.fs.root(vim.uv.cwd(), "project.godot"),
      single_file_support = true,
      on_attach = on_attach
    },
    gdshader_lsp = {}
  },
  formatters = {
    --gdscript = { "gdtoolkit" }
  },
  dap = {},
  ts = { "gdscript", "gdshader" },
  tools = {}
}
