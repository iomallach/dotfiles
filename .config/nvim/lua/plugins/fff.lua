return {
	"dmtrKovalenko/fff.nvim",
	build = "nix run .#release",
	lazy = false,
	opts = {
		-- pass here all the options
	},
	keys = {
		{
			"<leader>ff",
			function()
				require("fff").find_files() -- or find_in_git_root() if you only want git files
			end,
			desc = "Open file picker",
		},
	},
}
