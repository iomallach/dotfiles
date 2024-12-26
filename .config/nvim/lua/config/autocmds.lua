vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(args)
		-- Enable completion triggered by <c-x><c-o>
		vim.bo[args.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

		-- Buffer local mappings
		-- See `:help vim.lsp.*` for documentation
		local function opts(desc)
			return { buffer = args.buf, desc = desc }
		end

		-- Attach lsp_signature to buffer
		local bufnr = args.buf
		require("lsp_signature").on_attach({}, bufnr)

		local map = vim.keymap.set

		-- Add borders
		vim.diagnostic.config({
			float = { border = "rounded" },
			virtual_text = false,
		})
		vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
			border = "rounded",
		})

		map("n", "[d", vim.diagnostic.goto_prev, opts("Go to previous diagnostic"))
		map("n", "]d", vim.diagnostic.goto_next, opts("Go to next diagnostic"))
		map("n", "K", vim.lsp.buf.hover, opts("Hover doc"))
		map("n", "gK", function()
			vim.lsp.buf.signature_help()
		end, opts("Signature help"))
		map("n", "<leader>lpd", require("goto-preview").goto_preview_definition, opts("Peek definition"))
		map("n", "<leader>lgd", vim.lsp.buf.definition, opts("Go to definition"))
		map("n", "<leader>lgt", vim.lsp.buf.type_definition, opts("Go to type definition"))
		map("n", "<leader>lrn", vim.lsp.buf.rename, opts("Rename"))
		map("n", "<leader>ld", vim.diagnostic.open_float, opts("Show line diagnostic"))
		map("n", "<leader>lD", "<CMD>Trouble diagnostics toggle filter.buf=0<CR>", opts("Buffer diagnostics (trouble)"))
		map("n", "<leader>ltd", "<CMD>Trouble todo<CR>")
		map("n", "<leader>lfr", require("fzf-lua").lsp_references, opts("Show references"))
		map("n", "<leader>lpt", require("goto-preview").goto_preview_type_definition, opts("Peek type definition"))

		map("i", "<C-s>", vim.lsp.buf.signature_help, opts("Signature help"))
		map("n", "<leader>lgi", vim.lsp.buf.implementation, opts("Lsp Go to implementation"))
		map("n", "<leader>lwa", vim.lsp.buf.add_workspace_folder, opts("Lsp Add workspace folder"))
		map("n", "<leader>lwr", vim.lsp.buf.remove_workspace_folder, opts("Lsp Remove workspace folder"))

		map("n", "<leader>lwl", function()
			print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
		end, opts("Lsp List workspace folders"))

		map({ "n", "v" }, "<leader>ca", require("fzf-lua").lsp_code_actions, opts("Code action"))
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
