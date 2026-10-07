vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true
vim.g.terminal_manager_agent_command = "omp"

vim.o.number = true
vim.o.relativenumber = true
vim.o.mouse = "a"
vim.o.showmode = false
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.signcolumn = "yes"
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.o.inccommand = "split"
vim.o.cursorline = true
vim.opt.guicursor = {
	"n-v:block",
	"i-c-ci-ve:ver100",
}
vim.o.scrolloff = 10
vim.o.confirm = true
-- Draw with the terminal's 16-color ANSI palette instead of 24-bit RGB so
-- Neovim follows whatever theme the terminal is using.
vim.o.termguicolors = false

-- No permanent command-line row: the cmdline only appears while typing a
-- command, and messages go to ui2's ephemeral floating message window.
vim.o.cmdheight = 0
vim.o.showcmdloc = "statusline"
require("vim._core.ui2").enable({
	msg = {
		targets = "msg",
		msg = { timeout = 4000 },
	},
})

vim.o.tabstop = 2
vim.o.softtabstop = 2
vim.o.shiftwidth = 2

vim.schedule(function()
	vim.o.clipboard = "unnamedplus"
end)
