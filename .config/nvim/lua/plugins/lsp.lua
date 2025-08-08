return {
	{
		"neovim/nvim-lspconfig",
		event = "VeryLazy",
		dependencies = {
			"saghen/blink.cmp",
		},
		config = function()
			require("config.nvim-lspconfig").setup()
		end,
	},
	{
		"folke/trouble.nvim",
		opts = {},
		cmd = "Trouble",
	},
	{
		"chrisgrieser/nvim-lsp-endhints",
		event = "LspAttach",
		config = function()
			require("lsp-endhints").setup({
				icons = {
					type = "󰜁 ",
					parameter = "󰏪 ",
					offspec = " ", -- hint kind not defined in official LSP spec
					unknown = " ", -- hint kind is nil
				},
				label = {
					padding = 1,
					marginLeft = 0,
					bracketedParameters = true,
				},
				autoEnableHints = true,
			})

			local map = vim.keymap.set
			-- inlay hints will show at the end of the line (default)
			map("n", "<leader>lhe", require("lsp-endhints").enable)
			-- inlay hints will show as if the plugin was not installed
			map("n", "<leader>lhd", require("lsp-endhints").disable)
			-- toggle between the two
			map("n", "<leader>lht", require("lsp-endhints").toggle)
		end,
	},
	{
		"rachartier/tiny-inline-diagnostic.nvim",
		event = "VeryLazy", -- Or `LspAttach`
		priority = 1000, -- needs to be loaded in first
		config = function()
			require("tiny-inline-diagnostic").setup({
				always_show = true,
				options = {
					show_source = true,
				},
			})
		end,
	},
	{
		"rmagatti/goto-preview",
		event = "BufEnter",
		config = true, -- necessary as per https://github.com/rmagatti/goto-preview/issues/88
	},
	-- {
	-- 	"mfussenegger/nvim-jdtls",
	-- 	dependencies = {
	-- 		"mfussenegger/nvim-dap",
	-- 		"ray-x/lsp_signature.nvim",
	-- 	},
	-- },
}
