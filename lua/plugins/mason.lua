return {
  "williamboman/mason.nvim",
  name = "mason",
  dependencies = {
    "williamboman/mason-lspconfig.nvim",
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    "jay-babu/mason-nvim-dap.nvim"
  },
  opts = {
    ensure_installed = {}
  },
  config = function(_, opts)
    local lspconfig = require("lspconfig")
    local mason = require("mason")

    mason.setup()

    -- if opts.ensure_installed == nil then
    --   opts.ensure_installed = {}
    -- end

    vim.print(opts)

    require("mason-tool-installer").setup({ensure_installed = opts.ensure_installed})
    require("mason-lspconfig").setup {
      ensure_installed = {},
      automatic_installation = true,
      handlers = {
        function(server_name)
          lspconfig[server_name].setup {
            capabilities = vim.g.lsp.capabilities
          }
        end
      }
    }
  end
}
