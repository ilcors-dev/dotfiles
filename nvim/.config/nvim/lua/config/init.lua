require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.diagnostics")
require("config.pack")
require("plugins")
require("config.lsp")
require("core.terminal_manager").setup()
local local_work_path = vim.fs.dirname(vim.fn.stdpath("config")) .. "/local-nvim-work.lua"
if vim.uv.fs_stat(local_work_path) then
	dofile(local_work_path).setup()
end
