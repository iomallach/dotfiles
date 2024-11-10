return {
	{
		"ray-x/lsp_signature.nvim",
		event = "VeryLazy",
		opts = {},
		config = function(_, opts)
			require("lsp_signature").setup(opts)
		end,
	},
	{
		"glepnir/lspsaga.nvim",
		lazy = false,
		config = function()
			require("lspsaga").setup({
				-- keybinds for navigation in lspsaga window
				move_in_saga = { prev = "<C-k>", next = "<C-j>" },
				-- use enter to open file with finder
				finder_action_keys = {
					open = "<CR>",
				},
				-- use enter to open file with definition preview
				definition_action_keys = {
					edit = "<CR>",
				},
				ui = {
					code_action = "",
				},
			})
		end,
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
		},
	},
	{
		"williamboman/mason-lspconfig.nvim",
		opts = {
			ensure_installed = {
				"lua_ls",
			},
			automatic_installation = true,
		},
		event = "BufReadPre",
		dependencies = "williamboman/mason.nvim",
	},
	{
		"neovim/nvim-lspconfig",
		lazy = false,
		config = function()
			require("config.nvim-lspconfig")
		end,
	},
	{
		"folke/trouble.nvim",
		opts = {},
		cmd = "Trouble",
	},
	{
		"chrisgrieser/nvim-lsp-endhints",
		event = "LspAttach",
		config = function()
			require("lsp-endhints").setup({
				icons = {
					type = "󰜁 ",
					parameter = "󰏪 ",
					offspec = " ", -- hint kind not defined in official LSP spec
					unknown = " ", -- hint kind is nil
				},
				label = {
					padding = 1,
					marginLeft = 0,
					bracketedParameters = true,
				},
				autoEnableHints = true,
			})

			local map = vim.keymap.set
			-- inlay hints will show at the end of the line (default)
			map("n", "<leader>lhe", require("lsp-endhints").enable)
			-- inlay hints will show as if the plugin was not installed
			map("n", "<leader>lhd", require("lsp-endhints").disable)
			-- toggle between the two
			map("n", "<leader>lht", require("lsp-endhints").toggle)
		end,
	},
	-- {
	-- 	"mfussenegger/nvim-jdtls",
	-- 	dependencies = {
	-- 		"mfussenegger/nvim-dap",
	-- 		"ray-x/lsp_signature.nvim",
	-- 	},
	-- },
}
