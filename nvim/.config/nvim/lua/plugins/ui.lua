require("which-key").setup({
	delay = 0,
	icons = {
		mappings = vim.g.have_nerd_font,
		keys = vim.g.have_nerd_font and {} or {
			Up = "<Up> ",
			Down = "<Down> ",
			Left = "<Left> ",
			Right = "<Right> ",
			C = "<C-...> ",
			M = "<M-...> ",
			D = "<D-...> ",
			S = "<S-...> ",
			CR = "<CR> ",
			Esc = "<Esc> ",
			ScrollWheelDown = "<ScrollWheelDown> ",
			ScrollWheelUp = "<ScrollWheelUp> ",
			NL = "<NL> ",
			BS = "<BS> ",
			Space = "<Space> ",
			Tab = "<Tab> ",
			F1 = "<F1>",
			F2 = "<F2>",
			F3 = "<F3>",
			F4 = "<F4>",
			F5 = "<F5>",
			F6 = "<F6>",
			F7 = "<F7>",
			F8 = "<F8>",
			F9 = "<F9>",
			F10 = "<F10>",
			F11 = "<F11>",
			F12 = "<F12>",
		},
	},
	spec = {
		{ "<leader>s", group = "[S]earch" },
		{ "<leader>c", group = "[C]ode" },
		{ "<leader>g", group = "[G]itHub" },
		{ "<leader>t", group = "[T]oggle" },
		{ "<leader>h", group = "Git [H]unk", mode = { "n", "v" } },
		{ "<leader>o", group = "[O]pen" },
	},
})

local milli_splash = require("milli").load({ splash = "blackhole" })

require("snacks").setup({
	dashboard = {
		enabled = true,
		preset = {
			header = table.concat(milli_splash.frames[1], "\n"),
		},
		sections = {
			{ section = "header", padding = 1 },
			{ section = "keys", gap = 1, padding = 1 },
		},
	},
	indent = {
		enabled = true,
	},
	picker = {
		ui_select = true,
		sources = {
			files = {
				hidden = true,
				ignored = false,
			},
			buffers = {
				transform = function(item)
					if item.buf and item.pos and vim.api.nvim_buf_is_loaded(item.buf) then
						local ok, line_count = pcall(vim.api.nvim_buf_line_count, item.buf)
						if ok and item.pos[1] > line_count then
							item.pos = { line_count, 0 }
						end
					end

					return item
				end,
			},
		},
	},
	terminal = {
		enabled = true,
		stack = true,
	},
	lazygit = {
		enabled = true,
	},
	gh = {},
	scratch = {},
})
require("milli").snacks({ splash = "blackhole", loop = true })

vim.api.nvim_create_autocmd("UIEnter", {
	once = true,
	callback = function()
		vim.schedule(function()
			if vim.bo.filetype == "snacks_dashboard" then
				return
			end

			local argc = vim.fn.argc(-1)
			local directory_start = argc == 1 and vim.fn.isdirectory(vim.fn.argv(0)) == 1
			local empty_start = argc == 0
			if not directory_start and not empty_start then
				return
			end

			pcall(vim.cmd, "Neotree close")

			local win = vim.api.nvim_get_current_win()
			for _, candidate in ipairs(vim.api.nvim_list_wins()) do
				local buf = vim.api.nvim_win_get_buf(candidate)
				if vim.api.nvim_win_get_config(candidate).relative == "" and vim.bo[buf].filetype ~= "neo-tree" then
					win = candidate
					break
				end
			end

			vim.api.nvim_set_current_win(win)

			local buf = vim.api.nvim_get_current_buf()
			local use_current = empty_start
				and vim.api.nvim_buf_get_name(buf) == ""
				and not vim.bo[buf].modified
				and vim.api.nvim_buf_line_count(buf) == 1
				and vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] == ""

			Snacks.dashboard({
				buf = use_current and buf or vim.api.nvim_create_buf(false, true),
				win = win,
			})
		end)
	end,
})

local map = vim.keymap.set

map("n", "<leader>.", function()
	Snacks.scratch({
		name = "Notes",
		ft = "markdown",
		filekey = {
			cwd = false,
			branch = false,
			count = false,
		},
		win = {
			b = {
				disable_lint = true,
			},
		},
	})
end, { desc = "Toggle Scratch Buffer" })

map("n", "<leader>S", function()
	Snacks.scratch.select()
end, { desc = "Select Scratch Buffer" })
map("n", "<leader>sh", function()
	Snacks.picker.help()
end, { desc = "[S]earch [H]elp" })
map("n", "<leader>sk", function()
	Snacks.picker.keymaps()
end, { desc = "[S]earch [K]eymaps" })
map("n", "<leader>sf", function()
	Snacks.picker.files()
end, { desc = "[S]earch [F]iles" })
map("n", "<leader>ss", function()
	Snacks.picker()
end, { desc = "[S]elect [S]nacks Picker" })
map({ "n", "x" }, "<leader>sw", function()
	Snacks.picker.grep_word()
end, { desc = "[S]earch current [W]ord" })
map("n", "<leader>sg", function()
	Snacks.picker.grep()
end, { desc = "[S]earch by [G]rep" })
map("n", "<leader>sd", function()
	Snacks.picker.diagnostics()
end, { desc = "[S]earch [D]iagnostics" })
map("n", "<leader>sr", function()
	Snacks.picker.resume()
end, { desc = "[S]earch [R]esume" })
map("n", "<leader>s.", function()
	Snacks.picker.recent()
end, { desc = '[S]earch Recent Files ("." for repeat)' })
map("n", "<leader><leader>", function()
	Snacks.picker.buffers()
end, { desc = "[ ] Find existing buffers" })
map("n", "<leader>/", function()
	Snacks.picker.lines()
end, { desc = "[/] Fuzzily search in current buffer" })
map("n", "<leader>s/", function()
	Snacks.picker.grep_buffers()
end, { desc = "[S]earch [/] in Open Files" })
map("n", "<leader>sn", function()
	Snacks.picker.files({ cwd = vim.fn.stdpath("config") })
end, { desc = "[S]earch [N]eovim files" })
map("n", "<leader>gi", function()
	Snacks.picker.gh_issue()
end, { desc = "GitHub Issues (open)" })
map("n", "<leader>gI", function()
	Snacks.picker.gh_issue({ state = "all" })
end, { desc = "GitHub Issues (all)" })
map("n", "<leader>gp", function()
	Snacks.picker.gh_pr()
end, { desc = "GitHub Pull Requests (open)" })
map("n", "<leader>gP", function()
	Snacks.picker.gh_pr({ state = "all" })
end, { desc = "GitHub Pull Requests (all)" })
map("n", "<leader>gm", function()
	Snacks.picker.gh_pr({ author = "@me" })
end, { desc = "GitHub Pull Requests (mine)" })
map("n", "<leader>gr", function()
	Snacks.picker.gh_pr({
		state = "open",
		search = '(user-review-requested:@me OR team-review-requested:jet-hr/tech) -author:app/dependabot -label:"on hold"',
	})
end, { desc = "GitHub Pull Requests (review)" })
map("n", "<leader>ot", function()
	Snacks.terminal.open()
end, { desc = "[O]pen Terminal" })
map("n", "<leader>ol", function()
	Snacks.lazygit.open()
end, { desc = "[O]pen: Lazygit" })

require("vercel").setup({
	transparent = false,
	styles = {
		comments = { italic = true },
		keywords = { bold = true },
	},
})

require("onedark").setup({
	style = "light",
	transparent = false,
	code_style = {
		comments = "italic",
	},
})

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

require("todo-comments").setup({ signs = false })

require("mini.ai").setup({ n_lines = 500 })
require("mini.surround").setup()

local statusline = require("mini.statusline")
statusline.setup({
	use_icons = vim.g.have_nerd_font,
	content = {
		active = function()
			local buffers = {}
			local filename

			if MiniStatusline.is_truncated(120) then
				filename = "%t%m%r"
			elseif MiniStatusline.is_truncated(180) then
				filename = "%f%m%r"
			else
				filename = "%F%m%r"
			end

			table.insert(buffers, filename)

			local tm = require("core.terminal_manager")
			if #tm.get_active_terminals() > 0 then
				for _, term in pairs(tm.get_terminals_info()) do
					table.insert(buffers, "term#" .. term.number .. ":" .. term.command:sub(1, 24))
				end
			end

			local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
			local git = MiniStatusline.section_git({ trunc_width = 40 })
			local diff = MiniStatusline.section_diff({ trunc_width = 75 })
			local diagnostics = MiniStatusline.section_diagnostics({ trunc_width = 75 })
			local lsp = MiniStatusline.section_lsp({ trunc_width = 75 })
			local fileinfo = MiniStatusline.section_fileinfo({ trunc_width = 120 })
			local location = MiniStatusline.section_location({ trunc_width = 75 })
			local search = MiniStatusline.section_searchcount({ trunc_width = 75 })

			return MiniStatusline.combine_groups({
				{ hl = mode_hl, strings = { mode } },
				{ hl = "MiniStatuslineDevinfo", strings = { git, diff, diagnostics, lsp } },
				"%<",
				{ hl = "MiniStatuslineFilename", strings = buffers },
				"%=",
				{ hl = "MiniStatuslineFileinfo", strings = { fileinfo } },
				{ hl = mode_hl, strings = { search, location } },
			})
		end,
	},
})

statusline.section_location = function()
	return "%2l:%-2v"
end
