return {
  lsp = {
    servers = {
      jsonls = {
        settings = {
          json = {
            format = {
              enable = true,
            },
            validate = {
              enable = true,
            },
          },
        },
      },
    },
  },

  treesitter = {
    ensure_installed = {
    "json"
    }
  }
}
