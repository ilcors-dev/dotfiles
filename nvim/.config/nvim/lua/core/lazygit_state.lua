local M = {
	terminal = nil,
	source_win = nil,
	cwd = nil,
}

function M.set(terminal)
	M.terminal = terminal
end

function M.get()
	return M.terminal
end

function M.clear()
	M.terminal = nil
end

function M.set_source_win(win)
	M.source_win = win
end

function M.get_source_win()
	return M.source_win
end

function M.set_cwd(cwd)
	M.cwd = cwd
end

function M.get_cwd()
	return M.cwd
end

return M
