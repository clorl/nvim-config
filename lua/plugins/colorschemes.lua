local colorschemes = {
  {
    "catppuccin/nvim",
    name = "catppuccin",
  },
"kvrohit/rasmus.nvim",
"zenbones-theme/zenbones.nvim",
"andreasvc/vim-256noir",
"Alligator/accent.vim",
"huyvohcmc/atlas.vim",
"chriskempson/base16",
"davidosomething/vim-colors-meh",
"andreypopp/vim-colors-plain",
"fxn/vim-monochrome",
"widatama/vim-phoenix",
"axvr/photon.vim",
 { 
   "neko-night/nvim",
   name = "neko-night"
 },
"sainnhe/edge",
"rose-pine/neovim",
"navarasu/onedark.nvim",
"scottmckendry/cyberdream.nvim",
"Mofiqul/dracula.nvim",
"olimorris/onedarkpro.nvim",
"bluz71/vim-moonfly-colors",
"aliqyan-21/darkvoid.nvim",
"wuelnerdotexe/vim-enfocado"
}

--
--
--

local default_spec = {
  priority = 52,
  lazy = true,
}

local final_spec = {}
for _, colorscheme in pairs(colorschemes) do
  if type(colorscheme) == "string" then
    local name = "z_colorscheme-"..colorscheme
                  :gsub("[^/]*/", "")
                  :gsub("[%-_%.]?n?vim[%-_%.]?","")
    local copy = vim.deepcopy(default_spec)
    copy[1] = colorscheme
    copy.name = name
    table.insert(final_spec, copy)
  else
    local copy = vim.deepcopy(vim.tbl_deep_extend("force", default_spec, colorscheme))
    if not copy.name then
    copy.name = copy[1]
                  :gsub("[^/]*/", "")
                  :gsub("[%-_%.]?n?vim[%-_%.]?","")
    end
    copy.name = "z_colorscheme-" .. copy.name
    table.insert(final_spec, copy)
  end
end

return final_spec
