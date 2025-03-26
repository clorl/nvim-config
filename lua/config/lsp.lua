return {
  servers = {
    default = {},
    lua_ls = {
      settings = {
        Lua = {
          runtime = { version = "LuaJIT" },
          workspace = {
            checkThirdParty = false,
            library = {
              '${3rd}/luv/library',
              unpack(vim.api.nvim_get_runtime_file('', true))
            }
          },
          completion = {
            callSnippet = "Replace"
          }
        }
      },
    },
    haxe_language_server = {
      cmd = {"node", vim.fs.normalize("~/bin/server.js") },
      root_dir = function() return vim.fn.getcwd() end,
      name = "haxe",
      filetypes = { "haxe", "hx", ".hx", "hxml", ".hxml" }
    }
  },
  formatters = {
    lua = { "stylua" }
  },
  mason = {},
  treesitter = {},
  binaries = {}
}
