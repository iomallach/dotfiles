return {
	"mrcjkb/rustaceanvim",
	version = "^4",
	ft = { "rust" },
	dependencies = {
		{
			"lvimuser/lsp-inlayhints.nvim",
			opts = {},
		},
		"nvim-lua/plenary.nvim",
		"mfussenegger/nvim-dap",
	},
	config = function()
		vim.g.rustaceanvim = {
			tools = {
				hover_actions = {
					auto_focus = true,
				},
			},
			server = {
				on_attach = function(client, bufnr)
					require("lsp-inlayhints").on_attach(client, bufnr)
					local map = vim.keymap.set

					-- Inlayhints mappings
					map("n", "<leader>lht", function()
						require("lsp-inlayhints").toggle()
					end, { desc = "Toggle inlayhints" })

					map("n", "<leader>lhr", function()
						require("lsp-inlayhints").reset()
					end, { desc = "Reset inlayhints" })
				end,
			},
		}
	end,
}
