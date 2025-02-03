return {
	{
		"mrcjkb/haskell-tools.nvim",
		version = "^3", -- Recommended
		ft = { "haskell", "lhaskell", "cabal", "cabalproject" },
	},
	{
		"mrcjkb/rustaceanvim",
		version = "^4",
		ft = { "rust" },
		dependencies = {
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
					settings = {
						["rust-analyzer"] = {
							inlayHints = {
								bindingModeHints = {
									enable = false,
								},
								chainingHints = {
									enable = true,
								},
								closingBraceHints = {
									enable = true,
									minLines = 25,
								},
								closureReturnTypeHints = {
									enable = "never",
								},
								lifetimeElisionHints = {
									enable = "never",
									useParameterNames = false,
								},
								maxLength = 25,
								parameterHints = {
									enable = true,
								},
								reborrowHints = {
									enable = "never",
								},
								renderColons = true,
								typeHints = {
									enable = true,
									hideClosureInitialization = false,
									hideNamedConstructor = false,
								},
							},
						},
					},
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
		init = function()
			local run_and_debug = require("config.java.run_and_debug")
			vim.keymap.set("n", "<leader>Jr", run_and_debug.run_spring_boot, { desc = "[R]un spring boot application" })
			vim.keymap.set("n", "<leader>Jtc", run_and_debug.run_test_class(false), { desc = "[T]est [C]lass" })
			vim.keymap.set("n", "<leader>Jtm", run_and_debug.run_test_method(false), { desc = "[T]est [M]ethod" })

			local dap = require("dap")
			dap.configurations.java = {
				{
					type = "java",
					request = "attach",
					name = "Attach to a process",
					hostName = "localhost",
					port = "5005",
				},
			}
		end,
	},
}
