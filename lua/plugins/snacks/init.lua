require("plugins.snacks.lsp-progress")

local layout_select = 
    {
      preview = false,
      layout = {
        backdrop = false,
        width = 0.5,
        min_width = 80,
        height = 0.4,
        min_height = 3,
        box = "vertical",
        border = "rounded",
        title = "{title}",
        title_pos = "center",
        { win = "input", height = 1, border = "bottom" },
        { win = "list", border = "none" },
        { win = "preview", title = "{preview}", height = 0.4, border = "top" },
      },
    }

return {
  {
    "folke/snacks.nvim",
    lazy = false,
    opts = {
      bigfile = { enabled = true },
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
        sources = {
          select = {
            layout = layout_select
          }
        },
        win = {
          input = {
            keys = {
              ["<c-p>"] = { "toggle_preview", mode = { "n", "i" } },
            },
          }
        },
        formatters = {
          filename_first = true,
        },
        layout = {
          preset = "sidebar",
          layout = {
            position = "right",
            width = 0.3,
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
      { "<Tab>", function() Snacks.picker.buffers({
        current = false,
        focus = "list",
        win = {
          list = {
            keys = {
              ["<Tab>"] = { "list_down", mode = { "n", "i" } },
              ["<S-Tab>"] = { "list_up", mode = { "n", "i" } },
            },
          },
        }})
      end
      },
      { "<leader>p", function() Snacks.picker.commands({
          layout = layout_select
      }) end},
      { "<leader>n", function() Snacks.notifier.show_history() end, { desc = "Notifications"}},
      { "<leader>ff", function() Snacks.picker.smart() end, { desc = "Find Files" }},
      { "<leader>e", function() Snacks.picker.explorer({
        layout = { preset = "sidebar", preview = false },
      }) end, { desc = "File Explorer" }},
      { "<leader>fg", function() Snacks.picker.grep() end, { desc = "Grep" }},
      { "<leader>fF", function() Snacks.picker.grep_buffers() end, { desc = "Grep in Buffers" }},
      { "<leader>fc", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, { desc = "Find in Config" }},
      --{ "<leader>fG", function() Snacks.picker.git_files() end, { desc = "Git Files" }},
      -- "<c-p>", function() Snacks.picker.commands({ preview = none }) end, { desc = "Command Palette"} },
      { "<leader>fh", function() Snacks.picker.help({
        layout = { preset = "dropdown" }
      }) end, { desc = "Find in Help"} },
      { "<leader>fi", function() Snacks.picker.icons() end, { desc = "Find Icons"} },
      --{ "<leader>fj", function() Snacks.picker.jumps() end, { desc = "Find Jumps"} },
      { "<leader>fp", function() Snacks.picker.lazy() end, { desc = "Find Plugins"} },
      { "<leader>fs", function() Snacks.picker.lsp_symbols() end, { desc = "Find Document Symbols"} },
      { "<leader>fS", function() Snacks.picker.lsp_workspace_symbols() end, { desc = "Find Workspace Symbols"} },
      { "<leader><space>", function() Snacks.picker.resume() end, { desc = "Last Picker"} },
      { "<leader>/", function() Snacks.picker.lines() end, { desc = "Find Lines"} },
      { "<leader>:", function() Snacks.picker.search_history() end, { desc = "Find Search History"} },
    },
  },
}
