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
		padding_left = 10,
		padding_right = 10,
	},
	label = {
		color = colors.text,
		font = {
			family = settings.font.text,
			style = settings.font.style_map["Regular"],
			size = 16,
		},
		padding_right = 10,
	},
	background = {
		height = 32,
		corner_radius = 16,
		padding_left = 10,
		padding_right = 10,
	},
})
