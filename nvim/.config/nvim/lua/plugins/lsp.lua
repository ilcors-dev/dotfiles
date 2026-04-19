require("lazydev").setup({
	library = {
		{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
	},
})

require("fidget").setup({
	progress = {
		ignore_done_already = false,
		ignore_empty_message = false,
		lsp = {
			log_handler = true,
		},
		display = {
			skip_history = false,
		},
	},
})

require("blink.cmp").setup({
	keymap = {
		preset = "default",
	},
	appearance = {
		nerd_font_variant = "mono",
	},
	completion = {
		documentation = { auto_show = false, auto_show_delay_ms = 500 },
	},
	sources = {
		default = { "lsp", "path", "snippets", "lazydev" },
		providers = {
			lazydev = { module = "lazydev.integrations.blink", score_offset = 100 },
		},
	},
	snippets = { preset = "luasnip" },
	fuzzy = {
		implementation = "prefer_rust",
		prebuilt_binaries = {
			force_version = "v*",
		},
	},
	signature = { enabled = true },
})

require("venv-selector").setup({
	options = {
		enable_cached_venvs = true,
		cached_venv_automatic_activation = true,
		notify_user_on_venv_activation = true,
		picker = "snacks",
	},
	search = {
		workspace_backend = {
			command = "$FD '/bin/python$' '$WORKSPACE_PATH/backend/jet_core' --full-path --color never -HI -a -L -E __pycache__ -E .git -E site-packages",
		},
	},
})

vim.keymap.set("n", "<leader>cv", "<cmd>VenvSelect<CR>", { desc = "Select Python [V]env" })
