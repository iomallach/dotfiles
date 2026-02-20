return {
	"rebelot/heirline.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons", "neovim/nvim-lspconfig" },
	enabled = false,
	event = "VeryLazy",
	config = function()
		require("heirline").setup({
			statusline = require("config.heirline"),
		})
	end,
}
