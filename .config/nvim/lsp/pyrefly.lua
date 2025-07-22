local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = vim.tbl_deep_extend("force", capabilities, require("blink.cmp").get_lsp_capabilities(capabilities))

return {
	capabilities = capabilities,
	cmd = { "pyrefly", "lsp" },
	filetypes = { "python" },
	root_markers = {
		"pyrefly.toml",
		"pyproject.toml",
		"setup.py",
		"setup.cfg",
		"requirements.txt",
		"Pipfile",
		".git",
	},
	on_exit = function(code, _, _)
		vim.notify("Closing Pyrefly LSP exited with code: " .. code, vim.log.levels.INFO)
	end,
}
