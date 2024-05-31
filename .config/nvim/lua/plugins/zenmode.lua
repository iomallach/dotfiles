return -- Lua
{
	"folke/zen-mode.nvim",
	cmd = "ZenMode",
	opts = {
		-- your configuration comes here
		-- or leave it empty to use the default settings
		-- refer to the configuration section below
	},
  config = function ()
    vim.keymap.set("n", "<leader>tz", "<CMD>ZenMode<CR>")
  end
}
