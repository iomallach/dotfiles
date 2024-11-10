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
			hint = { enable = true },
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
	settings = {
		clangd = {
			InlayHints = {
				Designators = true,
				Enabled = true,
				ParameterNames = true,
				DeducedTypes = true,
			},
			fallbackFlags = { "-std=c++20" },
		},
	},
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
			usePlaceholders = false,
			analyses = {
				unusedparams = true,
			},
			hints = {
				rangeVariableTypes = true,
				parameterNames = true,
				constantValues = true,
				assignVariableTypes = true,
				compositeLiteralFields = true,
				compositeLiteralTypes = true,
				functionTypeParameters = true,
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

-- Tell our JDTLS language features it is capable of
capabilities = {
	workspace = {
		configuration = true,
	},
	textDocument = {
		completion = {
			completionItem = {
				snippetSupport = false,
			},
		},
	},
}

local lsp_capabilities = require("cmp_nvim_lsp").default_capabilities()

for k, v in pairs(lsp_capabilities) do
	capabilities[k] = v
end

require("java").setup({
	jdk = {
		auto_install = false,
	},
})
lspconfig.jdtls.setup({
	init_options = {
		bundles = require("spring_boot").java_extensions(),
	},
	settings = {
		java = {
			signatureHelp = {
				enabled = true,
			},
			-- Use the fernflower decompiler when using the javap command to decompile byte code back to java code
			contentProvider = {
				preferred = "fernflower",
			},
			-- Setup automatical package import oranization on file save
			saveActions = {
				organizeImports = true,
			},
			-- Customize completion options
			completion = {
				-- When using an unimported static method, how should the LSP rank possible places to import the static method from
				favoriteStaticMembers = {
					"org.hamcrest.MatcherAssert.assertThat",
					"org.hamcrest.Matchers.*",
					"org.hamcrest.CoreMatchers.*",
					"org.junit.jupiter.api.Assertions.*",
					"java.util.Objects.requireNonNull",
					"java.util.Objects.requireNonNullElse",
					"org.mockito.Mockito.*",
				},
				-- Try not to suggest imports from these packages in the code action window
				filteredTypes = {
					"com.sun.*",
					"io.micrometer.shaded.*",
					"java.awt.*",
					"jdk.*",
					"sun.*",
				},
				-- Set the order in which the language server should organize imports
				importOrder = {
					"java",
					"jakarta",
					"javax",
					"com",
					"org",
				},
			},
			sources = {
				-- How many classes from a specific package should be imported before automatic imports combine them all into a single import
				organizeImports = {
					starThreshold = 9999,
					staticThreshold = 9999,
				},
			},
			-- How should different pieces of code be generated?
			codeGeneration = {
				-- When generating toString use a json format
				toString = {
					template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
				},
				-- When generating hashCode and equals methods use the java 7 objects method
				hashCodeEquals = {
					useJava7Objects = true,
				},
				-- When generating code use code blocks
				useBlocks = true,
			},
			-- If changes to the project will require the developer to update the projects configuration advise the developer before accepting the change
			configuration = {
				updateBuildConfiguration = "interactive",
			},
			-- enable code lens in the lsp
			referencesCodeLens = {
				enabled = true,
			},
			implementationsCodeLens = {
				enabled = true,
			},
			-- enable inlay hints for parameter names,
			inlayHints = {
				parameterNames = {
					enabled = "all",
				},
				variableTypes = {
					enabled = true, -- Show variable type hints
				},
				methodReturnTypes = {
					enabled = true, -- Show return type hints for methods
				},
				lambdaParameterTypes = {
					enabled = true, -- Show parameter types for lambda expressions
				},
			},
		},
	},
	on_attach = function(client, bufnr)
		-- Refresh the codelens
		-- Code lens enables features such as code reference counts, implemenation counts, and more.
		vim.lsp.codelens.refresh()

		-- Code Lens autocommand setup
		vim.api.nvim_create_autocmd("BufWritePost", {
			pattern = { "*.java" },
			callback = function()
				local _, _ = pcall(vim.lsp.codelens.refresh)
			end,
		})
	end,
})
