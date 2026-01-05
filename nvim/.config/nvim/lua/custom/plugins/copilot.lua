return {
	"github/copilot.vim",
	cond = true,
	config = function()
		vim.g.copilot_no_maps = true
		vim.g.copilot_no_tab_map = true

		vim.api.nvim_create_user_command("CopilotToggle", function()
			if vim.b.copilot_enabled == 1 then
				vim.cmd("Copilot disable")
				print("Copilot disabled for this buffer")
			else
				vim.cmd("Copilot enable")
				print("Copilot enabled for this buffer")
			end
		end, { desc = "Toggle Copilot for current buffer" })

		vim.keymap.set("n", "<leader>ct", "<cmd>CopilotToggle<CR>", { desc = "Toggle Copilot" })
		vim.keymap.set("i", "<C-y>", 'copilot#Accept("\\<CR>")', {
			expr = true,
			replace_keycodes = false,
			desc = "Accept Copilot suggestion",
		})
	end,
}
