--- @class SvnPlugin
--- @field api SvnApi API to interact with SVN cli
--- @field pickers { [string]: fun(opts: table): snacks.Picker)} Definitions for pickers used by Snacks nvim
local M = {}

--- @param success_cb fun(bufnr: int, content: table) Called when the user saves (:w) the buffer
--- @param abort_cb fun(bufnr: int) Called when the user deletes (:bd) the buffer
--- @param initial_content? table Content of the temp buffer when opened
local function buf_user_input(success_cb, abort_cb, initial_content)

	initial_content = initial_content or {}
	local bufnr = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_set_current_buf(bufnr)


  vim.bo[bufnr].buftype = ''
  vim.bo[bufnr].buflisted = false
  vim.bo[bufnr].bufhidden = 'wipe'
  vim.bo[bufnr].swapfile = false
  vim.bo[bufnr].modifiable = true
  vim.bo[bufnr].filetype = "COMMIT_MESSAGE"

	local grp = vim.api.nvim_create_augroup("TmpBuffer_" .. bufnr, { clear = true })
	vim.api.nvim_buf_set_name(bufnr, "COMMIT_EDITMSG")
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, initial_content)

  vim.api.nvim_create_autocmd("BufWriteCmd", {
		group = grp,
    buffer = bufnr,
    callback = function ()
			success_cb(bufnr, vim.api.nvim_buf_get_lines(bufnr, 0, -1, false))
			if vim.api.nvim_buf_is_valid(bufnr) then
				vim.api.nvim_buf_delete(bufnr, { force = true })
			end
			vim.api.nvim_del_augroup_by_id(grp)
		end,
		once = true
  })

  -- The BufDelete handles the "Cancel" action (e.g., :bd, :q)
  vim.api.nvim_create_autocmd("BufWinLeave", {
		group = grp,
    buffer = bufnr,
    callback = function()
			vim.bo[bufnr].modified = false
			abort_cb(bufnr)
			vim.api.nvim_del_augroup_by_id(grp)
		end,
		once = true
  })

	vim.cmd("startinsert")
end

--- @param cmd string The parameters to give to the svn command
--- @return boolean success
--- @return table|string # The result of the command invocation as a table or the error message as a string or table
local function svn(cmd)
	local res = vim.fn.systemlist("svn " .. cmd)
	local errmsg = {}
	for i in ipairs(res) do
		local found = res[i]:match("svn:%s+(.*)\r")
		if found ~= nil then
			table.insert(errmsg, found)
		end
	end

	if #errmsg > 0 then
		return false, table.concat(errmsg, "\n")
	end
	return true, res
end

--- @class SvnApi List of functions to interact with svn cli
M.api = {}

--- @class FileStatus
--- @field path string File path relative to cwd (normalized)
--- @field status string One character describing the status of the file per as SVN conventions
--- @field cl string|nil Name of the changelist this file is assigned to, nil if no cl

--- @param opts? table For later
--- @return FileStatus[]?
function M.api.status(opts)
	local success, res = svn("status")
	if not success then
		vim.notify(res, vim.log.levels.ERROR)
		return
	end

	local statuses = "[ ADMRCXI!~%?]"
	local cl_pattern = "---%sChangelist%s'([^']+)':\r"

	local res_list = {}
	local cl = nil

---@diagnostic disable-next-line: param-type-mismatch
	for i in ipairs(res) do
		local clmatch = res[i]:match(cl_pattern)
		if clmatch ~= nil then
			cl = clmatch
		end

		local status = res[i]:match(statuses)
		local path = res[i]:match(statuses .. "%s*(.*)\r")
		if status ~= nil and path ~= nil then
			local npath = vim.fs.normalize(path)
			local obj = {
				["path"] = npath,
				["status"] = status,
				["cl"] = cl,
			}
			table.insert(res_list, obj)
		end
	end

	return res_list
end

--- @param files string[] list of filepaths to add
--- @param opts? table Options for later
--- @return boolean success
function M.api.add(files, opts)
	local args = table.concat(files, " ")
	local success, res = svn("add " .. args)
	if not success then
		vim.notify(res, vim.log.levels.ERROR)
		return false
	end

	return true
end

--- @param files string[]List of files to commit
--- @param message string Commit message.
--- @param opts? table Options for later
function M.api.commit(files, message, opts)
	local args = table.concat(files, " ")
	local success, res = svn("commit " .. args .. " -m " .. '"' .. message .. '"')
	if not success then
		vim.notify(res, vim.log.levels.ERROR)
		return false
	end
	return true
end

M.pickers = {}

--- @return boolean # True if dependencies for using pickers are setup, otherwise prints an error
local function pickers_check_dependencies()
	if Snacks == nil then
		vim.notify("snacks.nvim must be installed and initialized before using the pickers module", vim.log.levels.ERROR)
		return false
	end
	if Snacks.picker == nil then
		vim.notify("snacks.nvim picker module must be enabled", vim.log.levels.ERROR)
		return false
	end
	return true
end

local statuses = "[ ADMRCXI!~%?]"
local status_score = {
	[" "] = 0,
	["~"] = 1,
	["I"] = 2,
	["X"] = 3,
	["R"] = 4,
	["C"] = 5,
	["D"] = 6,
	["A"] = 7,
	["?"] = 8,
	["M"] = 9
}

--- @class SvnPicker Definition for a Snacks picker that displays Svn Files
local SvnPicker = {}

--- @param opts table Config for the picker with added keys specific to the SvnPicker
--- 	cl? string: nil to filter files that have no cl, "*" to have all files no matter the cl, and a string to choose one specific cl
--- @return SvnPicker?
function SvnPicker.new(opts)
	if not pickers_check_dependencies() then
		return nil
	end

	local files = M.api.status({})
	if files == nil then
		return
	end

	local default_opts = {}

	local picker_opts = {}
	if opts == nil then
		picker_opts = default_opts
	else
		picker_opts = vim.tbl_deep_extend("force", default_opts, opts)
	end

	-- Build Picker
	local picker = {
		title = "SVN Base Picker",
		opts = picker_opts,
	}

	table.sort(files, function(a,b)
		local sa = status_score[a.status] or -1
		local sb = status_score[b.status] or -1
		return sa > sb
	end)

	picker.items = {}
	for i, file in ipairs(files) do
		local cl_check = true
		if picker_opts.cl == nil then
			cl_check = file.cl == picker_opts.cl
		end
		if picker_opts.cl ~= nil and picker_opts.cl ~= "*" then
			cl_check = file.cl == picker_opts.cl
		end

		if cl_check and file.status ~= " " then
			table.insert(picker.items, {
				idx = i,
				score = i,
				text = file.path,
				name = file.path,
				status = file.status,
				file = file.path
			})
		end
	end

	picker.format = function(item)
		return {
			{item.status},
			{" - "},
			{item.name, "SnacksPickerLabel"},
		}
	end

	picker.confirm = function(picker, item)
		picker:close()
	end

	return picker
end

--- @param opts table|nil Options to pass to the picker, with added custom options for this particular one
function M.pickers.commit(opts)
	--- @class SvnPicker
	local base = SvnPicker.new(opts)
	if base == nil then
		return
	end

	base.confirm = function(picker, item)
		picker:close()
		local all_items = picker:selected()
		if all_items == nil or #all_items <= 0 then
			all_items = { item }
		end

		local initial_message = {
			"",
			"--This line, and those below, will be ignored--",
			"The following files will be marked for addition and committed:",
		}

		local add_args = {}
		for i, item in ipairs(all_items) do
			if item.status == "?" then
				table.insert(add_args, item.file)
				table.insert(initial_message, "    " .. item.file)
			end
		end

		local commit_args = {}
		table.insert(initial_message, "")
		table.insert(initial_message, "The following files will be committed:")
		for i, item in ipairs(all_items) do
			if item.status ~= "?" then
				table.insert(initial_message, "    " .. item.status .. " " .. item.file)
			end
			table.insert(commit_args, item.file)
		end

		buf_user_input(
			function(bufnr, contents)
				local full_message = ""
				local msg_ended = false
				local end_idx = -1
				for i, line in ipairs(contents) do
					if not msg_ended then
						if line:sub(1,2) == "--" then
							msg_ended = true
						else
							full_message = full_message .. line
						end
					end
				end
				if M.api.add(add_args) then
					if M.api.commit(commit_args, full_message) then
						vim.notify("Success commit", vim.log.levels.INFO)
					else
						vim.notify("Committing files to SVN repo failed", vim.log.levels.ERROR)
					end
				else
					vim.notify("Adding files to SVN repo failed", vim.log.levels.ERROR)
				end
			end,
			function(bufnr)
				vim.notify("Commit aborted", vim.log.levels.WARN)
			end,
			initial_message)
	end

	return Snacks.picker.pick(base)
end

return M
