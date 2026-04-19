local group = vim.api.nvim_create_augroup("nvim-pack-hooks", { clear = true })

vim.g.copilot_no_maps = true
vim.g.copilot_no_tab_map = true

vim.api.nvim_create_autocmd("PackChanged", {
	group = group,
	callback = function(event)
		local data = event.data
		if not data or (data.kind ~= "install" and data.kind ~= "update") then
			return
		end

		if data.spec.name == "LuaSnip" and vim.fn.has("win32") == 0 and vim.fn.executable("make") == 1 then
			vim.system({ "make", "install_jsregexp" }, { cwd = data.path }):wait()
		end
	end,
})

local function gh(repo)
	return "https://github.com/" .. repo
end

vim.pack.add({
	gh("L3MON4D3/LuaSnip"),
	gh("MunifTanjim/nui.nvim"),
	gh("WhoIsSethDaniel/mason-tool-installer.nvim"),
	gh("echasnovski/mini.nvim"),
	gh("f-person/auto-dark-mode.nvim"),
	gh("folke/lazydev.nvim"),
	gh("folke/snacks.nvim"),
	gh("folke/todo-comments.nvim"),
	gh("folke/which-key.nvim"),
	{ src = gh("github/copilot.vim"), version = "release" },
	gh("j-hui/fidget.nvim"),
	gh("lewis6991/gitsigns.nvim"),
	gh("linux-cultist/venv-selector.nvim"),
	gh("mason-org/mason-lspconfig.nvim"),
	gh("mason-org/mason.nvim"),
	gh("mfussenegger/nvim-lint"),
	gh("navarasu/onedark.nvim"),
	gh("neovim/nvim-lspconfig"),
	gh("nvim-lua/plenary.nvim"),
	gh("nvim-neo-tree/neo-tree.nvim"),
	gh("nvim-tree/nvim-web-devicons"),
	{ src = gh("nvim-treesitter/nvim-treesitter"), version = "main" },
	{ src = gh("saghen/blink.cmp"), version = vim.version.range("1") },
	gh("stevearc/conform.nvim"),
	gh("tiesen243/vercel.nvim"),
	gh("windwp/nvim-autopairs"),
}, { confirm = false, load = true })
