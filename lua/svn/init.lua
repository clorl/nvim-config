--- TODO:
--- - Update
--- 	- Handle conflicts
--- - Update after commit
--- - Blame
--- - Log history
--- - Update to revision


---
--- SVN PLUGIN MODULE
---

local M = {}

--- Internal function that prompts the user for input in a temporary buffer
--- @param success_cb fun(bufnr: integer, content: table) Called when the user saves (:w) the buffer
--- @param abort_cb fun(bufnr: integer) Called when the user deletes (:bd) the buffer
--- @param initial_content? table Content of the temp buffer when opened
--- @private
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


---
--- SVN PLUGIN API
---

--- @param cmd string The parameters to give to the svn command
--- @return boolean success
--- @return table|string # The result of the command invocation as a table or the error message as a string or table
--- @private
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

-- Structured output of svn status
--- @class svn.api.FileStatus {path: string, status: string, cl?: string}
--- @field path string File path
--- @field status string Single character representing the file statuts (see SVN docs)
--- @field cl? string Name of the changelist the file is in, if found

-- Takes a list of lines outputted by svn for files status and outputs structured data
--- @param lines string[]
--- @return svn.api.FileStatus[]
local function parse_status(lines)
	local statuses = "([ ADMRCXI!~%?])"
	local file_pattern = "%s*" .. statuses .. "%s(.*)\r"
	local cl_header = "---%sChangelist%s'([^']+)':\r"
	local cur_cl = nil

	local result = {}

	for _, line in ipairs(lines) do
		local status, file = line:match(file_pattern)
		if status ~= nil and file ~= nil then
			table.insert(result, {
				path = file,
				status = status,
				cl = cur_cl
			})
		else
			local cl_match = line:match(cl_header)
			if cl_match ~= nil then
				cur_cl = cl_match
			end
		end
	end

	return result
end

-- Structured output of svn revision
--- @class svn.api.Revision {path: string, status: string, cl?: string}
--- @field rev string
--- @field user string
--- @field date string
--- @field time string
--- @field timezone string
--- @field datetime_localized string

--- @param line string Svn revision summary
--- @return svn.api.Revision?
local function parse_revision(line)
	local pattern = table.concat({
		"(r%d*)", -- Rev number
		"%s|%s",
		"([^|]*)", -- User name,
		"%s|%s",
		"([%d%-]*)%s", -- Date
		"([%d:]*)%s", -- Time
		"(%+%d*)%s", -- Timezone,
		"(%(.*%))", -- Localized datetime
		"%s|%s",
		".*" -- Ignore the rest
	}, "")

	local m = {line:match(pattern)}
	if m ~= nil and #m >= 6 then
		return {
			rev = m[1],
			user = m[2],
			date = m[3],
			time = m[4],
			timezone = m[5],
			datetime_localized = m[6]
		}
	end

	return nil
end

M.api = {}

--- @param opts? table For now does nothing
--- @return svn.api.StatusResult[]?
---@diagnostic disable-next-line: unused-local
function M.api.status(opts)
	local success, res = svn("status")
	if not success then
		vim.notify(res, vim.log.levels.ERROR)
		return
	end

	return parse_status(res)
end

--- @param files string[] list of filepaths to add
--- @param opts? table Unused for now
--- @return boolean success
---@diagnostic disable-next-line: unused-local
function M.api.add(files, opts)
	local args = table.concat(files, " ")
	local success, res = svn("add " .. args)
	if not success then
		vim.notify(res, vim.log.levels.ERROR)
		return false
	end

	return true
end

--- @param files string[] List of files to commit
--- @param message string Commit message.
--- @param opts? table Unused for now
--- @return boolean success
---@diagnostic disable-next-line: unused-local
function M.api.commit(files, message, opts)
	local args = table.concat(files, " ")
	local success, res = svn("commit " .. args .. " -m " .. '"' .. message .. '"')
	if not success then
		vim.notify(res, vim.log.levels.ERROR)
		return false
	end
	return true
end

--- @param path? string What path for the log command, either a directory or a file
--- @param opts? {limit?: integer}
--- @return any? result
function M.api.log(path, opts)
	opts = opts or {}

	local args = {}
	if path ~= nil then
		table.insert(args, path)
	end

	if opts.limit ~= nil then
		table.insert(args, "-l")
		table.insert(args, "" .. opts.limit)
	end

	local success, res = svn("log -v " .. table.concat(args, " "))
	if not success then
		vim.notify(res, vim.log.levels.ERROR)
		return nil
	end

	local idx = 1
	local output = {}
	while idx < #res do
		local header = res[idx+1]
		local changed_files_start = res[idx+3]

		-- Look for newline
		local changed_files = {}
		local j = idx + 3
		local chg_file_line = res[j]
		while chg_file_line ~= "\r" do
			table.insert(changed_files, chg_file_line)
			j = j + 1
			chg_file_line = res[j]
		end

		-- Look for delimiter
		local k = j + 1
		local mess = {}
		local mess_line = res[k]
		while string.gsub(mess_line, "%-*", "") ~= "\r" do
			table.insert(mess, mess_line)
			k = k + 1
			mess_line = res[k]
		end

		table.insert(output, {
			header = parse_revision(header),
			changed_files = parse_status(changed_files),
			message = mess
		})

		-- Assign delimiter index
		idx = k
	end

	log(output)

end


---
--- PICKERS DEFINITION ---
---

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

M.picker = {}

--- @class snacks.Picker see [snacks.picker](https://github.com/folke/snacks.nvim/blob/main/docs/picker.md)
--- @class snacks.picker.Config see [snacks.picker](https://github.com/folke/snacks.nvim/blob/main/docs/picker.md)

--- @class svn.picker.SvnPicker : snacks.Picker Picker that displays svn status output
M.picker.SvnPicker = {}

--- @class svn.picker.Config : snacks.picker.Config Extended configuration for SVN Picker
--- @field cl? string|nil|'*': A changelist to filter files. If nil, will show files that have no cl, if '*' will display all files no matter the cl. If string, will select files of that specific cl

--- @return SvnPicker?
function M.picker.SvnPicker.new(opts)
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

	picker.confirm = function(p, _)
		p:close()
	end

	return picker
end

--- Calls Snacks.pick to display a list of svn files and commit the ones selected
--- @param opts? svn.picker.Config
function M.picker.commit(opts)
	--- @class SvnPicker
	local base = M.picker.SvnPicker.new(opts)
	if base == nil then
		return
	end

	base.confirm = function(picker, selected_item)
		picker:close()
		local all_items = picker:selected()
		if all_items == nil or #all_items <= 0 then
			all_items = { selected_item }
		end

		local initial_message = {
			"",
			"--This line, and those below, will be ignored--",
			"The following files will be marked for addition and committed:",
		}

		local add_args = {}
		for _, item in ipairs(all_items) do
			if item.status == "?" then
				table.insert(add_args, item.file)
				table.insert(initial_message, "    " .. item.file)
			end
		end

		local commit_args = {}
		table.insert(initial_message, "")
		table.insert(initial_message, "The following files will be committed:")
		for _, item in ipairs(all_items) do
			if item.status ~= "?" then
				table.insert(initial_message, "    " .. item.status .. " " .. item.file)
			end
			table.insert(commit_args, item.file)
		end

		buf_user_input(
			function(_, contents)
				local full_message = ""
				local msg_ended = false
				for _, line in ipairs(contents) do
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
			function(_)
				vim.notify("Commit aborted", vim.log.levels.WARN)
			end,
			initial_message)
	end

	return Snacks.picker.pick(base)
end

--- @param file? string If set, will show previous versions of the current file, otherwise cwd
--- @param limit? integer Max number of items to show
--- @param opts? svn.picker.Config Unused
function M.picker.log(file, limit, opts)
	--- @class SvnPicker
	local base = M.pickerSvnPicker.new(opts)
	if base == nil then
		return
	end
end

vim.api.nvim_create_user_command("Svn", function()
  log(M.api.log("res/data.cdb", { limit = 10 }))
end, {})

return M
