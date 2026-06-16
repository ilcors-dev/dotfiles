local function is_lazygit_terminal(bufnr)
	if not vim.api.nvim_buf_is_valid(bufnr) or vim.bo[bufnr].filetype ~= "snacks_terminal" then
		return false
	end

	local meta = vim.b[bufnr].snacks_terminal
	if type(meta) ~= "table" then
		return false
	end

	local cmd = meta.cmd
	if type(cmd) == "table" then
		return cmd[1] == "lazygit"
	end

	return type(cmd) == "string" and cmd:match("^lazygit(%s|$)") ~= nil
end

local function close_visible_lazygit_float()
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local config = vim.api.nvim_win_get_config(win)
		if config.relative ~= "" and is_lazygit_terminal(vim.api.nvim_win_get_buf(win)) then
			pcall(vim.api.nvim_win_close, win, true)
			return
		end
	end
end

local function target_lazygit_source_win()
	local win = vim.g.lazygit_source_win
	if win and vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_config(win).relative == "" then
		return win
	end

	for _, candidate in ipairs(vim.api.nvim_list_wins()) do
		if vim.api.nvim_win_get_config(candidate).relative == "" then
			return candidate
		end
	end

	return vim.api.nvim_get_current_win()
end

require("flatten").setup({
	window = {
		open = function(opts)
			local focus = opts.files[1]
			if not focus then
				return nil, nil
			end

			local win = target_lazygit_source_win()
			vim.api.nvim_win_set_buf(win, focus.bufnr)
			vim.api.nvim_set_current_win(win)
			return focus.bufnr, win
		end,
	},
	hooks = {
		pre_open = function()
			close_visible_lazygit_float()
		end,
		post_open = function(opts)
			if opts.winnr and vim.api.nvim_win_is_valid(opts.winnr) then
				vim.api.nvim_set_current_win(opts.winnr)
			end
		end,
	},
})
