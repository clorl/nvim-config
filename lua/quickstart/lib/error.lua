-- Global enum for error codes/names
-- You can use it in reverse like error[-1] which will return the corresponding name
local M = {
	None = 0,
	Generic = -1,
	NotImplemented = -2
}

local reverse = {}
for k,v in ipairs(M) do
	reverse[v] = k
end
M._reverse = reverse

M.__index = function(t,k)
	if k == "_reverse" then
		vim.notify("_reverse key on Error list is not meant to be accessed.", vim.loglevels.ERR)
		return nil
	end
	if type(k) == "number" then
		return rawget(t, "_reverse")[k]
	end
	return rawget(t,k)
end

M.__new_index = function(t,k,v)
	vim.notify("Error list is readonly", vim.loglevels.ERR)
end

return M
