local settings = require("settings")
local colors = require("colors")

sbar.default({
	icon = {
		font = {
			family = settings.font.text,
			style = settings.font.style_map["Regular"],
			size = 20,
		},
		color = colors.green,
	},
	label = {
		color = colors.text,
		font = {
			family = settings.font.text,
			style = settings.font.style_map["Regular"],
			size = 16,
		},
	},
	background = {
		height = 32,
		corner_radius = 16,
	},
})
