return {
    "folke/edgy.nvim",
    event = "VeryLazy",
    opts = {
      animate = {
        enabled = false
      },
      right = {
        {
          ft = "OverseerList",
          title = "Run Configs"
        }
      },
      left = {
        {
          ft = "trouble",
          title = "Trouble: Document Symbols"
        },
        {
          ft = "trouble",
          title = "Trouble: LSP"
        }
      },
      bottom = {
        { title = "Trouble: Diagnostics", ft = "trouble", size = { height = 0.2 } }, -- Optional: Let edgy try to manage it
        { ft = "qf", title = "Trouble: Quickfix", size = { height = 0.2 }}, -- Optional: Let edgy manage qf directly
      },
      exit_when_last = true,
    },
  }
