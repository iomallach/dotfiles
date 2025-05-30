return {
	{
		"supermaven-inc/supermaven-nvim",
		event = "VeryLazy",
		config = function()
			require("supermaven-nvim").setup({
				disable_inline_completion = true, -- disables inline completion for use with cmp
				disable_keymaps = true,
			})
		end,
	},
}
