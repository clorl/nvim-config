return {
  'stevearc/overseer.nvim',
  opts = {
    template_dirs = { "plugins.overseer" },
    component_aliases = {
      default = {
      { "display_duration", detail_level = 2 },
      {
        "on_output_quickfix", 
        close = true,
        open = true,
        open_on_exit = "failure",
        set_diagnostics = true,
        tail = true
      },
      {
        "on_result_diagnostics",
        remove_on_restart = true,
      },
      {
        "on_result_diagnostics_quickfix",
        set_empty_results = true
      },
      "on_output_summarize",
      "on_exit_set_status",
      "on_complete_notify",
      --{ "on_complete_dispose", require_view = { "SUCCESS", "FAILURE" } },
      }
    }
  },
  keys = {
    { "<f5>", "<cmd>OverseerToggle<cr>" },
    { "<f4>", "<cmd>OverseerQuickAction<cr>" },
    { "<leader>rr", "<cmd>OverseerRun<cr>", { desc = "Run" }},
    { "<leader>rR", "<cmd>OverseerRunCmd<cr>", { desc = "Run shell command" }},
    { "<leader>rn", "<cmd>OverseerBuild<cr>", { desc = "Create task" }},
    { "<leader>ra", "<cmd>OverseerTaskAction<cr>", { desc = "Action on task" }},
  }
}
