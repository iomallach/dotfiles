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
		"nix",
		"just",
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
	lazy = false,
	build = ":TSUpdate",
	config = function()
		require("nvim-treesitter").setup({
			install_dir = vim.fn.stdpath("data") .. "/site",
		})
		require("nvim-treesitter").install(opts.ensure_installed)
	end,
	dependencies = {
		"nvim-treesitter/nvim-treesitter-context",
	},
}
