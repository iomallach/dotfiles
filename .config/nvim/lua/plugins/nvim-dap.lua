return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "rcarriga/nvim-dap-ui",
    "theHamsta/nvim-dap-virtual-text",
  },
  config = function(_, _)
    local dap = require("dap")
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

    -- Keymaps
    vim.keymap.set("n", "<F1>", dap.continue)
    vim.keymap.set("n", "<F2>", dap.step_into)
    vim.keymap.set("n", "<F3>", dap.step_over)
    vim.keymap.set("n", "<F4>", dap.step_out)
    vim.keymap.set("n", "<F5>", dap.step_back)
    vim.keymap.set("n", "<F11>", dap.restart)
    vim.keymap.set("n", "<F12>", dap.terminate)
  end,
}
