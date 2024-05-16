local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- config.color_scheme = "Zenburn"
-- config.color_scheme = "DoomOne"
config.color_scheme = "Catppuccin Macchiato"
config.font = wezterm.font("FiraCode Nerd Font")
config.font_size = 16
config.hide_tab_bar_if_only_one_tab = true
config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}
config.window_decorations = "RESIZE"

return config
