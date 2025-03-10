local opts = {
	ensure_installed = {
		"vimdoc",
		"vim",
		"lua",
		"python",
		"c",
		"haskell",
		"go",
		"zig",
		"rust",
		"json",
		"markdown",
		"markdown_inline",
		"dockerfile",
		"sql",
		"bash",
		"regex",
		"yaml",
		"toml",
		"gitignore",
		"typescript",
	},
	highlight = {
		enable = true,
		use_languagetree = true,
	},
	indent = { enable = true },
	auto_install = true,
	autotag = { enable = true }, -- Close and rename html tags
}

return {
	"nvim-treesitter/nvim-treesitter",
	event = "VeryLazy",
	config = function()
		require("nvim-treesitter.configs").setup(opts)
	end,
	dependencies = {
		"nvim-treesitter/nvim-treesitter-context",
	},
}
