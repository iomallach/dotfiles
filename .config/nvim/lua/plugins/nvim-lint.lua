return {
	"mfussenegger/nvim-lint",
	lazy = false,
	config = function()
		require("lint").linters_by_ft = {
			c = { "clangtidy" },
			python = { "mypy", "ruff" },
			dockerfile = { "hadolint" },
			yaml = { "actionlint" },
		}
		vim.api.nvim_create_autocmd({ "InsertLeave", "BufEnter", "BufWritePre" }, {
			callback = function()
				require("lint").try_lint()
			end,
		})
	end,
}
