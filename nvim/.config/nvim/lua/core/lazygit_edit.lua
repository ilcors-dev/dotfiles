local lazygit_state = require("core.lazygit_state")

local M = {}

local function target_source_win()
	local win = lazygit_state.get_source_win()
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

local function resolve_path(path)
	if vim.fn.fnamemodify(path, ":p") == path then
		return vim.fs.normalize(path)
	end

	local cwd = lazygit_state.get_cwd()
	if cwd and cwd ~= "" then
		return vim.fs.normalize(vim.fs.joinpath(cwd, path))
	end

	return vim.fs.normalize(vim.fn.fnamemodify(path, ":p"))
end

local function hide_lazygit()
	local terminal = lazygit_state.get()
	if not terminal then
		return
	end

	pcall(function()
		if terminal:valid() then
			terminal:hide()
		elseif terminal:buf_valid() then
			terminal.win = nil
		end
	end)
end

local function edit(path, line)
	hide_lazygit()

	local win = target_source_win()
	vim.api.nvim_set_current_win(win)
	vim.cmd.edit(vim.fn.fnameescape(resolve_path(path)))

	if line and tonumber(line) and tonumber(line) > 0 then
		vim.api.nvim_win_set_cursor(win, { tonumber(line), 0 })
		vim.cmd("normal! zz")
	end
	vim.cmd.stopinsert()
end

function M.open(path)
	edit(path)
end

function M.open_at_line(path, line)
	edit(path, line)
end

return M
