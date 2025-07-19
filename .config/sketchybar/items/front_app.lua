local colors = require("colors")

local front_app = sbar.add("item", {
	position = "left",
	background = {
		color = colors.surface0,
		border_color = colors.blue,
		border_width = 1,
	},
	icon = {
		background = {
			drawing = true,
		},
	},
	label = {
		padding_right = 20,
	},
	display = "active",
	padding_right = 10,
})

front_app:subscribe({ "front_app_switched" }, function(env)
	front_app:set({
		label = "  " .. env.INFO,
		icon = {
			background = {
				image = "app." .. env.INFO,
			},
		},
	})
end)
