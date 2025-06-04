return {
	"nvimdev/dashboard-nvim",
	event = "VimEnter",
	config = function()
		local logo = [[
⠀⠀⠀⠀⠀⠀⠀⣠⡤⠶⡄⠀⠀⠀⠀⠀⠀⠀⢠⠶⣦⣀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⢀⣴⣿⡟⠀⠈⣀⣾⣝⣯⣿⣛⣷⣦⡀⠀⠈⢿⣿⣦⡀⠀⠀⠀⠀
⠀⠀⠀⣴⣿⣿⣿⡇⠀⢼⣿⣽⣿⢻⣿⣻⣿⣟⣷⡄⠀⢸⣿⣿⣾⣄⠀⠀⠀
⠀⠀⣞⣿⣿⣿⣿⣷⣤⣸⣟⣿⣿⣻⣯⣿⣿⣿⣿⣀⣴⣿⣿⣿⣿⣯⣆⠀⠀
⠀⡼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣜⡆⠀
⢠⣟⣯⣿⣿⣿⣷⢿⣫⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣬⣟⠿⣿⣿⣿⣿⡷⣾⠀
⢸⣯⣿⣿⡏⠙⡇⣾⣟⣿⡿⢿⣿⣿⣿⣿⣿⢿⣟⡿⣿⠀⡟⠉⢹⣿⣿⢿⡄
⢸⣯⡿⢿⠀⠀⠱⢈⣿⢿⣿⡿⣏⣿⣿⣿⣿⣿⣿⣿⣿⣀⠃⠀⢸⡿⣿⣿⡇
⢸⣿⣇⠈⢃⣴⠟⠛⢉⣸⣇⣹⣿⣿⠚⡿⣿⣉⣿⠃⠈⠙⢻⡄⠎⠀⣿⡷⠃
⠈⡇⣿⠀⠀⠻⣤⠠⣿⠉⢻⡟⢷⣝⣷⠉⣿⢿⡻⣃⢀⢤⢀⡏⠀⢠⡏⡼⠀
⠀⠘⠘⡅⠀⣔⠚⢀⣉⣻⡾⢡⡾⣻⣧⡾⢃⣈⣳⢧⡘⠤⠞⠁⠀⡼⠁⠀⠀
⠀⠀⠀⠸⡀⠀⢠⡎⣝⠉⢰⠾⠿⢯⡘⢧⡧⠄⠀⡄⢻⠀⠀⠀⢰⠁⠀⠀⠀
⠀⠀⠀⠀⠁⠀⠈⢧⣈⠀⠘⢦⠀⣀⠇⣼⠃⠰⣄⣡⠞⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⢤⠼⠁⠀⠀⠳⣤⡼⠀⠀⠀⠀⠀⠀
    ]]
		logo = string.rep("\n", 2) .. logo

		require("dashboard").setup({
			-- config
			theme = "doom",
			config = {
				header = vim.split(logo, "\n"),
				center = {
					{
						icon = " ",
						desc = "Find File           ",
						key = "f",
						keymap = "SPC f f",
						key_format = " %s", -- remove default surrounding `[]`
						action = "lua require('fzf-lua').files()",
						icon_hl = "Title",
						key_hl = "Number",
						desc_hl = "String",
					},
					{
						icon = " ",
						desc = "Grep Project",
						key = "w",
						keymap = "SPC f g",
						key_format = " %s", -- remove default surrounding `[]`
						action = "lua requre('fzf-lua').live_grep()",
						icon_hl = "Title",
						key_hl = "Number",
						desc_hl = "String",
					},
					{
						icon = " ",
						desc = "Load Saved Session",
						key = "l",
						keymap = "SPC l s",
						key_format = " %s", -- remove default surrounding `[]`
						action = "lua require('persisted').load()",
						icon_hl = "Title",
						key_hl = "Number",
						desc_hl = "String",
					},
					{
						icon = " ",
						desc = "Git Good",
						key = "g",
						keymap = "SPC g g",
						key_format = " %s", -- remove default surrounding `[]`
						action = "lua require('neogit').open()",
						icon_hl = "Title",
						key_hl = "Number",
						desc_hl = "String",
					},
					{
						icon = "󰩈 ",
						desc = "Quit (Don't you dare)",
						key = "q",
						keymap = "SPC q",
						key_format = " %s",
						action = ":q",
						icon_hl = "Title",
						key_hl = "Number",
						desc_hl = "String",
					},
				},
				footer = {}, --your footer
			},
		})
	end,
	dependencies = { { "nvim-tree/nvim-web-devicons" } },
}
