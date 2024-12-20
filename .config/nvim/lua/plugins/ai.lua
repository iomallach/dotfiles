return {
	-- {
	-- 	"Exafunction/codeium.nvim",
	-- 	event = "VeryLazy",
	-- 	dependencies = {
	-- 		"nvim-lua/plenary.nvim",
	-- 		-- "hrsh7th/nvim-cmp",
	-- 		"iguanacucumber/magazine.nvim",
	-- 	},
	-- 	config = function()
	-- 		require("codeium").setup({})
	-- 	end,
	-- },
	{
		"supermaven-inc/supermaven-nvim",
		event = "VeryLazy",
		dependencies = {
			-- "hrsh7th/nvim-cmp",
			"iguanacucumber/magazine.nvim",
		},
		config = function()
			require("supermaven-nvim").setup({
				disable_inline_completion = true, -- disables inline completion for use with cmp
				disable_keymaps = true,
			})
		end,
	},
}
