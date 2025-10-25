local map = vim.keymap.set

local os = require("overseer")
os.setup {
	component_aliases = {
		default = {
			"on_exit_set_status",
			{ "on_complete_dispose", timeout = 300},
	   -- { "open_output", direction = "dock", on_start = "always"},
		}
	}
}

map({ "n", "v" }, "<F5>", "<cmd>OverseerRun<cr>", { desc = "Run"})
map({ "n", "v" }, "<S-F5>", "<cmd>OverseerQuickAction<cr>", { desc = "Run Quick Action"})
map({ "n", "v" }, "<C-F5>", "<cmd>OverseerToggle<cr>", { desc = "Toggle Run Panel"})

vim.api.nvim_create_user_command("Make", function(params)
  local task = require("overseer").new_task({
    cmd = vim.fn.expandcmd(params.args),
    components = {
      {
				"on_output_quickfix",
				open_height = 10,
				open = not params.bang,
				tail = true,
			},
			{ "on_complete_dispose" },
      "default",
    },
  })
  task:start()
end, {
  desc = "Compile",
  nargs = "*",
	bang= true,
	complete = "shellcmdline"
})

vim.keymap.set({"n","v"}, "<C-p>", function()
	local keys = vim.api.nvim_replace_termcodes(":Make <Up>", true, false, true)
	vim.api.nvim_feedkeys(keys, "n", true)
end, { desc = "Compile"})
