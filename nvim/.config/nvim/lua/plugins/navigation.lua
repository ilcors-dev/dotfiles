local common_components = require("neo-tree.sources.common.components")
local manager = require("neo-tree.sources.manager")
local utils = require("neo-tree.utils")

-- Last file shown in a normal window. Its name in the tree uses
-- NeoTreeActiveFile. Focusing the tree itself keeps the previous value.
local active_file

require("neo-tree").setup({
	open_files_do_not_replace_types = { "Trouble", "qf", "edgy" }, -- drop "terminal" so files take over the terminal window
	filesystem = {
		hijack_netrw_behavior = "disabled",
		follow_current_file = {
			enabled = true, -- reveal and focus the current buffer's file in the tree
			leave_dirs_open = false, -- collapse directories that auto-expand when focus moves away
		},
		components = {
			name = function(config, node, state)
				local name = common_components.name(config, node, state)
				if node.path == active_file then
					name.highlight = "NeoTreeActiveFile"
				end
				return name
			end,
		},
		window = {
			mappings = {
				["\\"] = "close_window",
			},
			position = "right",
		},
		filtered_items = {
			visible = true,
			hide_dotfiles = false,
			hide_gitignored = false,
		},
	},
	event_handlers = {
		{
			event = "vim_buffer_enter",
			handler = function()
				local path = manager.get_path_to_reveal()
				if not path then
					return
				end
				path = utils.normalize_path(path)
				if path ~= active_file then
					active_file = path
					manager.redraw("filesystem")
				end
			end,
		},
	},
	close_if_last_window = true,
	enable_git_status = true,
	enable_diagnostics = true,
	window = {
		position = "right",
	},
})

vim.keymap.set("n", "\\", "<cmd>Neotree reveal<CR>", { desc = "NeoTree reveal", silent = true })
