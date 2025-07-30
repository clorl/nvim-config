return {
  'stevearc/overseer.nvim',
  lazy = false,
  opts = {
    strategy = "jobstart",
    component_aliases = {
      default = {
        "on_exit_set_status",
        "on_output_quickfix",
        { "display_duration", detail_level = 1 },
        { "on_complete_notify" },
      }
    }
  },
  keys = {
    { "<S-F5>", "<cmd>OverseerToggle right<cr>" },
    { "<F5>", "<cmd>OverseerRun<cr>" },
    { "<C-F5>", "<cmd>OverseerQuickAction<cr>" },
    { "<leader>cr", "<cmd>OverseerRun<cr>", { desc = "Run Code" }},
    { "<leader>cn", "<cmd>OverseerBuild<cr>", { desc = "New run task" }},
    { "<leader>cA", "<cmd>OverseerTaskAction<cr>", { desc = "Action on run task" }},
    { "<leader>ce", "<cmd>OverseerTaskAction<cr>", { desc = "Edit run task" }},
  }
}
