local lspconfig = require("lspconfig")

local diagnostic_signs = {
	Error = " ",
	Warn = " ",
	Hint = "",
	Info = "",
}

for type, icon in pairs(diagnostic_signs) do
	local hl = "DiagnosticSign" .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem = {
	documentationFormat = { "markdown", "plaintext" },
	snippetSupport = true,
	preselectSupport = true,
	insertReplaceSupport = true,
	labelDetailsSupport = true,
	deprecatedSupport = true,
	commitCharactersSupport = true,
	tagSupport = { valueSet = { 1 } },
	resolveSupport = {
		properties = {
			"documentation",
			"detail",
			"additionalTextEdits",
		},
	},
}

lspconfig.lua_ls.setup({
	capabilities = capabilities,
	settings = {
		Lua = {
			diagnostics = {
				globals = { "vim" },
			},
			workspace = {
				library = {
					[vim.fn.expand("$VIMRUNTIME/lua")] = true,
					[vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
				},
			},
			maxPreload = 100000,
			preloadFileSize = 10000,
		},
	},
})

lspconfig.clangd.setup({
	on_attach = function(client, bufnr)
		client.server_capabilities.signatureHelpProvider = false
	end,
	capabilities = capabilities,
})

lspconfig.pyright.setup({
	on_attach = function(client, bufnr)
		-- TODO: If it annoys with failures, try pcall()
		-- vim.cmd("PyrightSetPythonPath .venv/bin/python")
	end,
	capabilities = capabilities,
	filetypes = { "python" },
	settings = {
		pyright = {
			disableOrganizeImport = true,
			analysis = {
				useLibraryCodeForTypes = true,
				autoSearchPaths = true,
				autoImportCompletions = true,
			},
		},
	},
})

lspconfig.gopls.setup({
	capabilities = capabilities,
	cmd = { "gopls" },
	filetypes = { "go", "gomod", "gowork", "gotmpl" },
	root_dir = lspconfig.util.root_pattern("go.work", "go.mod", ".git"),
	settings = {
		gopls = {
			completeUnimported = true,
			usePlaceholders = true,
			analyses = {
				unusedparams = true,
			},
		},
	},
})

lspconfig.templ.setup({
	capabilities = capabilities,
})

lspconfig.jsonls.setup({
	commands = {
		Format = {
			function()
				vim.lsp.buf.range_formatting({}, { 0, 0 }, { vim.fn.line("$"), 0 })
			end,
		},
	},
})

lspconfig.tailwindcss.setup({
	settings = {
		includeLanguages = {
			templ = "html",
		},
	},
})

lspconfig.yamlls.setup({})

-- require('java').setup({
--   jdk = {
--     auto_install = false,
--   },
-- })
-- lspconfig.jdtls.setup({})
