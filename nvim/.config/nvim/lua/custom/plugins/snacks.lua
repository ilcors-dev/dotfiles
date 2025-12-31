return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	---@type snacks.Config
	opts = {
		indent = {
			enabled = true,
		},
		terminal = {
			enabled = true,
			stack = true,
		},
		lazygit = {
			enabled = true,
		},
	},
	keys = {
		{
			"<leader>ot",
			function()
				Snacks.terminal.open()
			end,
			desc = "[O]pen Terminal",
		},
		{
			"<leader>ol",
			function()
				Snacks.lazygit.open()
			end,
			desc = "[O]pen: Lazygit",
		},
	},
}
