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
				Snacks.terminal.toggle()
			end,
			desc = "[O]pen: Toggle Terminal",
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
