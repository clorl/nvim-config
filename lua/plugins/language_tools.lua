local lsp_utils = require("util.lsp")

vim.diagnostic.config({
  virtual_text = true
})

local blink = {
  "saghen/blink.cmp",
  version = "*",
  --priority = 100,
  opts = {
  },
  config = function()
    local blink = require("blink.cmp")
    blink.setup({
      keymap = { preset = "super-tab" }
    })
    lsp_utils.add_capabilities(blink.get_lsp_capabilities())
  end,
  dependencies = {
    "saghen/blink.compat",
    version = "*",
    lazy = true,
    opts = {
      impersonate_nvim_cmp = true
    }
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
        require("config.keys").lsp()
      end
    })

    local config = require("config.lsp")
    local lspc = require("lspconfig")
    local capabilities = lsp_utils.capabilities

    -- This sets up servers I have explicitely declared in config.lsp.servers
    for server_name, server_config in pairs(config.servers) do
      if server_name ~= "default" then
        local capabilities = lsp_utils.capabilities
        if server_config.capabilities and type(server_config.capabilities) == "table" then
          capabilities = vim.tbl_deep_extend("force", capabilities, server_config.capabilities)
        end
        server_config.capabilities = capabilities

        if config.default then
          server_config = vim.tbl_deep_extend("force", config.default, server_config)
        end
        lspc[server_name].setup(server_config)
      end
    end
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
      return require("util").get_os() ~= "nixos"  -- On NixOS these are installed in another way
    end,
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = {}
      })
      require("mason-nvim-dap").setup({
        ensure_installed = {}
      })
      require("mason-tool-installer").setup({
        ensure_installed = {}
      })
      local lsp_configs = require("config.lsp").servers

      -- This sets up servers installed through Mason
      require("mason-lspconfig").setup_handlers({
        function (server_name)
          if lsp_configs[server_name] then
            return
          end
          require("lspconfig")[server_name].setup(lsp_configs.default and lsp_configs.default or {})
        end
      })
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
      { "<leader>cf", function() require("conform").format { async = true, lsp_format = "fallback" } end, { desc = "Format"}}
    },
    opts = {
      format_on_save = false,
      formatters_by_ft = require("config.lsp").formatters
    },
    config = function(opts)
      require("conform").setup(opts)
      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    end
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    main = "nvim-treesitter.configs",
    opts = {
      ensure_installed = {},
      -- TODO: ensure installed
      auto_install = true,
      highlight = {
        enable = true
      }
    }
  },
  {
    "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
    enabled = false,
    config = function()
      --require("lsp_lines").setup()
    end
  }
}
