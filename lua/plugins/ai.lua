return {
  "Exafunction/codeium.nvim",
  cmd = "Codeium",
  event = "InsertEnter",
  build = ":Codeium Auth",
  enabled = function()
    return require("util").get_os() ~= "nixos" or vim.fn.executable("codeium") == 1
  end,
  dependencies = {
        "nvim-lua/plenary.nvim",
  },
  opts = {
    enable_cmp_source = true,
    virtual_text = {
      enabled = true,
      key_bindings = {
        accept = "<C-enter>", -- handled by nvim-cmp / blink.cmp
        next = "<M-]>",
        prev = "<M-[>",
      },
    },
  },
}
