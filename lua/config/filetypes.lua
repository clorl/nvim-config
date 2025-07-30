return {
  ts = {
    pattern = {"*.hx"}
  },
  hxml = {
    pattern = {"*.hxml"}
  },
  log = {
    pattern = {"*.log"},
    callback = function(opts)
      vim.bo.wrap = true
    end
  }
}
