return {
	"williamboman/mason.nvim",
	cmd = "Mason",
	opts = {
		ensure_installed = {
			"clangd",
			"clang-format",
			"rust-analyzer",
			"basedpyright",
			"mypy",
			"ruff",
			"debugpy",
			"gopls",
			"gofumpt",
			"goimports",
			"golines",
			"golangci-lint",
			"lua-language-server",
			"checkmake",
			"luacheck",
			"stylua",
			"hadolint",
			"json-lsp",
			"yaml-language-server",
			"jdtls",
			"tailwindcss-language-server",
			"templ",
			"delve",
			"java-debug-adapter",
			"java-test",
		},

		PATH = "skip",

		ui = {
			icons = {
				package_pending = " ",
				package_installed = "󰄳 ",
				package_uninstalled = " 󰚌",
			},

			keymaps = {
				toggle_server_expand = "<CR>",
				install_server = "i",
				update_server = "u",
				check_server_version = "c",
				update_all_servers = "U",
				check_outdated_servers = "C",
				uninstall_server = "X",
				cancel_installation = "<C-c>",
			},
		},
		max_concurrent_installers = 10,
	},
	-- config = function(_, opts)
	--   require("mason").setup(opts)
	--   vim.api.nvim_create_user_command("MasonInstallAll", function()
	--     if opts.ensure_installed and #opts.ensure_installed > 0 then
	--       vim.cmd("MasonInstall " .. table.concat(opts.ensure_installed, " "))
	--     end
	--   end, {})
	--
	--   vim.g.mason_binaries_list = opts.ensure_installed
	-- end
}
