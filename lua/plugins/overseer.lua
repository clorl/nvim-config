return {
  'stevearc/overseer.nvim',
  lazy = false,
  opts = {
    default_detail = 1,
    component_aliases = {
      default = {
        "on_exit_set_status",
        { "open_output", direction = "dock", on_start = "always"},
        "on_result_diagnostics"
      }
    },
    task_list = {
      separator = ""
    }
  },
  keys = {
    { "<F5>", "<cmd>OverseerRun<cr>", desc = "Run code"},
    { "<S-F5>", "<cmd>OverseerQuickAction<cr>",  desc = "Action on run task" },
    { "<leader>r", "<cmd>OverseerQuickAction<cr>",  desc = "Toggle Overseer Menu" },
  
}
}

-- exrc template
-- require("overseer").register_template({
--   name = "My project task",
--   params = {},
--   condition = {
--     -- This makes the template only available in the current directory
--     -- In case you :cd out later
--     dir = vim.fn.getcwd(),
--   },
--   builder = function()
--     return {
--       cmd = {"echo"},
--       args = {"Hello", "world"},
--     }
--   end,
-- })
