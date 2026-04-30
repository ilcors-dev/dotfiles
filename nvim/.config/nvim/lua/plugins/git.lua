local function system(args, opts, callback)
	vim.system(args, opts, function(result)
		vim.schedule(function()
			callback(result)
		end)
	end)
end

local function git_root(callback)
	local path = vim.api.nvim_buf_get_name(0)
	local cwd = path ~= "" and vim.fn.fnamemodify(path, ":h") or vim.fn.getcwd()

	system({ "git", "rev-parse", "--show-toplevel" }, { cwd = cwd, text = true }, function(result)
		if result.code ~= 0 then
			vim.notify("Current buffer is not inside a git repository", vim.log.levels.WARN, { title = "Git" })
			return
		end

		callback(vim.trim(result.stdout))
	end)
end

local function current_tracked_file(callback)
	local path = vim.api.nvim_buf_get_name(0)
	if path == "" then
		vim.notify("Current buffer has no file path", vim.log.levels.WARN, { title = "Git" })
		return
	end

	local path_dir = vim.fn.fnamemodify(path, ":h")
	system({ "git", "rev-parse", "--show-toplevel" }, { cwd = path_dir, text = true }, function(root_result)
		if root_result.code ~= 0 then
			vim.notify("Current file is not inside a git repository", vim.log.levels.WARN, { title = "Git" })
			return
		end

		local root = vim.trim(root_result.stdout)
		local relpath = vim.fs.relpath(root, path) or path
		system({ "git", "ls-files", "--full-name", "--", relpath }, { cwd = root, text = true }, function(file_result)
			if file_result.code ~= 0 or vim.trim(file_result.stdout) == "" then
				vim.notify("Current file is not tracked by git", vim.log.levels.WARN, { title = "Git" })
				return
			end

			callback(root, vim.trim(file_result.stdout))
		end)
	end)
end

local function open_commit_on_github(picker, item)
	if not item or not item.commit then
		vim.notify("No commit selected", vim.log.levels.WARN, { title = "GitHub" })
		return
	end

	picker:close()
	system({ "gh", "browse", item.commit }, { cwd = item.cwd or picker:cwd(), text = true }, function(result)
		if result.code ~= 0 then
			vim.notify(
				vim.trim(result.stderr ~= "" and result.stderr or "Could not open commit on GitHub"),
				vim.log.levels.ERROR,
				{ title = "GitHub" }
			)
		end
	end)
end

local function pick_commits_by_author(root, author)
	if not author or author == "" then
		vim.notify("No author selected", vim.log.levels.WARN, { title = "Git" })
		return
	end

	Snacks.picker.git_log({
		author = author,
		cwd = root,
		confirm = open_commit_on_github,
	})
end

local function current_line_author(callback)
	current_tracked_file(function(root, file)
		local line = vim.api.nvim_win_get_cursor(0)[1]
		system({ "git", "blame", "-L", line .. "," .. line, "--porcelain", "--", file }, { cwd = root, text = true }, function(blame_result)
			if blame_result.code ~= 0 then
				vim.notify("Could not blame current line", vim.log.levels.ERROR, { title = "Git" })
				return
			end

			local author = blame_result.stdout:match("\nauthor ([^\n]+)")
			local mail = blame_result.stdout:match("\nauthor%-mail <([^>]+)>")
			if not author then
				vim.notify("No author found for current line", vim.log.levels.WARN, { title = "Git" })
				return
			end

			callback(root, mail and (author .. " <" .. mail .. ">") or author)
		end)
	end)
end

local function current_line_commit(callback)
	current_tracked_file(function(root, file)
		local line = vim.api.nvim_win_get_cursor(0)[1]
		system({ "git", "blame", "-L", line .. "," .. line, "--porcelain", "--", file }, { cwd = root, text = true }, function(blame_result)
			if blame_result.code ~= 0 then
				vim.notify("Could not blame current line", vim.log.levels.ERROR, { title = "GitHub" })
				return
			end

			local sha = blame_result.stdout:match("^(%x+)")
			if not sha then
				vim.notify("Could not find a commit for current line", vim.log.levels.WARN, { title = "GitHub" })
				return
			end

			if sha:match("^0+$") then
				vim.notify("Current line is uncommitted", vim.log.levels.WARN, { title = "GitHub" })
				return
			end

			callback(root, sha)
		end)
	end)
end

local function pick_author()
	git_root(function(root)
		system({ "git", "log", "--all", "--format=%an <%ae>" }, { cwd = root, text = true }, function(author_result)
			if author_result.code ~= 0 then
				vim.notify("Could not list git authors", vim.log.levels.ERROR, { title = "Git" })
				return
			end

			local authors = {}
			local by_email = {}
			for author in author_result.stdout:gmatch("[^\n]+") do
				if author ~= "" and not authors[author] then
					authors[author] = { author = author }
					local email = author:match("<([^>]+)>")
					if email then
						by_email[email:lower()] = author
					end
				end
			end

			system({
				"gh",
				"api",
				"repos/{owner}/{repo}/collaborators",
				"--paginate",
				"--jq",
				".[] | [.login, .name, .email] | @tsv",
			}, { cwd = root, text = true }, function(collaborator_result)
				if collaborator_result.code == 0 then
					for line in collaborator_result.stdout:gmatch("[^\n]+") do
						local login, name, email = line:match("([^\t]*)\t([^\t]*)\t([^\t]*)")
						local author = email and by_email[email:lower()] or nil
						if author then
							authors[author].login = login ~= "" and login or nil
						elseif name and name ~= "" then
							for existing, item in pairs(authors) do
								if existing:lower():find(name:lower(), 1, true) then
									item.login = login ~= "" and login or nil
									break
								end
							end
						end
					end
				end

				local items = vim.tbl_values(authors)
				if #items == 0 then
					vim.notify("No git authors found", vim.log.levels.WARN, { title = "Git" })
					return
				end

				table.sort(items, function(a, b)
					return a.author:lower() < b.author:lower()
				end)

				vim.ui.select(items, {
					prompt = "Git author:",
					format_item = function(item)
						return item.login and (item.author .. "  @" .. item.login) or item.author
					end,
				}, function(item)
					if item then
						pick_commits_by_author(root, item.author)
					end
				end)
			end)
		end)
	end)
end

local function open_line_commit()
	current_line_commit(function(root, sha)
		system({ "gh", "browse", sha }, { cwd = root, text = true }, function(result)
			if result.code ~= 0 then
				vim.notify(
					vim.trim(result.stderr ~= "" and result.stderr or "Could not open commit on GitHub"),
					vim.log.levels.ERROR,
					{ title = "GitHub" }
				)
			end
		end)
	end)
end

local function open_line_pr()
	current_line_commit(function(root, sha)
		system({
			"gh",
			"pr",
			"list",
			"--search",
			sha,
			"--state",
			"merged",
			"--json",
			"url",
			"--jq",
			".[0].url",
		}, { cwd = root, text = true }, function(result)
			if result.code ~= 0 then
				vim.notify(
					vim.trim(result.stderr ~= "" and result.stderr or "Could not search GitHub PRs"),
					vim.log.levels.ERROR,
					{ title = "GitHub" }
				)
				return
			end

			local url = vim.trim(result.stdout)
			if url == "" then
				vim.notify("No PR found for commit " .. sha:sub(1, 8), vim.log.levels.WARN, { title = "GitHub" })
				return
			end

			vim.ui.open(url)
		end)
	end)
end

vim.keymap.set("n", "<leader>go", open_line_commit, { desc = "GitHub [O]pen line commit" })
vim.keymap.set("n", "<leader>gO", open_line_pr, { desc = "GitHub [O]pen line PR" })
vim.keymap.set("n", "<leader>ga", pick_author, { desc = "Git commits by [A]uthor" })
vim.keymap.set("n", "<leader>gA", function()
	current_line_author(function(root, author)
		pick_commits_by_author(root, author)
	end)
end, { desc = "Git commits by line [A]uthor" })

require("gitsigns").setup({
	signs = {
		add = { text = "+" },
		change = { text = "~" },
		delete = { text = "_" },
		topdelete = { text = "‾" },
		changedelete = { text = "~" },
	},
	on_attach = function(bufnr)
		local gitsigns = require("gitsigns")

		local function map(mode, lhs, rhs, opts)
			opts = opts or {}
			opts.buffer = bufnr
			vim.keymap.set(mode, lhs, rhs, opts)
		end

		map("n", "]c", function()
			if vim.wo.diff then
				vim.cmd.normal({ "]c", bang = true })
			else
				gitsigns.nav_hunk("next")
			end
		end, { desc = "Jump to next git [c]hange" })

		map("n", "[c", function()
			if vim.wo.diff then
				vim.cmd.normal({ "[c", bang = true })
			else
				gitsigns.nav_hunk("prev")
			end
		end, { desc = "Jump to previous git [c]hange" })

		map("v", "<leader>hs", function()
			gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
		end, { desc = "git [s]tage hunk" })
		map("v", "<leader>hr", function()
			gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
		end, { desc = "git [r]eset hunk" })
		map("n", "<leader>hs", gitsigns.stage_hunk, { desc = "git [s]tage hunk" })
		map("n", "<leader>hr", gitsigns.reset_hunk, { desc = "git [r]eset hunk" })
		map("n", "<leader>hS", gitsigns.stage_buffer, { desc = "git [S]tage buffer" })
		map("n", "<leader>hu", gitsigns.stage_hunk, { desc = "git [u]ndo stage hunk" })
		map("n", "<leader>hR", gitsigns.reset_buffer, { desc = "git [R]eset buffer" })
		map("n", "<leader>hp", gitsigns.preview_hunk, { desc = "git [p]review hunk" })
		map("n", "<leader>hb", gitsigns.blame_line, { desc = "git [b]lame line" })
		map("n", "<leader>hd", gitsigns.diffthis, { desc = "git [d]iff against index" })
		map("n", "<leader>hD", function()
			gitsigns.diffthis("@")
		end, { desc = "git [D]iff against last commit" })
		map("n", "<leader>tb", gitsigns.toggle_current_line_blame, { desc = "[T]oggle git show [b]lame line" })
		map("n", "<leader>tD", gitsigns.preview_hunk_inline, { desc = "[T]oggle git show [D]eleted" })
	end,
})
