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

local nvim_treesitter = require("nvim-treesitter")
local treesitter_runtime = vim.fn.stdpath("data") .. "/site/pack/core/opt/nvim-treesitter/runtime"

if vim.fn.isdirectory(treesitter_runtime) == 1 then
	vim.opt.runtimepath:prepend(treesitter_runtime)
end

local installed_parsers = nvim_treesitter.get_installed("parsers")
local missing_parsers = vim.iter(parsers)
	:filter(function(parser)
		return not vim.tbl_contains(installed_parsers, parser)
	end)
	:totable()

if #missing_parsers > 0 then
	nvim_treesitter.install(missing_parsers)
end

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

local available_parsers = nvim_treesitter.get_available()
vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("treesitter-attach", { clear = true }),
	callback = function(args)
		local buf, filetype = args.buf, args.match
		local language = vim.treesitter.language.get_lang(filetype)
		if not language then
			return
		end

		local current_installed = nvim_treesitter.get_installed("parsers")
		if vim.tbl_contains(current_installed, language) then
			treesitter_try_attach(buf, language)
		elseif vim.tbl_contains(available_parsers, language) then
			nvim_treesitter.install(language):await(function()
				treesitter_try_attach(buf, language)
			end)
		else
			treesitter_try_attach(buf, language)
		end
	end,
})
