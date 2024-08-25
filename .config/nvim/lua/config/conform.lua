local function get_ruff_executable()
	local path_to_ruff = vim.fn.getcwd() .. "/.venv/bin/ruff"
	local is_ruff_in_venv = vim.fn.filereadable(path_to_ruff)
	if is_ruff_in_venv then
		return path_to_ruff
	end
	return "ruff"
end

local options = {
	lsp_fallback = true,
	formatters = {
		ruff_fix = {
			command = get_ruff_executable(),
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
		ruff_format = {
			command = get_ruff_executable(),
		},
	},

	formatters_by_ft = {
		lua = { "stylua" },
		c = { "clang_format" },
		python = { "ruff_format", "ruff_fix" },
		go = { "gofumpt", "goimports" },
	},
	format_on_save = {
		-- These options will be passed to conform.format()
		timeout_ms = 500,
		lsp_fallback = true,
	},
}

require("conform").setup(options)
