return {
	"mfussenegger/nvim-dap",
	config = function(_, _)
		local dap = require("dap")
		dap.adapters.lldb = {
			type = "executable",
			command = "/usr/local/opt/llvm@18/bin/lldb-dap",
			name = "lldb",
		}
		dap.adapters.codelldb = {
			type = "executable",
			command = "/usr/local/opt/llvm@18/bin/lldb-dap",
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
	end,
}
