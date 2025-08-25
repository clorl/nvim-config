local get_xml_path = function()
  local parser = vim.treesitter.get_parser(0)
  if not parser then
    print("Could not get treesitter parser for the current buffer.")
    return
  end

  local root = parser:parse()[1]
  if not root then
    print("Treesitter failed to parse the buffer.")
    return
  end

  local row, col = vim.fn.getpos(".")[2] - 1, vim.fn.getpos(".")[3] - 1
  local node = root:get_leaf_at(row, col)

  if not node then
    print("No treesitter node found at cursor position.")
    return
  end

  local path_elements = {}
  local current_node = node

  -- Traverse up the tree to find all parent tags
  while current_node do
    -- Check if the node is a start_tag or end_tag
    if current_node:type() == "start_tag" or current_node:type() == "end_tag" then
      -- Get the tag name (the first child of the tag node)
      local tag_name_node = current_node:child(0)
      if tag_name_node then
        -- Get the text of the tag name
        local tag_name = vim.treesitter.get_node_text(tag_name_node, 0)
        table.insert(path_elements, 1, tag_name) -- Add to the beginning of the list
      end
    end
    current_node = current_node:parent()
  end

  -- Join the elements with "/" to form the full path
  local path = table.concat(path_elements, "/")

  -- Print the final path to the user
  if path ~= "" then
    print("XML Path: " .. path)
  else
    print("Could not determine XML path. Is this a valid XML file?")
  end
end

return {
	{
		"nvim-treesitter/nvim-treesitter",
		name = "treesitter",
		build = ":TSUpdate",
		config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
		opts = {
			ensure_installed = { "xml" },
			opts_extend = { "ensure_installed" },
			auto_install = true,
			highlight = {
				enable = true,
			},
			indent = { enable = true },
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<C-space>",
					node_incremental = "<C-space>",
					scope_incremental = false,
					node_decremental = "<bs>",
				},
			},
		},
	},
	{
		"windwp/nvim-ts-autotag",
		event = "BufWritePre",
		opts = {},
	},
	{
		"folke/ts-comments.nvim",
		event = "VeryLazy",
		opts = {},
	},
}
