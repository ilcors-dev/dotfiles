---@class TerminalEntry
---@field buf integer?
---@field created boolean
---@field commands string[]?

---@class TerminalInfo
---@field number integer?
---@field label string
---@field command string

---@class TerminalManager
---@field terminals table<integer, TerminalEntry>
---@field last_editor_buf integer?
---@field _in_terminal_mode boolean
---@field _last_terminal_buf integer?
---@field _last_opencode_buf integer?
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
	_last_opencode_buf = nil,
}

local OPENCODE_LABEL_PREFIX = "opencode #"
local OPENCODE_MAX = 3

local function opencode_label(number)
	return OPENCODE_LABEL_PREFIX .. number
end

local function opencode_buffer_name(number)
	return vim.fs.joinpath(vim.fn.getcwd(), opencode_label(number))
end

---@param buf integer
---@return integer?
local function get_opencode_number(buf)
	if not vim.api.nvim_buf_is_valid(buf) then
		return nil
	end

	if vim.api.nvim_get_option_value("buftype", { buf = buf }) ~= "terminal" then
		return nil
	end

	local label = vim.fs.basename(vim.api.nvim_buf_get_name(buf))
	return tonumber(label:match("^" .. vim.pesc(OPENCODE_LABEL_PREFIX) .. "(%d+)$"))
end

---@param num number
function M.open_or_switch_to_terminal(num)
	if num < 1 or num > 5 then
		return
	end

	local term = M.terminals[num]
	if not term.created or not vim.api.nvim_buf_is_valid(term.buf) then
		M.create_terminal({ num = num })
	else
		vim.api.nvim_set_current_buf(term.buf)
	end
end

---@class CreateTerminalOpts
---@field num integer?
---@field name string?
---@field cmd string|string[]?
---@field env table<string, string>?

---@param opts CreateTerminalOpts
---@return integer?
function M.create_terminal(opts)
	opts = opts or {}

	local current_buf = vim.api.nvim_get_current_buf()
	if vim.bo[current_buf].buftype ~= "terminal" then
		M.last_editor_buf = current_buf
	end

	local buf = vim.api.nvim_create_buf(true, false)

	vim.api.nvim_set_option_value("buflisted", true, { buf = buf })
	vim.api.nvim_set_option_value("modified", false, { buf = buf })
	vim.api.nvim_set_current_buf(buf)

	local job = vim.fn.jobstart(opts.cmd or vim.o.shell, {
		cwd = vim.fn.getcwd(),
		env = opts.env,
		term = true,
	})

	if job <= 0 then
		vim.api.nvim_buf_delete(buf, { force = true })
		vim.notify("Failed to start terminal job", vim.log.levels.ERROR)
		return nil
	end

	if opts.name then
		vim.api.nvim_buf_set_name(buf, opts.name)
	end

	vim.schedule(function()
		vim.cmd.startinsert()
	end)

	if opts.num then
		local term = M.terminals[opts.num]
		term.buf = buf
		term.created = true
	end

	return buf
end

function M.switch_to_editor()
	if M.last_editor_buf and vim.api.nvim_buf_is_valid(M.last_editor_buf) then
		vim.api.nvim_set_current_buf(M.last_editor_buf)
	else
		vim.notify("No valid editor buffer to switch to.", vim.log.levels.WARN)
	end
end

function M.setup()
	M._setup_keybindings()
	M._setup_user_commands()
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

			table.insert(info, {
				number = i,
				label = "term#" .. i,
				command = cmd ~= "" and cmd or vim.o.shell,
			})
		end
	end

	for _, opencode in ipairs(M.get_opencode_terminals()) do
		table.insert(info, opencode)
	end

	return info
end

---@return TerminalInfo[]
function M.get_opencode_terminals()
	local info = {}

	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_valid(buf) then
			local number = get_opencode_number(buf)

			if number then
				table.insert(info, {
					number = number,
					label = opencode_label(number),
					command = "opencode",
				})
			end
		end
	end

	table.sort(info, function(a, b)
		return a.number < b.number
	end)

	return info
end

---@return integer?
function M.get_recent_opencode_buf()
	if M._last_opencode_buf and get_opencode_number(M._last_opencode_buf) then
		return M._last_opencode_buf
	end

	local terms = M.get_opencode_terminals()
	if #terms == 0 then
		return nil
	end

	local buf = M.get_opencode_buf(terms[#terms].number)
	if buf then
		M._last_opencode_buf = buf
	end

	return buf
end

function M.open_new_opencode()
	local number = M._next_opencode_number()
	if not number then
		M.switch_to_last_opencode()
		return
	end

	M.open_or_switch_to_opencode(number)
end

---@param number integer
---@return integer?
function M.open_specific_opencode(number)
	if number < 1 or number > OPENCODE_MAX then
		vim.notify("OpenCode slot must be between 1 and " .. OPENCODE_MAX, vim.log.levels.WARN)
		return nil
	end

	local buf = M.create_terminal({
		name = opencode_buffer_name(number),
		cmd = { "opencode" },
		env = { OPENCODE_ENABLE_EXA = "1" },
	})

	if buf then
		M._last_opencode_buf = buf
	end
end

function M.open_opencode()
	local buf = M.get_recent_opencode_buf()
	if buf then
		vim.api.nvim_set_current_buf(buf)
		return
	end

	M.open_new_opencode()
end

---@param number integer
---@return integer?
function M.get_opencode_buf(number)
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if get_opencode_number(buf) == number then
			return buf
		end
	end
end

---@param number integer
function M.open_or_switch_to_opencode(number)
	local buf = M.get_opencode_buf(number)
	if buf then
		vim.api.nvim_set_current_buf(buf)
		M._last_opencode_buf = buf
		return
	end

	M.open_specific_opencode(number)
end

function M.switch_to_last_opencode()
	local buf = M.get_recent_opencode_buf()
	if buf then
		vim.api.nvim_set_current_buf(buf)
		return
	end

	vim.notify("No recent opencode buffer", vim.log.levels.WARN)
end

function M._setup_keybindings()
	for i = 1, #M.terminals do
		vim.keymap.set("n", "<leader>" .. i, function()
			M.open_or_switch_to_terminal(i)
		end, { desc = "Open/Switch to Terminal " .. i })
	end

	for i = 1, OPENCODE_MAX do
		vim.keymap.set("n", "<leader>o" .. i, function()
			M.open_or_switch_to_opencode(i)
		end, { desc = "OpenCode " .. i })
	end

	vim.keymap.set("n", "<leader>o0", function()
		M.switch_to_last_opencode()
	end, { desc = "OpenCode recent" })

	vim.keymap.set("n", "<leader>oo", function()
		M.open_opencode()
	end, { desc = "[O]pen or focus [O]penCode" })

	vim.keymap.set("n", "<leader>0", function()
		M.switch_to_editor()
	end, { desc = "Switch to Editor" })
end

function M._setup_user_commands()
	vim.api.nvim_create_user_command("OpenCode", function()
		M.open_opencode()
	end, { desc = "Open or focus OpenCode terminal" })

	vim.api.nvim_create_user_command("OpenCodeNew", function()
		M.open_new_opencode()
	end, { desc = "Open a new OpenCode terminal" })
end

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
				if get_opencode_number(buf) then
					M._last_opencode_buf = buf
				end
			elseif M._in_terminal_mode then
				if M._last_terminal_buf and vim.api.nvim_buf_is_valid(M._last_terminal_buf) then
					M._capture_terminal_commands_for_buf(M._last_terminal_buf)
				end

				M._in_terminal_mode = false
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

---@param buf integer
function M._capture_terminal_commands_for_buf(buf)
	local term_num

	for i, term in ipairs(M.terminals) do
		if term.buf == buf then
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
	local last_cmd

	for i = #lines, 1, -1 do
		local line = lines[i]
		for _, prompt in ipairs(prompts) do
			if line:sub(1, #prompt) == prompt then
				local cmd = line:sub(#prompt + 1):gsub("^%s+", ""):gsub("%s+$", "")
				if cmd ~= "" then
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

---@return integer?
function M._next_opencode_number()
	local used = {}

	for _, term in ipairs(M.get_opencode_terminals()) do
		used[term.number] = true
	end

	local number = 1
	while number <= OPENCODE_MAX and used[number] do
		number = number + 1
	end

	if number > OPENCODE_MAX then
		return nil
	end

	return number
end

return M
