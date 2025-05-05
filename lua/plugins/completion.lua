return {
  "saghen/blink.cmp",
  name = "blink",
  version = "*",
  priority = 51,
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
