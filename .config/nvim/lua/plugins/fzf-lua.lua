return {
	"ibhagwan/fzf-lua",
	event = "VimEnter",
	dependencies = {
		"elanmed/fzf-lua-frecency.nvim",
	},
	init = function()
		local keymap = require("vim.keymap")
		keymap.set("n", "<leader>fg", "<CMD>FzfLua live_grep<CR>", { desc = "Fzf Live Grep" })
		keymap.set("n", "<leader>fG", "<CMD>FzfLua global<CR>", { desc = "Fzf Live Grep" })
		keymap.set(
			"n",
			"<leader>fws",
			"<CMD>FzfLua lsp_live_workspace_symbols<CR>",
			{ desc = "Fzf Live Workspace symbols" }
		)
		keymap.set("n", "<leader>fb", "<CMD>FzfLua buffers<CR>", { desc = "Fzf Buffers" })
		keymap.set("n", "<leader>ff", function()
			require("fzf-lua-frecency").frecency({
				cwd_only = true,
			})
		end, { desc = "Fzf Frecent Files" })
		keymap.set("n", "<leader>fo", function()
			require("fzf-lua").oldfiles({
				cwd_only = true,
				stat_file = true, -- verify files exist on disk
			})
		end, { desc = "Fzf Old Files" })
		keymap.set("n", "<leader>fs", "<CMD>FzfLua lsp_document_symbols<CR>", { desc = "Fzf Document symbols" })
		keymap.set("n", "<leader>fr", "<CMD>FzfLua lsp_references<CR>", { desc = "Fzf References" })
		keymap.set("n", "<leader>fd", "<CMD>FzfLua diagnostics_document<CR>", { desc = "Fzf Diagnostics Document" })
		keymap.set("n", "<leader>fD", "<CMD>FzfLua diagnostics_workspace<CR>", { desc = "Fzf Diagnostics Workspace" })
		keymap.set("n", "<leader>fa", "<CMD>FzfLua<CR>", { desc = "Fzf Find All" })
		keymap.set("n", "<leader>ft", "<CMD>FzfLua helptags<CR>", { desc = "Fzf Helptags" })
		keymap.set("n", "<leader>fh", "<CMD>FzfLua command_history<CR>", { desc = "Fzf Command History" })
		keymap.set("n", "<leader>/", "<CMD>FzfLua blines<CR>", { desc = "Fzf Fuzzy find current buffer" })
		keymap.set("n", "<leader>fa", "<CMD>FzfLua<CR>", { desc = "Fzf find find fzf command" })
	end,
	config = function()
		require("fzf-lua").setup({
			keymap = {
				fzf = {
					["ctrl-q"] = "select-all+accept",
				},
			},
		})
	end,
}
