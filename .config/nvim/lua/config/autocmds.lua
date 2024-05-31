vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(ev)
		-- Enable completion triggered by <c-x><c-o>
		vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

		-- Buffer local mappings
		-- See `:help vim.lsp.*` for documentation
		local function opts(desc)
			return { buffer = ev.buf, desc = desc }
		end

		local map = vim.keymap.set

		map("n", "[d", "<CMD>Lspsaga diagnostic_jump_prev<CR>", opts("Previous diagnostic"))
		map("n", "]d", "<CMD>Lspsaga diagnostic_jump_next<CR>", opts("Next diagnostic"))
		map("n", "K", "<CMD>Lspsaga hover_doc<CR>", opts("Hover doc"))
		map("n", "<leader>lo", "<CMD>Lspsaga outline<CR>", opts("Outline"))
		map("n", "<leader>lpd", "<CMD>Lspsaga peek_definition<CR>", opts("Peek definition"))
		map("n", "<leader>lgd", "<CMD>Lspsaga goto_definition<CR>", opts("Go to definition"))
		map("n", "<leader>lgt", "<CMD>Lspsaga goto_type_definition<CR>", opts("Go to type definition"))
		map("n", "<leader>lrn", "<CMD>Lspsaga rename<CR>", opts("Rename"))
		map("n", "<leader>ld", "<CMD>Lspsaga show_line_diagnostics<CR>", opts("Show line diagnostic"))
		map("n", "<leader>lD", "<CMD>Lspsaga show_buf_diagnostics<CR>", opts("Show buffer diagnostics"))
		map("n", "<leader>lfr", "<CMD>Lspsaga finder<CR>", opts("Show references"))
		map("n", "<leader>lpt", "<CMD>Lspsaga peek_type_definition<CR>", opts("Peek type definition"))

		map("i", "<C-s>", vim.lsp.buf.signature_help, opts("Signature help"))
		map("n", "<leader>lgi", vim.lsp.buf.implementation, opts("Lsp Go to implementation"))
		map("n", "<leader>lwa", vim.lsp.buf.add_workspace_folder, opts("Lsp Add workspace folder"))
		map("n", "<leader>lwr", vim.lsp.buf.remove_workspace_folder, opts("Lsp Remove workspace folder"))

		map("n", "<leader>lwl", function()
			print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
		end, opts("Lsp List workspace folders"))

		map({ "n", "v" }, "<leader>ca", "<CMD>Lspsaga code_action<CR>", opts("Lspsaga Code action"))
	end,
})

-- highlight on yank
local highlight_yank_group = vim.api.nvim_create_augroup("HighlightYankGroup", {})
vim.api.nvim_create_autocmd("TextYankPost", {
	group = highlight_yank_group,
	callback = function()
		vim.highlight.on_yank()
	end,
})
