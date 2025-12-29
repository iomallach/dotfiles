return {
	{
		"mfussenegger/nvim-dap-python",
		ft = "python",
		dependencies = {
			"mfussenegger/nvim-dap",
		},
		config = function()
			local path = "~/.local/share/nvim/mason/packages/debugpy/venv/bin/python"
			require("dap-python").setup(path)
		end,
	},
	{
		"leoluz/nvim-dap-go",
		event = "VeryLazy",
		config = function()
			require("dap-go").setup({
				dap_configurations = {
					{
						-- Must be "go" or it will be ignored by the plugin
						type = "go",
						name = "Attach remote",
						mode = "remote",
						request = "attach",
					},
					{
						type = "go",
						name = "Debug (Build Flags)",
						request = "launch",
						program = "${file}",
						buildFlags = require("dap-go").get_build_flags,
					},
				},
			})
		end,
	},
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"theHamsta/nvim-dap-virtual-text",
      "leoluz/nvim-dap-go",
      "igorlfs/nvim-dap-view",
		},
		config = function(_, _)
			local dap = require("dap")

			-- Enable verbose logging
			dap.set_log_level('TRACE')

			dap.adapters.lldb = {
				type = "executable",
				command = "/opt/homebrew/opt/llvm/bin/lldb-dap",
				name = "lldb",
			}
			dap.adapters.codelldb = {
				type = "executable",
				command = "/opt/homebrew/opt/llvm/bin/lldb-dap",
				name = "codelldb",
			}
			dap.configurations.c = {
				{
					name = "Launch",
					type = "lldb",
					request = "launch",
					program = function()
						return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
					end,
					cwd = "${workspaceFolder}",
					stopOnEntry = false,
					args = function()
						local argument_string = vim.fn.input("Program arguments: ")
						return vim.fn.split(argument_string, " ", true)
					end,
				},
			}

			require("nvim-dap-virtual-text").setup()

			-- Keymaps
			vim.keymap.set("n", "<leader>dc", dap.continue)
			vim.keymap.set("n", "<leader>di", dap.step_into)
			vim.keymap.set("n", "<leader>do", dap.step_over)
			vim.keymap.set("n", "<leader>du", dap.step_out)
			vim.keymap.set("n", "<leader>da", dap.step_back)
			vim.keymap.set("n", "<leader>de", dap.restart)
			vim.keymap.set("n", "<leader>dt", dap.terminate)
			vim.keymap.set("n", "<leader>dr", dap.repl.open)
		end,
	},
}
