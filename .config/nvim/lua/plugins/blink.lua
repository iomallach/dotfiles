return {
	{
		"saghen/blink.cmp",
		version = "*",
		opts_extend = {
			"sources.completion.enabled_providers",
			"sources.compat",
			"sources.default",
		},
		dependencies = {
			"rafamadriz/friendly-snippets",
			"onsails/lspkind.nvim",
			"supermaven-inc/supermaven-nvim",
			{
				"saghen/blink.compat",
				opts = {},
				version = "*",
			},
			{
				"L3MON4D3/LuaSnip",
				-- follow latest release.
				version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
				-- install jsregexp (optional!).
				build = "make install_jsregexp",
			},
		},
		event = "InsertEnter",

		opts = {
			snippets = {
				preset = "luasnip",
			},
			appearance = {
				use_nvim_cmp_as_default = false,
				nerd_font_variant = "normal",
			},
			completion = {
				accept = {
					auto_brackets = {
						enabled = true,
					},
				},
				menu = {
					border = "rounded",
					draw = {
						treesitter = { "lsp" },
						columns = {
							{ "kind_icon", "label", "label_description", gap = 1 },
							{ "kind", "source_name", gap = 1 },
						},
					},
				},
				documentation = {
					auto_show = true,
					auto_show_delay_ms = 100,
					-- NOTE: Added on top of stuff grabbed from lazyvim
					treesitter_highlighting = true,
					window = { border = "rounded" },
				},
				ghost_text = {
					enabled = false,
				},
			},

			signature = {
				enabled = true,
				window = {
					border = "rounded",
					show_documentation = true,
				},
			},

			sources = {
				default = { "lsp", "path", "snippets", "buffer", "supermaven" },
				providers = {
					supermaven = {
						name = "supermaven",
						module = "blink.compat.source",
						score_offset = 100,
						async = true,
					},
				},
			},

			cmdline = {
				enabled = false,
			},

			keymap = {
				preset = "default",
			},
		},
	},
}
