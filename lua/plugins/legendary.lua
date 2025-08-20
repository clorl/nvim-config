return {
  'mrjones2014/legendary.nvim',
  enabled = false,
  version = 'v2.13.9',
  priority = 53,
  lazy = false,
  opts = {
    keymaps = {},
    funcs = {},
    commands = {},
    autocmds = {},
    extensions = {
      lazy_nvim = true,
    },
    select_prompt = ' Command Palette ',
  },
  keys = {
    {"<C-p>", "<cmd>Legendary<cr>", { desc = "Command Palette" }}
  }
  -- sqlite is only needed if you want to use frecency sorting
  -- dependencies = { 'kkharji/sqlite.lua' }
}
