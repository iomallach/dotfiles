local options = {
	lsp_fallback = true,
	formatters = {
		ruff_fix = {
			command = "ruff",
			args = {
				"check",
				"--fix",
				"-e",
				"-n",
				"--select",
				"I",
				"--stdin-filename",
				"$FILENAME",
				"-",
			},
			stdin = true,
			cwd = require("conform.util").root_file({
				"pyproject.toml",
				"ruff.toml",
			}),
		},
	},

	formatters_by_ft = {
		lua = { "stylua" },
		c = { "clang_format" },
		python = { "ruff_format", "ruff_fix" },
	},
	format_on_save = {
		-- These options will be passed to conform.format()
		timeout_ms = 500,
		lsp_fallback = true,
	},
}

require("conform").setup(options)
