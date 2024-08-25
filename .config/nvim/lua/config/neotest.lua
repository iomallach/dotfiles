local M = {}

local map = require("config.utils").map
local opts = require("config.utils").opts

function M.setup_keymaps()
	-- Run keymaps
	map("n", "<leader>trc", "<CMD>lua require('neotest').run.run()<CR>", opts("Run nearest test"))
	map(
		"n",
		"<leader>trf",
		"<CMD>lua require('neotest').run.run(vim.fn.expand('%'))<CR>",
		opts("Run tests in current file")
	)
	map("n", "<leader>trd", "<CMD>lua require('neotest').run.run({strategy = 'dap'})<CR>", opts("Debug nearest test"))
	map("n", "<leader>tra", "<CMD>lua require('neotest').run.attach()<CR>", opts("Attach to the nearest test"))

	-- Output keymaps
	map("n", "<leader>tow", "<CMD>lua require('neotest').output.open({enter = true})<CR>", opts("Show test output"))
	map("n", "<leader>tot", "<CMD>lua require('neotest').output_panel.toggle()<CR>", opts("Toggle output panel"))
	map("n", "<leader>toc", "<CMD>lua require('neotest').output_panel.clear()<CR>", opts("Clear output panel"))

	-- Summary keymaps
	map("n", "<leader>tst", "<CMD>lua require('neotest').summary.toggle()<CR>", opts("Toggle summary window"))
end
return M
