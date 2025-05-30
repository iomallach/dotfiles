local utils = require("config.utils")

-- Pane navigation and window navigation
utils.map("n", "<C-h>", "<C-w>h", utils.opts("Navigate left"))
utils.map("n", "<C-j>", "<C-w>j", utils.opts("Navigate down"))
utils.map("n", "<C-k>", "<C-w>k", utils.opts("Navigate up"))
utils.map("n", "<C-l>", "<C-w>l", utils.opts("Navigate right"))
utils.map("t", "<C-h>", "[[<Cmd>wincmd h<CR>") -- Navigate left
utils.map("t", "<C-j>", "[[<Cmd>wincmd j<CR>") -- Navigate down
utils.map("t", "<C-k>", "[[<Cmd>wincmd k<CR>") -- Navigate up
utils.map("t", "<C-l>", "[[<Cmd>wincmd l<CR>") -- Navigate right
utils.map("n", "<C-h>", ":TmuxNavigateLeft<CR>") -- Navigate left
utils.map("n", "<C-j>", ":TmuxNavigateDown<CR>") -- Navigate down
utils.map("n", "<C-k>", ":TmuxNavigateUp<CR>") -- Navigate up
utils.map("n", "<C-l>", ":TmuxNavigateRight<CR>") -- Navigate right

-- Insert mode movement
-- utils.map("i", "<C-b>", "<ESC>^i", { desc = "Move Beginning of line" })
-- utils.map("i", "<C-e>", "<End>", { desc = "Move End of line" })
utils.map("i", "<C-h>", "<Left>", { desc = "Move Left" })
utils.map("i", "<C-l>", "<Right>", { desc = "Move Right" })
utils.map("i", "<C-j>", "<Down>", { desc = "Move Down" })
utils.map("i", "<C-k>", "<Up>", { desc = "Move Up" })

-- Move lines up and down
utils.map("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
utils.map("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })
utils.map("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move line down" })
utils.map("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move line up" })

-- Window management
utils.map("n", "<leader>sv", ":vsplit<CR>", utils.opts("Split vertically"))
utils.map("n", "<leader>sh", ":split<CR>", utils.opts("Split horizontally"))
utils.map("n", "<A-Up>", "<CMD>resize +2<CR>")
utils.map("n", "<A-Down>", "<CMD>resize -2<CR>")
utils.map("n", "<A-Left>", "<CMD>vertical resize +2<CR>")
utils.map("n", "<A-Right>", "<CMD>vertical resize -2<CR>")

utils.map(
	"v",
	"<leader>/",
	"<ESC><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>",
	{ desc = "Comment Toggle" }
)

-- Indenting
utils.map("v", "<", "<gv")
utils.map("v", ">", ">gv")

-- From nvchad
utils.map("n", "<Esc>", "<cmd>noh<CR>", { desc = "General Clear highlights" })
utils.map("n", "<leader>fm", function()
	require("conform").format({ lsp_fallback = true })
end, { desc = "Format Files" })

-- DAP
utils.map("n", "<leader>dpr", "<CMD>lua require'dap-python'.test_method()<CR>", { desc = "Debug Test Method" })
utils.map("n", "<leader>db", "<CMD>DapToggleBreakpoint<CR>", { desc = "Toggle Breakpoint" })
utils.map("n", "<leader>dr", "<CMD>DapContinue<CR>", { desc = "Run or continue" })

-- Gitsigns
utils.map("n", "<leader>tb", "<CMD>lua require'gitsigns'.toggle_current_line_blame()<CR>", { desc = "Toggle Blame" })
utils.map("n", "[h", "<CMD>lua require('gitsigns').prev_hunk()<CR>", { desc = "Jump previous hunk" })
utils.map("n", "]h", "<CMD>lua require('gitsigns').next_hunk()<CR>", { desc = "Jump next hunk" })

if not vim.g.vscode then
	utils.map("n", "<leader>bk", "<CMD>bd<CR>", utils.opts("Close buffer"))
else
	utils.map("n", "<leader>x", "<CMD>lua require('vscode').call('workbench.action.closeActiveEditor')<CR>")
end

-- Neogit
if not vim.g.vscode then
	utils.map("n", "<leader>gg", "<CMD>Neogit<CR>", utils.opts("Open Neogit"))
else
	utils.map("n", "<leader>gg", "<CMD>lua require('vscode').call('magit.status')<CR>")
end

-- Oil
if not vim.g.vscode then
	-- utils.map("n", "-", "<CMD>Oil --float<CR>", utils.opts("Open float oil"))
	utils.map("n", "-", function()
		local buf_name = vim.api.nvim_buf_get_name(0)
		local path = vim.fn.filereadable(buf_name) == 1 and buf_name or vim.fn.getcwd()
		require("mini.files").open(path)
		require("mini.files").reveal_cwd()
	end, utils.opts("Open mini files"))
else
	utils.map("n", "-", "<CMD>lua require('vscode').call('extension.dired.open')<CR>")
end

-- Undotree
utils.map("n", "<leader>u", vim.cmd.UndotreeToggle, utils.opts("Toggle Undotree"))

-- ZenMode
utils.map("n", "<leader>tz", "<CMD>ZenMode<CR>", utils.opts("Toggle ZenMode"))

-- copy into system clipboard
utils.map("n", "<leader>y", '"+y')
utils.map("v", "<leader>y", '"+y')
utils.map("n", "<leader>Y", '"+Y')

utils.map("n", "x", '"_x')

-- vscode only
if vim.g.vscode then
	utils.map("n", "<leader>tv", "<CMD>lua require('vscode').call('workbench.action.toggleSidebarVisibility')<CR>")
	utils.map("n", "<leader>lD", "<CMD>lua require('vscode').call('workbench.actions.view.problems')<CR>")
	utils.map("n", "<leader>ff", "<CMD>lua require('vscode').call('find-it-faster.findFiles')<CR>")
	utils.map("n", "<leader>ff", "<CMD>lua require('vscode').call('find-it-faster.findWithinFiles')<CR>")
	utils.map("n", "<leader>lrn", "<CMD>lua require('vscode').call('editor.action.rename')<CR>")
	utils.map("n", "<leader>lfr", "<CMD>lua require('vscode').call('references-view.findReferences')<CR>")
	utils.map("n", "<leader>ca", "<CMD>lua require('vscode').call('editor.action.refactor')<CR>")
	utils.map("n", "<leader>tp", "<CMD>lua require('vscode').call('workbench.action.togglePanel')<CR>")
	utils.map("n", "<leader>tt", "<CMD>lua require('vscode').call('workbench.action.terminal.toggleTerminal')<CR>")
	utils.map("n", "<leader>fc", "<CMD>lua require('vscode').call('workbench.action.showCommands')<CR>")
end

-- Built in terminal
utils.map("t", "<ESC>", "<C-\\><C-n>", utils.opts("Escape terminal mode"))

-- Shortcut for "+ register
utils.map("n", "\\", '"+', utils.opts("Clipboard register"))

-- Alternate buffer
utils.map("n", "<leader><space>", "<C-^>", utils.opts("Alternate buffer"))

-- Scroll with centering
utils.map("n", "<C-u>", "<C-u>zz", utils.opts("Scroll up and center"))
utils.map("n", "<C-d>", "<C-d>zz", utils.opts("Scroll down and center"))
