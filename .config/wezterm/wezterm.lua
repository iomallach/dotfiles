local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- config.color_scheme = "Zenburn"
-- config.color_scheme = "DoomOne"
config.color_scheme = "Catppuccin Macchiato"
-- config.font = wezterm.font("FiraCode Nerd Font")
config.font = wezterm.font("CaskaydiaCove Nerd Font")
-- config.font = wezterm.font("JetBrainsMono Nerd Font")
config.font_size = 20
config.hide_tab_bar_if_only_one_tab = true
config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}
config.window_decorations = "RESIZE"

-- Wezterm - Nvim-Zenmode integration
wezterm.on("user-var-changed", function(window, pane, name, value)
	local overrides = window:get_config_overrides() or {}
	if name == "ZEN_MODE" then
		local incremental = value:find("+")
		local number_value = tonumber(value)
		if incremental ~= nil then
			while number_value > 0 do
				window:perform_action(wezterm.action.IncreaseFontSize, pane)
				number_value = number_value - 1
			end
			overrides.enable_tab_bar = false
		elseif number_value < 0 then
			window:perform_action(wezterm.action.ResetFontSize, pane)
			overrides.font_size = nil
			overrides.enable_tab_bar = true
		else
			overrides.font_size = number_value
			overrides.enable_tab_bar = false
		end
	end
	window:set_config_overrides(overrides)
end)

return config
