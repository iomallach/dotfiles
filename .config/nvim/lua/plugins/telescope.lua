local options = function()
	return {
		defaults = {
			prompt_prefix = "   ",
			file_ignore_patterns = { "node_modules" },
			path_display = { "truncate" },
			-- Developer configurations: Not meant for general override
			mappings = {
				n = { ["q"] = require("telescope.actions").close },
				i = {
					["<C-j>"] = require("telescope.actions").move_selection_next,
					["<C-k>"] = require("telescope.actions").move_selection_previous,
				},
			},
		},
		extensions_list = { "themes", "fzf", "ui-select" },
		extensions = {
			fzf = {
				fuzzy = true,
				override_generic_sorter = true,
				override_file_sorter = true,
				case_mode = "smart_case",
			},
			["ui-select"] = {
				require("telescope.themes").get_dropdown(),
			},
		},
	}
end

return {
	"nvim-telescope/telescope.nvim",
	branch = "0.1.x",
	event = "VimEnter",
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"nvim-lua/plenary.nvim",
		"andrew-george/telescope-themes",
		{
			"nvim-telescope/telescope-fzf-native.nvim",
			build = "make",
			cond = function()
				return vim.fn.executable("make") == 1
			end,
		},
		{ "nvim-telescope/telescope-ui-select.nvim" },
		{ "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
	},
	cmd = "Telescope",
	init = function()
		local keymap = require("vim.keymap")
		keymap.set("n", "<leader>ff", "<CMD>Telescope find_files<CR>", { desc = "Telescope Find Files" })
		keymap.set("n", "<leader>fg", "<CMD>Telescope live_grep<CR>", { desc = "Telescope Live Grep" })
		keymap.set("n", "<leader>fb", "<CMD>Telescope buffers<CR>", { desc = "Telescope Find Buffers" })
		keymap.set("n", "<leader>fa", "<CMD>Telescope <CR>", { desc = "Telescope Find All" })
		keymap.set(
			"n",
			"<leader>fz",
			"<CMD>Telescope current_buffer_fuzzy_find<CR>",
			{ desc = "Telescope Find in Buffer" }
		)
		keymap.set("n", "<leader>fd", "<CMD>Telescope diagnostics<CR>", { desc = "Telescope Find Diagnostics" })
		keymap.set("n", "<leader>fh", "<CMD>Telescope command_history<CR>", { desc = "Telescope Command History" })
		keymap.set(
			"n",
			"<leader>fs",
			"<CMD>Telescope lsp_document_symbols<CR>",
			{ desc = "Telescope Document Symbols" }
		)
		keymap.set(
			"n",
			"<leader>fws",
			"<CMD>Telescope lsp_workspace_symbols<CR>",
			{ desc = "Telescope Document Symbols" }
		)
		keymap.set("n", "<leader>fr", "<CMD>Telescope lsp_references<CR>", { desc = "Telescope Find References" })
		keymap.set("n", "<leader>ft", "<CMD>Telescope help_tags<CR>", { desc = "Telescope Find References" })
	end,
	config = function()
		local telescope = require("telescope")
		local opts = options()
		telescope.setup(opts)
		-- load extensions
		for _, ext in ipairs(opts.extensions_list) do
			telescope.load_extension(ext)
		end
	end,
}
