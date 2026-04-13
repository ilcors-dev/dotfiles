vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.have_nerd_font = true

vim.o.number = true
vim.o.relativenumber = true

vim.o.mouse = "a" -- enable mouse mode
vim.o.showmode = false

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(function()
	vim.o.clipboard = "unnamedplus"
end)

vim.o.breakindent = true -- enable break indent

vim.o.undofile = true -- Save undo history

-- case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.ignorecase = true
vim.o.smartcase = true

vim.o.signcolumn = "yes"

vim.o.updatetime = 250 -- decrease update time
vim.o.timeoutlen = 300 -- decrease mapped sequence wait time

-- Configure how new splits should be opened
vim.o.splitright = true
vim.o.splitbelow = true

vim.o.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

vim.o.inccommand = "split" -- preview substitutions live, as you type!

-- show which line your cursor is on
vim.o.cursorline = true
vim.opt.guicursor = {
	"n-v:block",
	"i-c-ci-ve:ver100",
}

vim.o.scrolloff = 10 -- minimal number of screen lines to keep above and below the cursor.

vim.o.confirm = true

vim.o.tabstop = 2
vim.o.softtabstop = 2
vim.o.shiftwidth = 2

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "<leader>w", ":w<CR>", { desc = "Save buffer" })

vim.keymap.set("n", "<leader>oq", vim.diagnostic.setloclist, { desc = "[O]pen diagnostic [Q]uickfix list" })
vim.keymap.set("n", "<leader>od", function()
	vim.diagnostic.open_float(0, { scope = "line" })
end, { desc = "[O]pen Line [D]iagnostic" })

vim.keymap.set("n", "<leader>da", vim.lsp.buf.code_action, { desc = "[D]iagnostic [A]pply" })
vim.keymap.set("n", "<leader>dc", function()
	local current_line = vim.api.nvim_win_get_cursor(0)[1] - 1 -- 0-indexed line
	local diagnostics = vim.diagnostic.get(0, { lnum = current_line })
	if #diagnostics > 0 then
		local message = diagnostics[1].message -- Take first diagnostic (or loop for all)
		vim.fn.setreg("+", message) -- Copy to system clipboard
		vim.notify("Diagnostic copied: " .. message, vim.log.levels.INFO)
	else
		vim.notify("No diagnostic on current line", vim.log.levels.WARN)
	end
end, { desc = "Line [D]iagnostic Copy" })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

vim.keymap.set("n", "<left>", '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set("n", "<right>", '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set("n", "<up>", '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set("n", "<down>", '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- NOTE: Some terminals have colliding keymaps or are not able to send distinct keycodes
vim.keymap.set("n", "<C-S-h>", "<C-w>H", { desc = "Move window to the left" })
vim.keymap.set("n", "<C-S-l>", "<C-w>L", { desc = "Move window to the right" })
vim.keymap.set("n", "<C-S-j>", "<C-w>J", { desc = "Move window to the lower" })
vim.keymap.set("n", "<C-S-k>", "<C-w>K", { desc = "Move window to the upper" })

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

vim.api.nvim_create_autocmd("TermOpen", {
	group = vim.api.nvim_create_augroup("custom-term-open", { clear = true }),
	callback = function()
		vim.opt.number = false
		vim.opt.relativenumber = false
	end,
})

-- install `lazy.nvim` plugin manager - from nvim 0.12 on, we can use the included vim.pack. we will see.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		error("Error cloning lazy.nvim:\n" .. out)
	end
end

---@type vim.Option
local rtp = vim.opt.rtp
rtp:prepend(lazypath)

require("lazy").setup({
	{
		"lewis6991/gitsigns.nvim",
		opts = {
			signs = {
				add = { text = "+" },
				change = { text = "~" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
			},
		},
	},

	{
		"folke/which-key.nvim",
		event = "VimEnter",
		opts = {
			delay = 0,
			icons = {
				mappings = vim.g.have_nerd_font,
				keys = vim.g.have_nerd_font and {} or {
					Up = "<Up> ",
					Down = "<Down> ",
					Left = "<Left> ",
					Right = "<Right> ",
					C = "<C-…> ",
					M = "<M-…> ",
					D = "<D-…> ",
					S = "<S-…> ",
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
				{ "<leader>t", group = "[T]oggle" },
				{ "<leader>h", group = "Git [H]unk", mode = { "n", "v" } },
				{ "<leader>o", group = "[O]pen" },
			},
		},
	},
	{
		"linux-cultist/venv-selector.nvim",
		ft = "python",
		cmd = { "VenvSelect", "VenvSelectLog", "VenvSelectCache" },
		keys = {
			{ "<leader>cv", "<cmd>VenvSelect<cr>", desc = "Select Python [V]env", ft = "python" },
		},
		opts = {
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
		},
	},

	-- LSP Plugins
	{
		-- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
		-- used for completion, annotations and signatures of Neovim apis
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				-- Load luvit types when the `vim.uv` word is found
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			},
		},
	},
	{
		-- Main LSP Configuration
		"neovim/nvim-lspconfig",
		dependencies = {
			-- Automatically install LSPs and related tools to stdpath for Neovim
			-- Mason must be loaded before its dependents so we need to set it up here.
			-- NOTE: `opts = {}` is the same as calling `require('mason').setup({})`
			{ "mason-org/mason.nvim", opts = {} },
			"mason-org/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",

			-- Useful status updates for LSP.
			{
				"j-hui/fidget.nvim",
				opts = {
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
				},
			},

			-- Allows extra capabilities provided by blink.cmp
			"saghen/blink.cmp",
		},
		config = function()
			local python_root_markers = {
				"ty.toml",
				"pyproject.toml",
				"setup.py",
				"setup.cfg",
				"requirements.txt",
				"Pipfile",
			}

			local function find_python_root(bufnr)
				return vim.fs.root(bufnr, python_root_markers)
					or vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))
					or vim.fn.getcwd()
			end

			local function on_ruff_attach(client)
				client.server_capabilities.hoverProvider = false
				client.server_capabilities.signatureHelpProvider = nil
				client.server_capabilities.documentFormattingProvider = false
				client.server_capabilities.documentRangeFormattingProvider = false
			end

			local tsserver_filetypes = {
				"javascript",
				"javascriptreact",
				"typescript",
				"typescriptreact",
				"vue",
			}

			local function on_typescript_attach(client, bufnr)
				client.server_capabilities.documentFormattingProvider = false
				client.server_capabilities.documentRangeFormattingProvider = false

				if vim.bo[bufnr].filetype == "vue" and client.server_capabilities.semanticTokensProvider then
					client.server_capabilities.semanticTokensProvider.full = false
				end
			end

			local vue_language_server_path = vim.fn.stdpath("data")
				.. "/mason/packages/vue-language-server/node_modules/@vue/language-server"
			local vue_plugin = {
				name = "@vue/typescript-plugin",
				location = vue_language_server_path,
				languages = { "vue" },
				configNamespace = "typescript",
			}

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
				callback = function(event)
					local map = function(keys, func, desc, mode)
						mode = mode or "n"
						vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
					end

					map("grn", vim.lsp.buf.rename, "[R]e[n]ame")

					map("gra", vim.lsp.buf.code_action, "[G]oto Code [A]ction", { "n", "x" })

					map("grr", function()
						Snacks.picker.lsp_references()
					end, "[G]oto [R]eferences")

					map("gri", function()
						Snacks.picker.lsp_implementations()
					end, "[G]oto [I]mplementation")

					map("grd", function()
						Snacks.picker.lsp_definitions()
					end, "[G]oto [D]efinition")

					map("grD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

					map("gO", function()
						Snacks.picker.lsp_symbols()
					end, "Open Document Symbols")

					map("gW", function()
						Snacks.picker.lsp_workspace_symbols()
					end, "Open Workspace Symbols")

					map("grt", function()
						Snacks.picker.lsp_type_definitions()
					end, "[G]oto [T]ype Definition")

					local client = vim.lsp.get_client_by_id(event.data.client_id)
					if
						client
						and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf)
					then
						local highlight_augroup =
							vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
						vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.document_highlight,
						})

						vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.clear_references,
						})

						vim.api.nvim_create_autocmd("LspDetach", {
							group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
							callback = function(event2)
								vim.lsp.buf.clear_references()
								vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
							end,
						})
					end

					if
						client
						and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf)
					then
						map("<leader>th", function()
							vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
						end, "[T]oggle Inlay [H]ints")
					end
				end,
			})

			-- Diagnostic Config
			-- See :help vim.diagnostic.Opts
			vim.diagnostic.config({
				severity_sort = true,
				float = { border = "rounded", source = "if_many" },
				underline = { severity = vim.diagnostic.severity.ERROR },
				signs = vim.g.have_nerd_font and {
					text = {
						[vim.diagnostic.severity.ERROR] = "󰅚 ",
						[vim.diagnostic.severity.WARN] = "󰀪 ",
						[vim.diagnostic.severity.INFO] = "󰋽 ",
						[vim.diagnostic.severity.HINT] = "󰌶 ",
					},
				} or {},
				virtual_text = {
					source = "if_many",
					spacing = 2,
					format = function(diagnostic)
						local diagnostic_message = {
							[vim.diagnostic.severity.ERROR] = diagnostic.message,
							[vim.diagnostic.severity.WARN] = diagnostic.message,
							[vim.diagnostic.severity.INFO] = diagnostic.message,
							[vim.diagnostic.severity.HINT] = diagnostic.message,
						}
						return diagnostic_message[diagnostic.severity]
					end,
				},
			})

			local servers = {
				ty = {
					cmd = { vim.fn.expand("~/.local/bin/ty"), "server" },
					root_dir = function(bufnr, on_dir)
						on_dir(find_python_root(bufnr))
					end,
					init_options = {
						logLevel = "error",
					},
					settings = {
						ty = {
							diagnosticMode = "openFilesOnly",
							completions = {
								autoImport = false,
							},
							configuration = {
								src = {
									exclude = { "**/migrations/**" },
								},
							},
						},
					},
				},
				ruff = {
					root_dir = function(bufnr, on_dir)
						on_dir(find_python_root(bufnr))
					end,
					on_attach = on_ruff_attach,
					init_options = {
						settings = {
							showSyntaxErrors = false,
							logLevel = "error",
						},
					},
				},
				rust_analyzer = {},
				vtsls = {
					filetypes = tsserver_filetypes,
					on_attach = on_typescript_attach,
					settings = {
						vtsls = {
							tsserver = {
								globalPlugins = { vue_plugin },
							},
						},
						typescript = {
							tsserver = {
								maxTsServerMemory = 8192,
							},
						},
					},
				},

				lua_ls = {
					settings = {
						Lua = {
							completion = {
								callSnippet = "Replace",
							},
						},
					},
				},
				vue_ls = {},
			}
			local mason_servers = vim.tbl_filter(function(server_name)
				return server_name ~= "ty"
			end, vim.tbl_keys(servers or {}))
			---@type MasonLspconfigSettings
			---@diagnostic disable-next-line: missing-fields
			require("mason-lspconfig").setup({
				automatic_enable = mason_servers,
			})

			local ensure_installed = vim.deepcopy(mason_servers)
			vim.list_extend(ensure_installed, {
				"stylua", -- Used to format Lua code
				"prettierd",
				"prettier",
			})
			require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

			for server_name, config in pairs(servers) do
				vim.lsp.config(server_name, config)
			end
			vim.lsp.enable("ty")
		end,
	},

	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		keys = {
			{
				"<leader>f",
				function()
					require("conform").format({ async = true, lsp_format = "fallback" })
				end,
				mode = "",
				desc = "[F]ormat buffer",
			},
		},
		opts = {
			notify_on_error = false,
			format_on_save = function(bufnr)
				local disable_filetypes = { c = true, cpp = true }
				if disable_filetypes[vim.bo[bufnr].filetype] then
					return nil
				else
					return {
						timeout_ms = 500,
						lsp_format = "fallback",
					}
				end
			end,
			formatters_by_ft = {
				css = { "prettierd", "prettier", stop_after_first = true },
				html = { "prettierd", "prettier", stop_after_first = true },
				javascript = { "prettierd", "prettier", stop_after_first = true },
				javascriptreact = { "prettierd", "prettier", stop_after_first = true },
				json = { "prettierd", "prettier", stop_after_first = true },
				jsonc = { "prettierd", "prettier", stop_after_first = true },
				lua = { "stylua" },
				python = { "ruff_format" },
				scss = { "prettierd", "prettier", stop_after_first = true },
				toml = { "prettierd", "prettier", stop_after_first = true },
				typescript = { "prettierd", "prettier", stop_after_first = true },
				typescriptreact = { "prettierd", "prettier", stop_after_first = true },
				vue = { "prettierd", "prettier", stop_after_first = true },
				yaml = { "prettierd", "prettier", stop_after_first = true },
			},
		},
	},

	{
		"saghen/blink.cmp",
		event = "VimEnter",
		version = "1.*",
		dependencies = {
			{
				"L3MON4D3/LuaSnip",
				version = "2.*",
				build = (function()
					if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
						return
					end
					return "make install_jsregexp"
				end)(),
				dependencies = {},
				opts = {},
			},
			"folke/lazydev.nvim",
		},
		--- @module 'blink.cmp'
		--- @type blink.cmp.Config
		opts = {
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

			fuzzy = { implementation = "prefer_rust_with_warning" },

			signature = { enabled = true },
		},
	},
	{
		"folke/todo-comments.nvim",
		event = "VimEnter",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = { signs = false },
	},

	{
		"echasnovski/mini.nvim",
		config = function()
			-- Better Around/Inside textobjects
			--
			-- Examples:
			--  - va)  - [V]isually select [A]round [)]paren
			--  - yinq - [Y]ank [I]nside [N]ext [Q]uote
			--  - ci'  - [C]hange [I]nside [']quote
			require("mini.ai").setup({ n_lines = 500 })

			-- Add/delete/replace surroundings (brackets, quotes, etc.)
			--
			-- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
			-- - sd'   - [S]urround [D]elete [']quotes
			-- - sr)'  - [S]urround [R]eplace [)] [']
			require("mini.surround").setup()

			-- Simple and easy statusline.
			--  You could remove this setup call if you don't like it,
			--  and try some other statusline plugin
			local statusline = require("mini.statusline")
			local function python_root()
				if vim.bo.filetype ~= "python" then
					return ""
				end

				local clients = vim.lsp.get_clients({ bufnr = 0, name = "ty" })
				local client = clients[1]
				if not client then
					return ""
				end

				local root = client.workspace_folders
					and client.workspace_folders[1]
					and client.workspace_folders[1].name
				if not root or root == "" then
					root = vim.fn.getcwd()
				end

				return "pyroot:" .. vim.fs.basename(root)
			end
			-- set use_icons to true if you have a Nerd Font
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

						local tm = require("custom.terminal_manager")

						if #tm.get_active_terminals() > 0 then
							local open_terminals = tm.get_terminals_info()

							for _, term in pairs(open_terminals) do
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
			---@diagnostic disable-next-line: duplicate-set-field
			statusline.section_location = function()
				return "%2l:%-2v"
			end
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false,
		branch = "main",
		build = ":TSUpdate",
		config = function()
			local parsers = {
				"bash",
				"c",
				"css",
				"diff",
				"html",
				"javascript",
				"json",
				"lua",
				"luadoc",
				"markdown",
				"markdown_inline",
				"python",
				"query",
				"scss",
				"sql",
				"toml",
				"tsx",
				"typescript",
				"vim",
				"vimdoc",
				"vue",
				"yaml",
			}

			local installed_parsers = require("nvim-treesitter").get_installed("parsers")
			local missing_parsers = vim.iter(parsers)
				:filter(function(parser)
					return not vim.tbl_contains(installed_parsers, parser)
				end)
				:totable()

			if #missing_parsers > 0 then
				require("nvim-treesitter").install(missing_parsers)
			end

			---@param buf integer
			---@param language string
			local function treesitter_try_attach(buf, language)
				if not vim.treesitter.language.add(language) then
					return
				end

				pcall(vim.treesitter.start, buf, language)

				local has_indent_query = vim.treesitter.query.get(language, "indent") ~= nil
				if has_indent_query and language ~= "ruby" then
					vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end
			end

			local available_parsers = require("nvim-treesitter").get_available()
			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("kickstart-treesitter-attach", { clear = true }),
				callback = function(args)
					local buf, filetype = args.buf, args.match
					local language = vim.treesitter.language.get_lang(filetype)
					if not language then
						return
					end

					local installed_parsers = require("nvim-treesitter").get_installed("parsers")

					if vim.tbl_contains(installed_parsers, language) then
						treesitter_try_attach(buf, language)
					elseif vim.tbl_contains(available_parsers, language) then
						require("nvim-treesitter").install(language):await(function()
							treesitter_try_attach(buf, language)
						end)
					else
						treesitter_try_attach(buf, language)
					end
				end,
			})
		end,
	},

	-- require 'kickstart.plugins.debug',
	require("kickstart.plugins.lint"),
	require("kickstart.plugins.autopairs"),
	require("kickstart.plugins.neo-tree"),
	require("kickstart.plugins.gitsigns"),

	{ import = "custom.plugins" },
}, {
	ui = {
		icons = vim.g.have_nerd_font and {} or {
			cmd = "⌘",
			config = "🛠",
			event = "📅",
			ft = "📂",
			init = "⚙",
			keys = "🗝",
			plugin = "🔌",
			runtime = "💻",
			require = "🌙",
			source = "📄",
			start = "🚀",
			task = "📌",
			lazy = "💤 ",
		},
	},
})

require("custom.terminal_manager").setup()
