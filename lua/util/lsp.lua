local M = {}

local capabilities_updated_callbacks = {}
M.capabilities = vim.lsp.protocol.make_client_capabilities()

function M.add_capabilities(new_capabilities, mode)
  if mode == nil or mode == "" then
    mode = "force"
  end
  M.capabilities = vim.tbl_deep_extend(mode, M.capabilities, new_capabilities)

  for i, f in ipairs(capabilities_updated_callbacks) do
    pcall(capabilities_updated_callbacks, M.capabilities)
  end
end

function M.listen_capabilities_updated(callback)
  table.insert(capabilities_updated_callbacks, callback)
end

return M
