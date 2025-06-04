local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = vim.tbl_deep_extend("force", capabilities, require("blink.cmp").get_lsp_capabilities(capabilities))
capabilities = vim.tbl_deep_extend("force", capabilities, {
	textDocument = {
		completion = {
			editsNearCursor = true,
		},
	},
	offsetEncoding = { "utf-8", "utf-16" },
})

return {
	on_attach = function(client, bufnr)
		client.server_capabilities.signatureHelpProvider = false
	end,
	capabilities = capabilities,
	cmd = { "clangd" },
	filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
	root_markers = {
		".clangd",
		".clang-tidy",
		".clang-format",
		"compile_commands.json",
		"compile_flags.txt",
		"configure.ac", -- AutoTools
		".git",
	},
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
}
