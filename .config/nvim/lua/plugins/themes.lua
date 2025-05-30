return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		-- lazy = false,
		-- priority = 1000,
		opts = {
			integrations = {
				cmp = true,
				gitsigns = true,
				headlines = true,
				markdown = true,
				noice = true,
				neotest = true,
				flash = true,
				illuminate = true,
				notify = true,
				mason = true,
				treesitter = true,
				which_key = true,
				fzf = true,
				blink_cmp = true,
			},
		},
	},
	{
		"NTBBloodbath/doom-one.nvim",
		-- priority = 1000,
		-- lazy = false,
		setup = function()
			-- Add color to cursor
			vim.g.doom_one_cursor_coloring = true
			-- Set :terminal colors
			vim.g.doom_one_terminal_colors = true
			-- Enable italic comments
			vim.g.doom_one_italic_comments = true
			-- Enable TS support
			vim.g.doom_one_enable_treesitter = true
			-- Color whole diagnostic text or only underline
			vim.g.doom_one_diagnostics_text_color = false
			-- Enable transparent background
			vim.g.doom_one_transparent_background = false

			-- Pumblend transparency
			vim.g.doom_one_pumblend_enable = false
			vim.g.doom_one_pumblend_transparency = 20

			-- Plugins integration
			vim.g.doom_one_plugin_neorg = true
			vim.g.doom_one_plugin_barbar = false
			vim.g.doom_one_plugin_telescope = true
			vim.g.doom_one_plugin_neogit = true
			vim.g.doom_one_plugin_nvim_tree = true
			vim.g.doom_one_plugin_dashboard = true
			vim.g.doom_one_plugin_startify = true
			vim.g.doom_one_plugin_whichkey = true
			vim.g.doom_one_plugin_indent_blankline = true
			vim.g.doom_one_plugin_vim_illuminate = true
			vim.g.doom_one_plugin_lspsaga = true
		end,
		config = function()
			vim.cmd("colorscheme doom-one")
		end,
	},
	{
		"sainnhe/everforest",
		-- priority = 1000,
		config = function()
			vim.o.background = "dark" -- or "light" for light mode
			vim.cmd([[colorscheme everforest]])
		end,
	},
	{
		"ellisonleao/gruvbox.nvim",
		-- priority = 1000,
		config = function()
			vim.o.background = "dark" -- or "light" for light mode
			vim.cmd([[colorscheme gruvbox]])
		end,
	},
	{
		"eldritch-theme/eldritch.nvim",
		lazy = false,
		priority = 1000,
		opts = {},
	},
}
