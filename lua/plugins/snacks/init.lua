require("plugins.snacks.lsp-progress")

local custom_pickers = {}

return {
  {
    "folke/snacks.nvim",
    lazy = false,
    opts = {
      bigfile = { enabled = true },
      dim = {},
      indent = {
        enabled = true,
        only_current = true
      },
      input = {},
      notifier = {
        timeout = 1000,
        level = vim.log.levels.ERROR,
      },
      quickfile = {},
      statuscolumn = {},
      picker = {
        layout = {
          preset = "sidebar",
          layout = {
            position = "right"
          }
        },
        frecency = true,
        file = {
          filename_first = true,
        }
      },
      styles = {
        notification_history = {
          width = 0.95,
          height = 0.95,
          wo = {
            wrap = true
          }
        }
      }
    },
    keys = {
      { "<leader>n", function() Snacks.notifier.show_history() end, { desc = "Notifications"}},
      { "<leader>ff", function() Snacks.picker.smart() end, { desc = "Find Files" }},
      { "<leader>fg", function() Snacks.picker.grep() end, { desc = "Grep" }},
      { "<leader>fc", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, { desc = "Find Config" }},
      --{ "<leader>fG", function() Snacks.picker.git_files() end, { desc = "Git Files" }},
      -- "<c-p>", function() Snacks.picker.commands({ preview = none }) end, { desc = "Command Palette"} },
      { "<leader>sh", function() Snacks.picker.help() end, { desc = "Find Help"} },
      { "<leader>si", function() Snacks.picker.icons() end, { desc = "Icons"} },
      { "<leader>sj", function() Snacks.picker.jumps() end, { desc = "Jumps"} },
      { "<leader>sp", function() Snacks.picker.lazy() end, { desc = "Plugins"} },
      { "<leader><space>", function() Snacks.picker.resume() end, { desc = "Last Picker"} },
    },
  },
}
