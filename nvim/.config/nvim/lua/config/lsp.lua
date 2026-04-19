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
	group = vim.api.nvim_create_augroup("nvim-lsp-attach", { clear = true }),
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
		if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
			local highlight_augroup = vim.api.nvim_create_augroup("nvim-lsp-highlight", { clear = false })
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
				group = vim.api.nvim_create_augroup("nvim-lsp-detach", { clear = true }),
				callback = function(event2)
					vim.lsp.buf.clear_references()
					vim.api.nvim_clear_autocmds({ group = "nvim-lsp-highlight", buffer = event2.buf })
				end,
			})
		end

		if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
			map("<leader>th", function()
				vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
			end, "[T]oggle Inlay [H]ints")
		end
	end,
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

require("mason").setup({})

local mason_servers = vim.tbl_filter(function(server_name)
	return server_name ~= "ty"
end, vim.tbl_keys(servers))

require("mason-lspconfig").setup({
	automatic_enable = mason_servers,
})

local ensure_installed = vim.deepcopy(mason_servers)
vim.list_extend(ensure_installed, {
	"stylua",
	"prettierd",
	"prettier",
})

require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

for server_name, config in pairs(servers) do
	vim.lsp.config(server_name, config)
end

vim.lsp.enable("ty")
