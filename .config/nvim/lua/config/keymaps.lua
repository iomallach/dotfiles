local keymap = vim.keymap

local opts = function(desc)
	return { desc = desc, noremap = true, silent = true }
end

-- Directory navigation
keymap.set("n", "<leader>n", ":NvimTreeToggle<CR>", opts("Toggle NvimTree"))
keymap.set("n", "<leader>e", ":NvimTreeFocus<CR>", opts("Focus NvimTree"))

-- Pane navigation and window navigation
keymap.set("n", "<C-h>", "<C-w>h", opts("Navigate left"))
keymap.set("n", "<C-j>", "<C-w>j", opts("Navigate down"))
keymap.set("n", "<C-k>", "<C-w>k", opts("Navigate up"))
keymap.set("n", "<C-l>", "<C-w>l", opts("Navigate right"))
keymap.set("t", "<C-h>", "[[<Cmd>wincmd h<CR>") -- Navigate left
keymap.set("t", "<C-j>", "[[<Cmd>wincmd j<CR>") -- Navigate down
keymap.set("t", "<C-k>", "[[<Cmd>wincmd k<CR>") -- Navigate up
keymap.set("t", "<C-l>", "[[<Cmd>wincmd l<CR>") -- Navigate right
keymap.set("n", "<C-h>", ":TmuxNavigateLeft<CR>") -- Navigate left
keymap.set("n", "<C-j>", ":TmuxNavigateDown<CR>") -- Navigate down
keymap.set("n", "<C-k>", ":TmuxNavigateUp<CR>") -- Navigate up
keymap.set("n", "<C-l>", ":TmuxNavigateRight<CR>") -- Navigate right

-- Insert mode movement
-- keymap.set("i", "<C-b>", "<ESC>^i", { desc = "Move Beginning of line" })
-- keymap.set("i", "<C-e>", "<End>", { desc = "Move End of line" })
keymap.set("i", "<C-h>", "<Left>", { desc = "Move Left" })
keymap.set("i", "<C-l>", "<Right>", { desc = "Move Right" })
keymap.set("i", "<C-j>", "<Down>", { desc = "Move Down" })
keymap.set("i", "<C-k>", "<Up>", { desc = "Move Up" })

-- Move lines up and down
keymap.set("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
keymap.set("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })
keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move line down" })
keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move line up" })

-- Window management
keymap.set("n", "<leader>sv", ":vsplit<CR>", opts("Split vertically"))
keymap.set("n", "<leader>sh", ":split<CR>", opts("Split horizontally"))
keymap.set("n", "<A-Up>", "<CMD>resize +2<CR>")
keymap.set("n", "<A-Down>", "<CMD>resize -2<CR>")
keymap.set("n", "<A-Left>", "<CMD>vertical resize +2<CR>")
keymap.set("n", "<A-Right>", "<CMD>vertical resize -2<CR>")

keymap.set(
	"v",
	"<leader>/",
	"<ESC><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>",
	{ desc = "Comment Toggle" }
)

-- Indenting
keymap.set("v", "<", "<gv")
keymap.set("v", ">", ">gv")

-- From nvchad
keymap.set("n", "<Esc>", "<cmd>noh<CR>", { desc = "General Clear highlights" })
keymap.set("n", "<leader>fm", function()
	require("conform").format({ lsp_fallback = true })
end, { desc = "Format Files" })

-- DAP
keymap.set("n", "<leader>dpr", "<CMD>lua require'dap-python'.test_method()<CR>", { desc = "Debug Test Method" })
keymap.set("n", "<leader>db", "<CMD>DapToggleBreakpoint<CR>", { desc = "Toggle Breakpoint" })
keymap.set("n", "<leader>dr", "<CMD>DapContinue<CR>", { desc = "Run or continue" })

-- Gitsigns
keymap.set("n", "<leader>tb", "<CMD>lua require'gitsigns'.toggle_current_line_blame()<CR>", { desc = "Toggle Blame" })

-- Bufferline
keymap.set("n", "<tab>", "<CMD>BufferLineCycleNext<CR>", opts("Next buffer"))
keymap.set("n", "<S-tab>", "<CMD>BufferLineCyclePrev<CR>", opts("Previous buffer"))
keymap.set("n", "<leader>x", "<CMD>bd<CR>", opts("Close buffer"))

-- Neogit
keymap.set("n", "<leader>gg", "<CMD>Neogit<CR>", opts("Open Neogit"))

-- Oil
keymap.set("n", "-", "<CMD>Oil --float<CR>", opts("Open float oil"))

-- Undotree
keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle, opts("Toggle Undotree"))

-- ZenMode
keymap.set("n", "<leader>tz", "<CMD>ZenMode<CR>", opts("Toggle ZenMode"))
