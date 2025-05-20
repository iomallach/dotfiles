local M = {}

local lspconfig = require("lspconfig")
local diagnostic_signs = {
	Error = " ",
	Warn = " ",
	Hint = "",
	Info = "",
}

local setup_diagnostic_signs = function()
	for type, icon in pairs(diagnostic_signs) do
		local hl = "DiagnosticSign" .. type
		vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
	end
end

local setup_pylyzer = function(capabilities)
	vim.lsp.config("pylyzer", {
		capabilities = capabilities,
	})
	vim.lsp.enable("pylyzer")
end

local setup_gopls = function(capabilities)
	-- Setup all go related LSPs
	-- Gopls
	vim.lsp.config("gopls", {
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
	vim.lsp.enable("gopls")

	-- Templ
	vim.lsp.config("templ", {
		capabilities = capabilities,
	})
	vim.lsp.enable("templ")

	-- Tailwindcss

	vim.lsp.config("tailwindcss", {
		settings = {
			includeLanguages = {
				templ = "html",
			},
		},
	})
	vim.lsp.enable("tailwindcss")
end

local setup_jdtls = function()
	-- Tell our JDTLS language features it is capable of
	local capabilities = {
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

	local lsp_capabilities = require("blink.cmp").get_lsp_capabilities(capabilities)

	for k, v in pairs(lsp_capabilities) do
		capabilities[k] = v
	end

	require("java").setup({
		jdk = {
			auto_install = false,
		},
	})
	vim.lsp.config("jdtls", {
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
	vim.lsp.enable("jdtls")
end

M.setup = function()
	setup_diagnostic_signs()

	setup_jdtls()
end

return M
