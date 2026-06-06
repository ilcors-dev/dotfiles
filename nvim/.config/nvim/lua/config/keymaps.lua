vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "<leader>w", "<cmd>w<CR>", { desc = "Save buffer" })

local function project_root()
	return vim.fs.root(0, {
		".git",
		"package.json",
		"pyproject.toml",
		"Cargo.toml",
		"go.mod",
		"Makefile",
	}) or vim.fn.getcwd()
end

local function visual_selection_text()
	local start_pos = vim.api.nvim_buf_get_mark(0, "<")
	local end_pos = vim.api.nvim_buf_get_mark(0, ">")
	local start_row, start_col = start_pos[1], start_pos[2]
	local end_row, end_col = end_pos[1], end_pos[2]

	if start_row == 0 or end_row == 0 then
		return nil
	end

	if start_row > end_row or (start_row == end_row and start_col > end_col) then
		start_row, end_row = end_row, start_row
		start_col, end_col = end_col, start_col
	end

	local lines = vim.api.nvim_buf_get_text(0, start_row - 1, start_col, end_row - 1, end_col + 1, {})
	if #lines == 0 then
		return nil
	end

	return table.concat(lines, "\n")
end

local function esc_sub_pattern(text)
	return vim.fn.escape(text, [[\/]])
end

local function open_substitute_cmd(cmdline, left_count)
	local keys = ":<C-u>" .. cmdline .. string.rep("<Left>", left_count)
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "n", false)
end

local function open_file_replace(pattern, confirm_each)
	local flags = confirm_each and "gc" or "g"
	open_substitute_cmd(("%%s/%s//%s"):format(pattern, flags), #flags + 1)
end

local function populate_tracked_quickfix(needle, word_boundary)
	local root = project_root()
	local args = { "git", "grep", "-n", "--column", "-F" }
	if word_boundary then
		table.insert(args, "-w")
	end
	table.insert(args, "--")
	table.insert(args, needle)

	local result = vim.system(args, { text = true, cwd = root }):wait()
	if result.code ~= 0 and result.code ~= 1 then
		local stderr = vim.trim(result.stderr or "")
		vim.notify(stderr ~= "" and stderr or "git grep failed", vim.log.levels.ERROR)
		return false
	end

	local lines = vim.split(result.stdout or "", "\n", { trimempty = true })
	if #lines == 0 then
		vim.notify("No tracked-file matches found", vim.log.levels.INFO)
		return false
	end

	vim.fn.setqflist({}, "r", {
		title = "Tracked-file replace matches",
		lines = lines,
		efm = "%f:%l:%c:%m",
	})
	vim.cmd.copen()
	return true
end

local function open_project_replace(needle, pattern, confirm_each)
	if not populate_tracked_quickfix(needle, true) then
		return
	end

	local flags = confirm_each and "gc" or "g"
	local suffix = " | update"
	local cmdline = ("cfdo %%s/%s//%s%s"):format(pattern, flags, suffix)
	open_substitute_cmd(cmdline, #suffix + #flags + 1)
end

local function replace_cword_in_file(confirm_each)
	local word = vim.fn.expand("<cword>")
	if word == "" then
		vim.notify("No word under cursor", vim.log.levels.WARN)
		return
	end

	local pattern = "\\<" .. esc_sub_pattern(word) .. "\\>"
	open_file_replace(pattern, confirm_each)
end

local function replace_cword_in_project(confirm_each)
	local word = vim.fn.expand("<cword>")
	if word == "" then
		vim.notify("No word under cursor", vim.log.levels.WARN)
		return
	end

	local pattern = "\\<" .. esc_sub_pattern(word) .. "\\>"
	open_project_replace(word, pattern, confirm_each)
end

local function replace_visual_in_file(confirm_each)
	local text = visual_selection_text()
	if not text or text == "" then
		vim.notify("No visual selection found", vim.log.levels.WARN)
		return
	end

	local pattern = "\\V" .. esc_sub_pattern(text)
	open_file_replace(pattern, confirm_each)
end

local function find_file_usages()
	local stem = vim.fn.expand("%:t:r")
	if stem == "" then
		vim.notify("Cannot determine component name from filename", vim.log.levels.WARN)
		return
	end

	local search_term = (stem == "index") and vim.fn.expand("%:p:h:t") or stem

	Snacks.picker.grep({
		search = search_term,
		title = "Usages: " .. search_term,
	})
end

vim.keymap.set("n", "<leader>cp", function()
	local root = project_root()

	local path = vim.api.nvim_buf_get_name(0)
	if path == "" then
		vim.notify("No file path for current buffer", vim.log.levels.WARN)
		return
	end

	local relpath = vim.fs.relpath(root, path) or vim.fn.fnamemodify(path, ":.")
	local cursor = vim.api.nvim_win_get_cursor(0)
	local location = ("%s:%d:%d"):format(relpath, cursor[1], cursor[2] + 1)

	vim.fn.setreg("+", location)
	vim.notify("Copied: " .. location)
end, { desc = "[C]opy file [P]osition" })

vim.keymap.set("n", "<leader>rw", function()
	replace_cword_in_file(false)
end, { desc = "[R]eplace current [W]ord in file" })
vim.keymap.set("n", "<leader>rW", function()
	replace_cword_in_file(true)
end, { desc = "[R]eplace current word in file (confirm)" })
vim.keymap.set("x", "<leader>rr", function()
	replace_visual_in_file(false)
end, { desc = "[R]eplace visual selection in file" })
vim.keymap.set("x", "<leader>rR", function()
	replace_visual_in_file(true)
end, { desc = "[R]eplace visual selection in file (confirm)" })
vim.keymap.set("n", "<leader>rp", function()
	replace_cword_in_project(false)
end, { desc = "[R]eplace current word in tracked files" })
vim.keymap.set("n", "<leader>rP", function()
	replace_cword_in_project(true)
end, { desc = "[R]eplace current word in tracked files (confirm)" })
vim.keymap.set("n", "<leader>ro", "<cmd>copen<CR>", { desc = "[R]eplace quickfix [O]pen" })
vim.keymap.set("n", "<leader>rc", "<cmd>cclose<CR>", { desc = "[R]eplace quickfix [C]lose" })
vim.keymap.set("n", "<leader>rn", "<cmd>cnext<CR>", { desc = "[R]eplace quickfix [N]ext" })
vim.keymap.set("n", "<leader>rN", "<cmd>cprev<CR>", { desc = "[R]eplace quickfix previous" })

vim.keymap.set("n", "<leader>fu", find_file_usages, { desc = "[F]ind file [U]sages" })

vim.keymap.set("n", "<leader>oq", vim.diagnostic.setloclist, { desc = "[O]pen diagnostic [Q]uickfix list" })
vim.keymap.set("n", "<leader>od", function()
	vim.diagnostic.open_float(0, { scope = "line" })
end, { desc = "[O]pen Line [D]iagnostic" })

vim.keymap.set("n", "<leader>da", vim.lsp.buf.code_action, { desc = "[D]iagnostic [A]pply" })
vim.keymap.set("n", "<leader>dc", function()
	local current_line = vim.api.nvim_win_get_cursor(0)[1] - 1
	local diagnostics = vim.diagnostic.get(0, { lnum = current_line })
	if #diagnostics > 0 then
		local message = diagnostics[1].message
		vim.fn.setreg("+", message)
		vim.notify("Diagnostic copied: " .. message, vim.log.levels.INFO)
	else
		vim.notify("No diagnostic on current line", vim.log.levels.WARN)
	end
end, { desc = "Line [D]iagnostic Copy" })

vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

vim.keymap.set("n", "<left>", '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set("n", "<right>", '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set("n", "<up>", '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set("n", "<down>", '<cmd>echo "Use j to move!!"<CR>')

vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

vim.keymap.set("n", "<C-S-h>", "<C-w>H", { desc = "Move window to the left" })
vim.keymap.set("n", "<C-S-l>", "<C-w>L", { desc = "Move window to the right" })
vim.keymap.set("n", "<C-S-j>", "<C-w>J", { desc = "Move window to the lower" })
vim.keymap.set("n", "<C-S-k>", "<C-w>K", { desc = "Move window to the upper" })
