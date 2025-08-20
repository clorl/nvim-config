  return {
    "stevearc/oil.nvim",
    lazy = false,
    keys = {
      { "<bs>", "<cmd>Oil<cr>" },
      { "<leader>fe", "<cmd>Oil<cr>", { desc = "File Explorer"}},
    },
    opts = {
      show_hidden = true,
      keymaps = {
        ["<bs>"] = "actions.parent",
        ["<s-h>"] = "actions.toggle_hidden",
        ["<s-bs>"] = "actions.open_cwd",
        ["<s-enter>"] = "actions.cd",
        ["<c-p>"] = ""
      }
    },
  }
