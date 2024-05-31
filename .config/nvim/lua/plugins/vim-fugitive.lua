return {
	"tpope/vim-fugitive",
	lazy = false,
	cmd = "Git",
	-- config = function()
	-- 	-- TODO: this duplicates keymaps, consider moving to utils
	-- 	local opts = function(desc)
	-- 		return { desc = desc, noremap = true, silent = true }
	-- 	end
	--
	-- 	local keymap = vim.keymap
	-- 	keymap("n", "<leader>gP", function()
	-- 		vim.cmd.Git("push")
	-- 	end, opts("Fugitive Git Push"))
	-- 	keymap("n", "<leader>gp", function()
	-- 		vim.cmd.Git({ "pull", "--rebase" })
	-- 	end, opts("Fugitive Git Pull Rebase"))
	-- 	keymap("n", "<leader>gt", ":Git push -u origin", opts("Fugitive Git Push Origin"))
	-- end,
}
