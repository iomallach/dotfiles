return {
	"sainnhe/everforest",
	priority = 1000,
	config = function()
		vim.o.background = "dark" -- or "light" for light mode
		vim.cmd([[colorscheme everforest]])
	end,
}
