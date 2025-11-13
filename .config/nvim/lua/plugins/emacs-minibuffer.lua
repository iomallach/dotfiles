return {
	"simifalaye/minibuffer.nvim",
	lazy = false,
	init = function()
		local minibuffer = require("minibuffer")

		vim.ui.select = require("minibuffer.builtin.ui_select")
		vim.ui.input = require("minibuffer.builtin.ui_input")

		vim.keymap.set("n", "<M-;>", require("minibuffer.builtin.cmdline"))
		vim.keymap.set("n", "<M-.>", function()
			minibuffer.resume(true)
		end)
	end,
}
