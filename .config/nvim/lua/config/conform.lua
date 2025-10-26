local function get_python_formatter_executable()
	-- one of these must be either installed in the venv or installed globally
	local formatters = { "black", "ruff" }

	for _, formatter in ipairs(formatters) do
		if vim.fn.executable(formatter) == 1 then
			return formatter
		end
	end

	-- fallback to ruff always
	return "ruff"
end

local function get_python_formatters()
	local formatter = get_python_formatter_executable()

	if formatter == "ruff" then
		return { "ruff_format", "ruff_fix" }
	elseif formatter == "black" then
		return { "black_format" }
	end

	return { "ruff_format", "ruff_fix" } -- fallback
end

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
		ruff_format = {
			command = "ruff",
			args = {
				"format",
				"--force-exclude",
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
		black_format = {
			command = "black",
			args = {
				"--stdin-filename",
				"$FILENAME",
				"--quiet",
				"-",
			},
		},
	},

	formatters_by_ft = {
		lua = { "stylua" },
		c = { "clang_format" },
		python = get_python_formatters(),
		go = { "gofumpt", "goimports" },
		java = { "google-java-format" },
		nix = { "nixfmt" },
	},
	format_on_save = {
		-- These options will be passed to conform.format()
		timeout_ms = 500,
		lsp_fallback = true,
	},
}

require("conform").setup(options)
