---@class TerminalEntry
---@field buf integer?
---@field created boolean
---@field commands string[]?

---@class TerminalInfo
---@field number integer
---@field command string

---@class TerminalManager
---@field terminals table<integer, TerminalEntry>
---@field last_editor_buf integer?
---@field _in_terminal_mode boolean
---@field _last_terminal_buf integer?
local M = {
	terminals = {
		[1] = { buf = nil, created = false, commands = {} },
		[2] = { buf = nil, created = false, commands = {} },
		[3] = { buf = nil, created = false, commands = {} },
		[4] = { buf = nil, created = false, commands = {} },
		[5] = { buf = nil, created = false, commands = {} },
	},
	last_editor_buf = nil,
	_in_terminal_mode = false,
	_last_terminal_buf = nil,
}

---@param num number Terminal number (1-5)
function M.open_or_switch_to_terminal(num)
	if num < 1 or num > 5 then
		return
	end

	local term = M.terminals[num]

	if not term.created or not vim.api.nvim_buf_is_valid(term.buf) then
		M.create_terminal(num)
	else
		vim.api.nvim_set_current_buf(term.buf)
	end
end

---@param num number Terminal number (1-5)
function M.create_terminal(num)
	local term = M.terminals[num]

	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_set_option_value("buflisted", true, { buf = buf })
	vim.api.nvim_set_option_value("filetype", "terminal", { buf = buf })
	vim.api.nvim_set_option_value("modified", false, { buf = buf })

	vim.api.nvim_set_current_buf(buf)

	local term_id = vim.fn.jobstart(vim.o.shell, {
		cwd = vim.fn.getcwd(),
		term = true,
	})

	term.buf = buf
	term.created = true
end

function M.switch_to_editor()
	if M.last_editor_buf and vim.api.nvim_buf_is_valid(M.last_editor_buf) then
		vim.api.nvim_set_current_buf(M.last_editor_buf)
	else
		vim.notify("No editor buffer found", vim.log.levels.WARN)
	end
end

function M.setup()
	M._setup_keybindings()
	M._setup_autocommands()
end

---@return string[]
function M.get_active_terminals()
	local active = {}

	for i = 1, #M.terminals do
		local term = M.terminals[i]

		if term.created and vim.api.nvim_buf_is_valid(term.buf) then
			table.insert(active, tostring(i))
		end
	end

	return active
end

---@return TerminalInfo[]
function M.get_terminals_info()
	local info = {}

	for i = 1, #M.terminals do
		local term = M.terminals[i]

		if term.created and vim.api.nvim_buf_is_valid(term.buf) then
			local cmd = ""

			if term.commands and #term.commands > 0 then
				cmd = term.commands[#term.commands]
			end

			table.insert(info, { number = i, command = cmd or vim.o.shell })
		end
	end

	return info
end

---@private
function M._setup_keybindings()
	for i = 1, #M.terminals do
		vim.keymap.set("n", "<leader>" .. i, function()
			M.open_or_switch_to_terminal(i)
		end, { desc = "Open/Switch to Terminal " .. i })
	end

	vim.keymap.set("n", "<leader>0", function()
		M.switch_to_editor()
	end, { desc = "Switch to Editor" })
end

---@private
function M._setup_autocommands()
	local group = vim.api.nvim_create_augroup("terminal_manager", { clear = true })

	vim.api.nvim_create_autocmd("BufEnter", {
		group = group,
		callback = function()
			local buf = vim.api.nvim_get_current_buf()
			local buftype = vim.api.nvim_get_option_value("buftype", { buf = buf })

			if buftype == "terminal" then
				M._in_terminal_mode = true
				M._last_terminal_buf = buf
				vim.cmd.startinsert()
			else
				if M._in_terminal_mode then
					if M._last_terminal_buf and vim.api.nvim_buf_is_valid(M._last_terminal_buf) then
						M._capture_terminal_commands_for_buf(M._last_terminal_buf)
					end

					M._in_terminal_mode = false
				end

				M.last_editor_buf = buf
			end
		end,
	})

	vim.api.nvim_create_autocmd("TermClose", {
		group = group,
		callback = function(event)
			M._capture_terminal_commands_for_buf(event.buf)
		end,
	})
end

---Gets the last executed command from the terminal buffer and stores it by parsing the buffer lines.
---@private
function M._capture_terminal_commands_for_buf(buf)
	local term_num = nil

	for i, t in ipairs(M.terminals) do
		if t.buf == buf then
			term_num = i
			break
		end
	end

	if not term_num then
		return
	end

	local term = M.terminals[term_num]
	if not term or not vim.api.nvim_buf_is_valid(buf) then
		return
	end

	term.commands = term.commands or {}

	local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

	local prompts = { "❯", "$", "#", "%", ">", ":" }
	local last_cmd = nil

	for i = #lines, 1, -1 do
		local line = lines[i]

		for _, p in ipairs(prompts) do
			if line:sub(1, #p) == p then
				local cmd = line:sub(#p + 1):gsub("^%s+", ""):gsub("%s+$", "")

				if cmd and cmd ~= "" then
					last_cmd = cmd
					break
				end
			end
		end

		if last_cmd then
			break
		end
	end

	if last_cmd then
		table.insert(term.commands, last_cmd)
	end

	while #term.commands > 8 do
		table.remove(term.commands, 1)
	end
end

---@return TerminalManager
return M
