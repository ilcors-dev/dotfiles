require("neo-tree").setup({
	filesystem = {
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
	close_if_last_window = true,
	enable_git_status = true,
	enable_diagnostics = true,
	window = {
		position = "right",
	},
})

vim.keymap.set("n", "\\", "<cmd>Neotree reveal<CR>", { desc = "NeoTree reveal", silent = true })
