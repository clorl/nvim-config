local M = {}
local map = vim.keymap.set
local util = require("util")

map({"n", "v"}, "<M-d>", [["_d]], { desc = "Delete without saving to register" })
map({ "n", "v" }, "<M-c>", [["_c]], { desc = "Replace without saving to register" })
map("n", "x", [["_x]], { desc = "Delete char without saving to register" })
map("n", "Q", "<nop>", { silent = true })

-- Because windows terminal is shit
if util.get_os() == "windows" then
  map("n", "<M-v>", "<cmd>norm <C-v><cr>", { silent = true })
end

-- better up/down
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
map({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })

-- Move to window using the <ctrl> hjkl keys
map("n", "<C-h>", "<C-w>h", { desc = "Go to Left Window", remap = true })
map("n", "<C-j>", "<C-w>j", { desc = "Go to Lower Window", remap = true })
map("n", "<C-k>", "<C-w>k", { desc = "Go to Upper Window", remap = true })
map("n", "<C-l>", "<C-w>l", { desc = "Go to Right Window", remap = true })

-- Resize window using <ctrl> arrow keys
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })

-- Move Lines
map("n", "<leader>j", "j", { desc = "Join lines" })
map("n", "J", "<cmd>execute 'move .+' . v:count1<cr>==", { desc = "Move Down" })
map("n", "K", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "Move Up" })
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move Down" })
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move Up" })
map("v", "J", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = "Move Down" })
map("v", "J", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = "Move Up" })

-- buffers
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next Buffer" })

-- Clear search and stop snippet on escape
map({ "i", "n", "s" }, "<esc>", function()
  vim.cmd("noh")
  return "<esc>"
end, { expr = true, desc = "Escape and Clear hlsearch" })

--keywordprg
--map("n", "<leader>K", "<cmd>norm! K<cr>", { desc = "Keywordprg" })

-- better indenting
map("v", "<", "<gv")
map("v", ">", ">gv")
map("n", "<", "<<")
map("n", ">", ">>")

-- lazy
map("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy" })

-- location list
map("n", "<leader>xl", function()
  local success, err = pcall(vim.fn.getloclist(0, { winid = 0 }).winid ~= 0 and vim.cmd.lclose or vim.cmd.lopen)
  if not success and err then
    vim.notify(err, vim.log.levels.ERROR)
  end
end, { desc = "Location List" })

-- quickfix list
map("n", "<leader>xX", function()
  local success, err = pcall(vim.fn.getqflist({ winid = 0 }).winid ~= 0 and vim.cmd.cclose or vim.cmd.copen)
  if not success and err then
    vim.notify(err, vim.log.levels.ERROR)
  end
end, { desc = "Quickfix List" })

map("n", "[q", vim.cmd.cprev, { desc = "Previous Quickfix" })
map("n", "]q", vim.cmd.cnext, { desc = "Next Quickfix" })

-- diagnostic
local diagnostic_goto = function(next, severity)
  local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
  severity = severity and vim.diagnostic.severity[severity] or nil
  return function()
    go({ severity = severity })
  end
end
map("n", "<leader>xl", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
map("n", "]d", diagnostic_goto(true), { desc = "Next Diagnostic" })
map("n", "[d", diagnostic_goto(false), { desc = "Prev Diagnostic" })
map("n", "]e", diagnostic_goto(true, "ERROR"), { desc = "Next Error" })
map("n", "[e", diagnostic_goto(false, "ERROR"), { desc = "Prev Error" })
map("n", "]w", diagnostic_goto(true, "WARN"), { desc = "Next Warning" })
map("n", "[w", diagnostic_goto(false, "WARN"), { desc = "Prev Warning" })

-- stylua: ignore start

-- Terminal Mappings
map("t", "<esc>", "<c-x><c-\\>", { desc = "which_key_ignore" })

function M.on_attach(bufnr)
  if Snacks and Snacks.picker then
    map("n","gd", function() Snacks.picker.lsp_definitions() end, {  desc = "Goto Definition" })
    map("n","gD", function() Snacks.picker.lsp_declarations() end, {  desc = "Goto Declaration" })
    map("n","gr", function() Snacks.picker.lsp_references() end, {  nowait = true, desc = "References" })
    map("n","gI", function() Snacks.picker.lsp_implementations() end, {  desc = "Goto Implementation" })
    map("n","gy", function() Snacks.picker.lsp_type_definitions() end, {  desc = "Goto T[y]pe Definition" })
    map("n","<leader>ss", function() Snacks.picker.lsp_symbols() end, {  desc = "LSP Symbols" })
    map("n","<leader>sS", function() Snacks.picker.lsp_workspace_symbols() end, {  desc = "LSP Workspace Symbols" })
  else
    map("n", "gd", vim.lsp.buf.definition, { desc = "Goto Definition" })
    map("n", "gr", vim.lsp.buf.references, { desc = "References" })
    map("n", "gI", vim.lsp.buf.implementation, { desc = "Goto Implementation" })
    map("n", "gy", vim.lsp.buf.type_definition, { desc = "Goto Type Definition" })
    map("n", "gD", vim.lsp.buf.declaration, { desc = "Goto Declaration" })
  end
    map("n","gc", function() vim.lsp.buf.incoming_calls() end, {  desc = "Incoming Calls" })
    map("n","gC", function() vim.lsp.buf.incoming_calls() end, {  desc = "Outgoing Calls" })
    map("n", "K", function() vim.lsp.buf.hover() end, { desc = "Show Documentation" })
    map({"n", "v"}, "<leader>ca", function() vim.lsp.buf.code_action() end, { desc = "Code Actions" })
    map("n", "<leader>cR", function() vim.lsp.buf.rename() end, { desc = "Rename Symbol"})
    map("i", "<M-Space>", function() vim.lsp.buf.completion({}) end, { desc = "Request Completion"})
    map({"n", "v"}, "<leader>cc", function() vim.lsp.codelens.run() end, { desc = "Codelens" })
    map({"n", "v"}, "<leader>cC", function() vim.lsp.codelens.refresh() end, { desc = "Refresh Codelens" })
end

return M
