return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    priority = 52,
    opts_extend = { "spec" },
    opts = {
      preset = "helix",
      defaults = {},
      spec = {
        {
          mode = { "n", "v" },
          { "<leader>c", group = "code" },
          { "<leader>d", group = "debug" },
          { "<leader>f", group = "file/find" },
          { "<leader>g", group = "git" },
          { "<leader>q", group = "quit/session" },
          { "<leader>r", group = "run code" },
          { "<leader>s", group = "search" },
          { "<leader>u", group = "ui", icon = { icon = "󰙵 ", color = "cyan" } },
          { "<leader>x", group = "diagnostics/quickfix", icon = { icon = "󱖫 ", color = "green" } },
          { "[", group = "prev" },
          { "]", group = "next" },
          { "g", group = "goto" },
          { "gs", group = "surround" },
          { "z", group = "fold" },
          -- better descriptions
          { "gx", desc = "Open with system app" },
          { "<leader>cf", desc = "Format code" },

          -- Snacks descriptions
          { "<leader>n", desc = "Show Notifications"},
          { "<leader>ff", desc = "Find Files" },
          { "<leader>fg", desc = "Grep" },
          { "<leader>fc", desc = "Files in Config" },
          { "<c-p>", desc = "Command Palette (wip)" },
          { "<leader>cr", desc = "Run Code" },
          { "<leader>cn", desc = "New run task" },
          { "<leader>cA", desc = "Action on run task" },
          { "<leader>ce", desc = "Edit run task" },
          { "<leader>sh", desc = "Find Help" },
          { "<leader>si", desc = "Icons" },
          { "<leader>sj", desc = "Jumps" },
          { "<leader>sp", desc = "Plugins" },
          { "<leader><space>", desc = "Last Picker" },
        },
      },
    },
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer Keymaps (which-key)",
      },
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
      if not vim.tbl_isempty(opts.defaults) then
        wk.register(opts.defaults)
      end
    end,
  }
