local severity = vim.diagnostic.severity

vim.diagnostic.config({
	severity_sort = true,
	float = { border = "rounded", source = "if_many" },
	underline = { severity = severity.ERROR },
	signs = vim.g.have_nerd_font and {
		text = {
			[severity.ERROR] = "󰅚 ",
			[severity.WARN] = "󰀪 ",
			[severity.INFO] = "󰋽 ",
			[severity.HINT] = "󰌶 ",
		},
	} or {},
	virtual_text = {
		source = "if_many",
		spacing = 2,
		format = function(diagnostic)
			return diagnostic.message
		end,
	},
})
