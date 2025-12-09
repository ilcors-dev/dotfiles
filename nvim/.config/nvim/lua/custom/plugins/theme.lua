return {
	{
		"tiesen243/vercel.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("vercel").setup({
				transparent = false,
				styles = {
					comments = { italic = true },
					keywords = { bold = true },
				},
			})
			vim.o.background = "dark"
			vim.cmd.colorscheme("vercel")
		end,
	},

	{
		"navarasu/onedark.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("onedark").setup({
				style = "light",
				transparent = false,
				code_style = {
					comments = "italic",
				},
			})
			require("onedark").load()
		end,
	},

	{
		"folke/tokyonight.nvim",
		enabled = false,
	},

	{
		"f-person/auto-dark-mode.nvim",
		lazy = false,
		priority = 900,
		config = function()
			require("auto-dark-mode").setup({
				update_interval = 1000,
				set_dark_mode = function()
					vim.o.background = "dark"
					vim.cmd.colorscheme("vercel")
				end,
				set_light_mode = function()
					vim.o.background = "light"
					vim.cmd.colorscheme("onedark")
				end,
			})
			require("auto-dark-mode").init()
		end,
	},
}
