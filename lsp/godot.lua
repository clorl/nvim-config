local function augroup(name)
  return vim.api.nvim_create_augroup("user_" .. name, { clear = true })
end

vim.api.nvim_create_autocmd("FileType", {
  group = augroup("godot"),
  pattern = { "gd", "gdscript", "godot" },
  callback = function(event)
		vim.bo.smartindent = false
		vim.bo.autoindent = true
		vim.wo.list = true
  end,
})

local port = os.getenv 'GDScript_Port' or '6005'
local cmd = vim.lsp.rpc.connect('127.0.0.1', tonumber(port))

if vim.fn.filereadable(vim.fn.getcwd() .. '/project.godot') == 1 then
  local addr = '/tmp/godot.pipe'
  if vim.fn.has 'win32' == 1 then
    addr = '127.0.0.1:6004'
  end
  vim.fn.serverstart(addr)
end

return {
  cmd = cmd,
  filetypes = { 'gd', 'gdscript', 'gdscript3' },
  root_markers = { 'project.godot', '.git' },
}
