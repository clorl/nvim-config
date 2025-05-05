vim.g.lsp = {
  capabilities = vim.lsp.protocol.make_client_capabilities(),
  on_attach = function(bufnr)
    require("config.keys").on_attach(bufnr)
  end,
}

vim.diagnostic.config {
  severity_sort = true,
  float = { border = 'rounded', source = 'if_many' },
  underline = { severity = vim.diagnostic.severity.ERROR },
  signs = vim.g.have_nerd_font and {
    text = {
      [vim.diagnostic.severity.ERROR] = '󰅚 ',
      [vim.diagnostic.severity.WARN] = '󰀪 ',
      [vim.diagnostic.severity.INFO] = '󰋽 ',
      [vim.diagnostic.severity.HINT] = '󰌶 ',
    },
  } or {},
  virtual_text = {
    source = 'if_many',
    spacing = 2,
    format = function(diagnostic)
      local diagnostic_message = {
        [vim.diagnostic.severity.ERROR] = diagnostic.message,
        [vim.diagnostic.severity.WARN] = diagnostic.message,
        [vim.diagnostic.severity.INFO] = diagnostic.message,
        [vim.diagnostic.severity.HINT] = diagnostic.message,
      }
      return diagnostic_message[diagnostic.severity]
    end,
  },
}

return {
  {
    "neovim/nvim-lspconfig",
    name = "lsp",
    dependencies = {
      "mason",
      "blink"
    },
    opts = {
      servers = {}
    },
    config = function(_, opts)
      local lspconfig = require("lspconfig")
      local default_config = {
        capabilities = vim.tbl_deep_extend("force", vim.lsp.protocol.make_client_capabilities(), vim.g.lsp.capabilities)
      }

      if opts.servers then
        for name, config in pairs(opts.servers) do
          local new_config = vim.tbl_deep_extend("force", default_config, config)
          lspconfig[name].setup(new_config)
        end
      end

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(_)
          vim.g.lsp.on_attach()
        end
      })

      vim.api.nvim_create_autocmd('LspDetach', {
        callback = function(_)
          vim.lsp.buf.clear_references()
          vim.diagnostic.hide()
          vim.lsp.codelens.clear()
        end,
      })

      vim.api.nvim_create_autocmd("ModeChanged", {
        pattern = "*:n",
        callback = function()
          local client = vim.lsp.get_clients({ bufnr = vim.api.nvim_get_current_buf() })[1]
          if not client or #client <= 0 then
            return
          end
          if client.supports_method("textDocument/codeLens") then
            vim.lsp.codelens.refresh()
          end
          if client.supports_method("textDocument/diagnostic") then
            vim.schedule(function()
              vim.diagnostic.reset()
              vim.diagnostic.get()
            end)
          end
        end
      })
    end
  },
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      }
    }
  },
}
