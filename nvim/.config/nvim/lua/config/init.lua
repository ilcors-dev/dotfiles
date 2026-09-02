require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.diagnostics")
require("config.pack")
require("plugins")
require("config.lsp")
local local_work_path = vim.fs.dirname(vim.fn.stdpath("config")) .. "/local-nvim-work.lua"
local local_work = vim.uv.fs_stat(local_work_path) and dofile(local_work_path) or {}
require("core.terminal_manager").setup(local_work.terminal_manager)
if local_work.setup then
	local_work.setup()
end
