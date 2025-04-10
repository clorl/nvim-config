vim.opt.splitkeep = "screen"

vim.api.nvim_create_autocmd("QuickFixCmdPost", {
  callback = function()
    vim.cmd([[Trouble qflist open]])
  end,
})

local function trouble(mode, opts)
  if opts == nil then opts = "" end
  return string.format("<cmd>Trouble %s toggle %s<cr>", mode, opts)
end

return {
  {
    "folke/trouble.nvim",
    opts = {
      focus = true,
      open_no_results = true,
      position = "bottom",
    }, -- for default options, refer to the configuration section for custom setup.
    cmd = "Trouble",
    keys = {
      {
        "<leader>xx",
        trouble("diagnostics"),
        desc = "Diagnostics",
      },
      {
        "<leader>xb",
        trouble("diagnostics", "filter.buf=0"),
        desc = "Buffer Diagnostics",
      },
      {
        "<leader>cs",
        trouble("symbols", "focus=false position=left"),
        desc = "Symbols Window",
      },
      {
        "<leader>cl",
        trouble("lsp", "focus=false position=left"),
        desc = "LSP Window",
      },
      {
        "<leader>xq",
        trouble("qflist"),
        desc = "Quickfix List",
      },
    },
  }
}
