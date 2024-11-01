return {
	{
		"mrcjkb/haskell-tools.nvim",
		version = "^3", -- Recommended
		ft = { "haskell", "lhaskell", "cabal", "cabalproject" },
	},
	{
		"rust-lang/rust.vim",
		ft = "rust",
		init = function()
			vim.g.rustfmt_autosave = 1
		end,
	},
	{
		"mrcjkb/rustaceanvim",
		version = "^4",
		ft = { "rust" },
		dependencies = {
			{
				"lvimuser/lsp-inlayhints.nvim",
				opts = {},
			},
			"nvim-lua/plenary.nvim",
			"mfussenegger/nvim-dap",
		},
		config = function()
			vim.g.rustaceanvim = {
				tools = {
					hover_actions = {
						auto_focus = true,
					},
				},
				server = {
					on_attach = function(client, bufnr)
						require("lsp-inlayhints").on_attach(client, bufnr)
						local map = vim.keymap.set

						-- Inlayhints mappings
						map("n", "<leader>lht", function()
							require("lsp-inlayhints").toggle()
						end, { desc = "Toggle inlayhints" })

						map("n", "<leader>lhr", function()
							require("lsp-inlayhints").reset()
						end, { desc = "Reset inlayhints" })
					end,
				},
			}
		end,
	},
	{
		"maxandron/goplements.nvim",
		ft = "go",
		opts = {
			-- your configuration comes here
			-- or leave it empty to use the default settings
			-- refer to the configuration section below
		},
	},
	-- { "nvim-java/nvim-java" },
	{
		"nvim-neotest/neotest",
		event = "VeryLazy",
		ft = { "go" },
		dependencies = {
			"nvim-neotest/nvim-nio",
			"nvim-lua/plenary.nvim",
			"antoinemadec/FixCursorHold.nvim",
			"nvim-treesitter/nvim-treesitter",
			-- Language adapters
			"fredrikaverpil/neotest-golang",
		},
		config = function()
			require("neotest").setup({
				adapters = {
					require("neotest-golang"), -- Registration
				},
			})
			require("config.neotest").setup_keymaps()
		end,
	},
	{
		"iomallach/poetry.nvim",
		ft = { "python" },
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		config = function()
			require("poetry").setup_user_command()
		end,
	},
	{
		"nvim-java/nvim-java",
		dependencies = {
			"ibhagwan/fzf-lua",
		},
	},
}
