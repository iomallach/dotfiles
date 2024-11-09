return {
	"ibhagwan/fzf-lua",
	event = "VimEnter",
	init = function()
		local keymap = require("vim.keymap")
		keymap.set("n", "<leader>fg", "<CMD>FzfLua live_grep<CR>", { desc = "Fzf Live Grep" })
		keymap.set(
			"n",
			"<leader>fws",
			"<CMD>FzfLua lsp_live_workspace_symbols<CR>",
			{ desc = "Fzf Live Workspace symbols" }
		)
		keymap.set("n", "<leader>fb", "<CMD>FzfLua buffers<CR>", { desc = "Fzf Buffers" })
		keymap.set("n", "<leader>ff", "<CMD>FzfLua files<CR>", { desc = "Fzf Files" })
	end,
}
