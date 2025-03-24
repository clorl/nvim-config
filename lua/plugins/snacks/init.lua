require("plugins.snacks.lsp-progress")

return {
  {
    "folke/snacks.nvim",
    priority = 1000,
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
        level = vim.log.levels.ERROR
      },
      quickfile = {},
      statuscolumn = {},
      picker = {
        preset = "ivy",
        layout = {
          position = "bottom"
        }
      },
      {
        formatters = {
          file = {
            filename_first = true
          }
        }
      }
    },
    keys = {
      { "<leader>gb", function() Snacks.git.blame_line {} end, { desc = "Git Blame" }},
      { "<leader>ff", function() Snacks.picker.smart() end, { desc = "Find Files" }},
      { "<leader>fg", function() Snacks.picker.grep() end, { desc = "Grep" }},
      { "<leader>fc", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, { desc = "Find Config" }},
      { "<leader>fG", function() Snacks.picker.git_files() end, { desc = "Find Config" }},
      { "<c-p>", function() Snacks.picker.commands() end, { desc = "Command Palette"} },
      { "<leader>sh", function() Snacks.picker.help() end, { desc = "Find Help"} },
      { "<leader>sx", function() Snacks.picker.diagnostics() end, { desc = "Diagnostics"} },
      { "<leader>sX", function() Snacks.picker.diagnostics_buffer() end, { desc = "Diagnostics Buffer"} },
      { "<leader>si", function() Snacks.picker.icons() end, { desc = "Icons"} },
      { "<leader>sj", function() Snacks.picker.jumps() end, { desc = "Jumps"} },
      { "<leader>sp", function() Snacks.picker.lazy() end, { desc = "Plugins"} },
      { "<leader>sq", function() Snacks.picker.lazy() end, { desc = "Quickfix List"} },
      { "<leader><space>", function() Snacks.picker.resume() end, { desc = "Last Picker"} },
      { "gd", function() Snacks.picker.lsp_definitions() end, desc = "Goto Definition" },
      { "gD", function() Snacks.picker.lsp_declarations() end, desc = "Goto Declaration" },
      { "gr", function() Snacks.picker.lsp_references() end, nowait = true, desc = "References" },
      { "gI", function() Snacks.picker.lsp_implementations() end, desc = "Goto Implementation" },
      { "gy", function() Snacks.picker.lsp_type_definitions() end, desc = "Goto T[y]pe Definition" },
      { "<leader>ss", function() Snacks.picker.lsp_symbols() end, desc = "LSP Symbols" },
      { "<leader>sS", function() Snacks.picker.lsp_workspace_symbols() end, desc = "LSP Workspace Symbols" },
    }
  },
}
