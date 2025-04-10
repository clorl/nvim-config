require("util.languages").setup("languages")

require("config.options")
require("config.lazy")
require("config.keys")
require("config.autocmds")
require("config.filetypes")

vim.cmd("colorscheme default")
