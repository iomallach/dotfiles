local ensure_installed = function()
	local ei = {
		"clangd",
		"clang-format",
		"rust-analyzer",
		"pyright",
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
		"checkstyle",
		"google-java-format",
		"marksman",
	}

	vim.api.nvim_create_user_command("MasonInstallAll", function()
		vim.cmd("MasonInstall " .. table.concat(ei, " "))
	end, {})

	vim.g.mason_binaries_list = ei
end

return {
	"williamboman/mason.nvim",
	cmd = "Mason",
	opts = {
		ensure_installed = ensure_installed(),

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
}
