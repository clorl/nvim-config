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
    }
  },
  formatters = {
    lua = { "stylua" }
  },
  mason = {},
  treesitter = {},
  binaries = {}
}
