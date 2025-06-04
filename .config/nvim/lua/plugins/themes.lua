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
		-- lazy = false,
		-- priority = 1000,
		opts = {},
	},
	{
		"olimorris/onedarkpro.nvim",
		lazy = false,
		priority = 1000,
		build = "make extras",
		opts = {
			colors = {
				vaporwave = {
					codeblock = "require('onedarkpro.helpers').lighten('bg', 2, 'vaporwave')",
					statusline_bg = "require('onedarkpro.helpers').lighten('bg', 4, 'vaporwave')", -- gray
					statuscolumn_border = "require('onedarkpro.helpers').lighten('bg', 4, 'vaporwave')", -- gray
					ellipsis = "require('onedarkpro.helpers').lighten('bg', 4, 'vaporwave')", -- gray
					picker_results = "require('onedarkpro.helpers').darken('bg', 4, 'vaporwave')",
					picker_selection = "require('onedarkpro.helpers').darken('bg', 8, 'vaporwave')",
					copilot = "require('onedarkpro.helpers').darken('gray', 8, 'vaporwave')",
					breadcrumbs = "require('onedarkpro.helpers').darken('gray', 10, 'vaporwave')",
					light_gray = "require('onedarkpro.helpers').darken('gray', 7, 'vaporwave')",
				},
				onedark = {
					codeblock = "require('onedarkpro.helpers').lighten('bg', 2, 'onedark')",
					statusline_bg = "#2e323b", -- gray
					statuscolumn_border = "#4b5160", -- gray
					ellipsis = "#808080", -- gray
					picker_results = "require('onedarkpro.helpers').darken('bg', 4, 'onedark')",
					picker_selection = "require('onedarkpro.helpers').darken('bg', 8, 'onedark')",
					copilot = "require('onedarkpro.helpers').darken('gray', 8, 'onedark')",
					breadcrumbs = "require('onedarkpro.helpers').darken('gray', 10, 'onedark')",
					light_gray = "require('onedarkpro.helpers').darken('gray', 7, 'onedark')",
				},
				light = {
					codeblock = "require('onedarkpro.helpers').darken('bg', 3, 'onelight')",
					comment = "#bebebe", -- Revert back to original comment colors
					statusline_bg = "#f0f0f0", -- gray
					statuscolumn_border = "#e7e7e7", -- gray
					ellipsis = "#808080", -- gray
					git_add = "require('onedarkpro.helpers').get_preloaded_colors('onelight').green",
					git_change = "require('onedarkpro.helpers').get_preloaded_colors('onelight').yellow",
					git_delete = "require('onedarkpro.helpers').get_preloaded_colors('onelight').red",
					picker_results = "require('onedarkpro.helpers').darken('bg', 5, 'onelight')",
					picker_selection = "require('onedarkpro.helpers').darken('bg', 9, 'onelight')",
					copilot = "require('onedarkpro.helpers').lighten('gray', 8, 'onelight')",
					breadcrumbs = "require('onedarkpro.helpers').lighten('gray', 8, 'onelight')",
					light_gray = "require('onedarkpro.helpers').lighten('gray', 10, 'onelight')",
				},
				rainbow = {
					"${green}",
					"${blue}",
					"${purple}",
					"${red}",
					"${orange}",
					"${yellow}",
					"${cyan}",
				},
			},
			highlights = {
				CodeCompanionTokens = { fg = "${gray}", italic = true },
				CodeCompanionVirtualText = { fg = "${gray}", italic = true },

				["@markup.raw.block.markdown"] = { bg = "${codeblock}" },
				["@markup.quote.markdown"] = { italic = true, extend = true },

				EdgyNormal = { bg = "${bg}" },
				EdgyTitle = { fg = "${purple}", bold = true },

				EyelinerPrimary = { fg = "${green}" },
				EyelinerSecondary = { fg = "${blue}" },

				NormalFloat = { bg = "${bg}" }, -- Set the terminal background to be the same as the editor
				FloatBorder = { fg = "${gray}", bg = "${bg}" },

				CursorLineNr = { bg = "${bg}", fg = "${fg}", italic = true },
				MatchParen = { fg = "${cyan}" },
				ModeMsg = { fg = "${gray}" }, -- Make command line text lighter
				Search = { bg = "${selection}", fg = "${yellow}", underline = true },
				VimLogo = { fg = { dark = "#81b766", light = "#029632" } },

				-- DAP
				DebugBreakpoint = { fg = "${red}", italic = true },
				DebugHighlightLine = { fg = "${purple}", italic = true },
				NvimDapVirtualText = { fg = "${cyan}", italic = true },

				-- DAP UI
				DapUIBreakpointsCurrentLine = { fg = "${yellow}", bold = true },

				-- Luasnip
				LuaSnipChoiceNode = { fg = "${yellow}" },
				LuaSnipInsertNode = { fg = "${yellow}" },

				-- Neotest
				NeotestAdapterName = { fg = "${purple}", bold = true },
				NeotestFocused = { bold = true },
				NeotestNamespace = { fg = "${blue}", bold = true },

				-- Virt Column
				VirtColumn = { fg = "${indentline}" },
			},

			caching = false,
			cache_path = vim.fn.expand(vim.fn.stdpath("cache") .. "/onedarkpro_dotfiles"),

			plugins = {
				barbar = false,
				lsp_saga = false,
				marks = false,
				polygot = false,
				startify = false,
				telescope = false,
				trouble = false,
				vim_ultest = false,
				which_key = false,
			},
			styles = {
				tags = "italic",
				methods = "bold",
				functions = "bold",
				keywords = "italic",
				comments = "italic",
				parameters = "italic",
				conditionals = "italic",
				virtual_text = "italic",
			},
			options = {
				cursorline = true,
				-- transparency = true,
				-- highlight_inactive_windows = true,
			},
		},
	},
}
