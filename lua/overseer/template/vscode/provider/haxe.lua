local M = {}

---@param defn table This is the decoded JSON data for the task
---@return table
M.get_task_opts = function(defn)
  return {
    cmd = vim.list_extend({"cowsay"}, defn.words),
    -- Optional working directory for task
    cwd = nil,
    -- Optionally specify environment variables for the task
    env = nil,
    -- Can override the problem matcher in the task definition
    problem_matcher = nil,
  }
end

return M
