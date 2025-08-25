return {
  "folke/persistence.nvim",
  event = "BufReadPre",
  opts = {
    need = 2
  },
  keys = {
    {"<leader>qs", function() require("persistence").select() end,  desc = "Select Session to load"},
    {"<leader>qr", function() require("persistence").load() end, desc = "Restore session"},
    {"<leader>qd", function() require("persistence").stop() end, { desc = "Do not save session"}},
    {"<leader>qq", function() vim.cmd("waq") end, { desc = "Save and quit"}}
  }
}
