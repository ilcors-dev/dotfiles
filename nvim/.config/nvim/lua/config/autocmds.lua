vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

local term_open_group = vim.api.nvim_create_augroup("term-open", { clear = true })

local function apply_terminal_window_options()
	vim.opt_local.number = false
	vim.opt_local.relativenumber = false
	vim.opt_local.statuscolumn = ""
	vim.opt_local.signcolumn = "no"
	vim.opt_local.foldcolumn = "0"
end

vim.api.nvim_create_autocmd({ "TermOpen", "BufEnter" }, {
	group = term_open_group,
	callback = function(event)
		if vim.bo[event.buf].buftype ~= "terminal" then
			return
		end

		apply_terminal_window_options()

		if event.event ~= "TermOpen" then
			return
		end

		local function resume_terminal_with_scroll()
			vim.cmd.startinsert()
		end

		for _, key in ipairs({ "<ScrollWheelUp>", "<ScrollWheelDown>", "<ScrollWheelLeft>", "<ScrollWheelRight>" }) do
			vim.keymap.set("n", key, function()
				resume_terminal_with_scroll()
			end, { buffer = event.buf, silent = true })
		end
	end,
})
