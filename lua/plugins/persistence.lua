return {
  "folke/persistence.nvim",
  event = "BufReadPre",
  opts = {
    need = 2
  },
  keys = {
    {"<leader>qS", function() require("persistence").select() end, { desc = "Select Session to load"}},
    {"<leader>qs", function() require("persistence").load() end, { desc = "Load session"}},
    {"<leader>qd", function() require("persistence").stop() end, { desc = "Do not save session"}},
    {"<leader>q", function() vim.cmd("waq") end, { desc = "Save and quit"}}
  }
}
