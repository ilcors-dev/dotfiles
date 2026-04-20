require("nvim-autopairs").setup({})

local function js_formatters(bufnr)
	local conform = require("conform")
	local formatters = { "eslint_d" }

	if conform.get_formatter_info("prettierd", bufnr).available then
		table.insert(formatters, "prettierd")
	elseif conform.get_formatter_info("prettier", bufnr).available then
		table.insert(formatters, "prettier")
	end

	return formatters
end

require("conform").setup({
	notify_on_error = false,
	format_on_save = function(bufnr)
		local disable_filetypes = { c = true, cpp = true }
		if disable_filetypes[vim.bo[bufnr].filetype] then
			return nil
		end

		return {
			timeout_ms = 500,
			lsp_format = "fallback",
		}
	end,
	formatters_by_ft = {
		css = { "prettierd", "prettier", stop_after_first = true },
		html = { "prettierd", "prettier", stop_after_first = true },
		javascript = js_formatters,
		javascriptreact = js_formatters,
		json = { "prettierd", "prettier", stop_after_first = true },
		jsonc = { "prettierd", "prettier", stop_after_first = true },
		lua = { "stylua" },
		python = { "ruff_format" },
		scss = { "prettierd", "prettier", stop_after_first = true },
		toml = { "prettierd", "prettier", stop_after_first = true },
		typescript = js_formatters,
		typescriptreact = js_formatters,
		vue = js_formatters,
		yaml = { "prettierd", "prettier", stop_after_first = true },
	},
})

vim.keymap.set({ "n", "v" }, "<leader>f", function()
	require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "[F]ormat buffer" })

local lint = require("lint")

local eslint_root_markers = {
	"eslint.config.js",
	"eslint.config.cjs",
	"eslint.config.mjs",
	"eslint.config.ts",
	"eslint.config.cts",
	"eslint.config.mts",
	".eslintrc",
	".eslintrc.js",
	".eslintrc.cjs",
	".eslintrc.json",
	"package.json",
}

local eslint_filetypes = {
	javascript = true,
	javascriptreact = true,
	typescript = true,
	typescriptreact = true,
	vue = true,
}

for _, linter_name in ipairs({ "eslint", "eslint_d" }) do
	local linter = lint.linters[linter_name]
	if linter then
		linter.ignore_exitcode = true
	end
end

lint.linters_by_ft = {
	javascript = { "eslint_d" },
	javascriptreact = { "eslint_d" },
	markdown = { "markdownlint" },
	python = { "ruff" },
	typescript = { "eslint_d" },
	typescriptreact = { "eslint_d" },
	vue = { "eslint_d" },
}

local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
	group = lint_augroup,
	callback = function(args)
		if vim.bo[args.buf].modifiable and not vim.b[args.buf].disable_lint then
			local opts = { bufnr = args.buf }
			local filetype = vim.bo[args.buf].filetype
			if eslint_filetypes[filetype] then
				local bufname = vim.api.nvim_buf_get_name(args.buf)
				opts.cwd = vim.fs.root(bufname, eslint_root_markers) or vim.fn.getcwd()
			end
			lint.try_lint(nil, opts)
		end
	end,
})
