local langs = require("util.languages")

vim.g.lsp = {
  capabilities = vim.lsp.protocol.make_client_capabilities(),
  on_attach = function(bufnr)
    require("config.keys").on_attach(bufnr)
  end
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

local blink = {
  "saghen/blink.cmp",
  version = "*",
  --priority = 100,
  opts = {
    keymap = {
      preset = "super-tab"
    },
    completion = {
      menu = {
        draw = {
          components = {
            kind_icon = {
              text = function(ctx)
                local lspkind = require("lspkind")
                local icon = ctx.kind_icon
                if vim.tbl_contains({ "Path" }, ctx.source_name) then
                  local dev_icon, _ = require("nvim-web-devicons").get_icon(ctx.label)
                  if dev_icon then
                    icon = dev_icon
                  end
                else
                  icon = require("lspkind").symbolic(ctx.kind, {
                    mode = "symbol",
                  })
                end

                return icon .. ctx.icon_gap
              end,

              -- Optionally, use the highlight groups from nvim-web-devicons
              -- You can also add the same function for `kind.highlight` if you want to
              -- keep the highlight groups in sync with the icons.
              highlight = function(ctx)
                local hl = ctx.kind_hl
                if vim.tbl_contains({ "Path" }, ctx.source_name) then
                  local dev_icon, dev_hl = require("nvim-web-devicons").get_icon(ctx.label)
                  if dev_icon then
                    hl = dev_hl
                  end
                end
                return hl
              end,
            }
          }
        }
      }
    }
  },
  enabled = function()
    return not vim.tbl_contains({ "markdown", "text", "log" }, vim.bo.filetype) and vim.bo.buftype ~= "prompt" and
    vim.b.completion ~= false
  end,
  config = function(_, opts)
    local blink = require("blink.cmp")
    blink.setup(opts)
    vim.g.capabilties = vim.tbl_deep_extend("force", vim.g.lsp.capabilities, blink.get_lsp_capabilities())
  end,
  dependencies = {
    {
      "saghen/blink.compat",
      version = "*",
      lazy = true,
      opts = {
        impersonate_nvim_cmp = true
      }
    },
    "onsails/lspkind.nvim",
    { "nvim-tree/nvim-web-devicons", opts = {} }
  }
}

local lspconfig = {
  "neovim/nvim-lspconfig",
  dependencies = {
    blink,
  },
  config = function()
    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(ev)
        vim.g.lsp.on_attach()
      end
    })

    vim.api.nvim_create_autocmd('LspDetach', {
      group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
      callback = function(event2)
        vim.lsp.buf.clear_references()
        vim.diagnostic.hide()
        vim.lsp.codelens.clear()
      end,
    })

    vim.api.nvim_create_autocmd("ModeChanged", {
      pattern = "*:n",
      callback = function()
        local client = vim.lsp.get_active_clients({ bufnr = vim.api.nvim_get_current_buf() })[1]
        if not client then
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
}

return {
  {

    "williamboman/mason.nvim",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "jay-babu/mason-nvim-dap.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      lspconfig
    },
    enabled = function()
      return require("util").get_os() ~= "nixos" -- On NixOS these are installed in another way
    end,
    config = function()
      local lspc = require("lspconfig")
      require("mason").setup()

      local ensure_ls = {}
      for server, _ in pairs(langs.lsp.configs) do
        table.insert(ensure_ls, server)
      end
      require("mason-lspconfig").setup({
        automatic_installation = true,
        ensure_installed = ensure_ls
      })
      require("mason-nvim-dap").setup({
        automatic_installation = true,
        ensure_installed = langs.ensure_installed.dap
      })
      require("mason-tool-installer").setup({
        ensure_installed = langs.ensure_installed.tools
      })

      require("mason-lspconfig").setup_handlers({
        function(server_name)
          if not vim.tbl_contains(vim.tbl_keys(langs.lsp.configs), server_name) then
            --else
            lspc[server_name].setup({
              capabilities = vim.g.lsp.capabilities
            })
          end
        end
      })


      for server_name, config in pairs(langs.lsp.configs) do
        if config.capabilities then
          config.capabilities = vim.tbl_deep_extend("force", vim.g.lsp.capabilities, config.capabilities)
        else
          config.capabilities = vim.g.lsp.capabilities
        end
        lspc[server_name].setup(config)
      end
    end
  },
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      mason
    },
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
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      { "<leader>cf", function() require("conform").format({ bufnr = vim.api.nvim_get_current_buf(), async = true, lsp_format =
        "fallback" }) end, { desc = "Format" } }
    },
    opts = {
      format_on_save = false,
      formatters_by_ft = langs.formatters,
      formatters = {
        haxe_formatter = require("languages.haxe").custom_formatters.haxe_formatter
      }
    },
    config = function(opts)
      if not opts.formatters_by_ft then
        opts.formatters_by_ft = {}
      end
      opts.formatters_by_ft.haxe = { "haxe_formatter" }
      require("conform").setup(opts)
    end
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
      ensure_installed = langs.ensure_installed.ts,
      auto_install = true,
      highlight = {
        enable = true
      },
    },
    config = function(opts)
      require("nvim-treesitter.configs").setup(opts)
      local parsers = require("nvim-treesitter.parsers")
      local parser_config = require "nvim-treesitter.parsers".get_parser_configs()
      vim.treesitter.language.register("typescript", "haxe")
    end
  }
}
