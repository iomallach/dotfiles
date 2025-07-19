local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

local cpu = sbar.add("item", {
	position = "right",
	icon = {
		string = icons.cpu,
		color = colors.blue,
		padding_right = 5,
		padding_left = 10,
	},
	background = {
		padding_right = 0,
		padding_left = 0,
	},
	label = {
		padding_right = 10,
		padding_left = 0,
		font = {
			family = settings.font.text,
			style = settings.font.style_map["Bold"],
		},
	},
})

cpu:subscribe({ "system_stats" }, function(env)
	cpu:set({
		label = env.CPU_USAGE,
	})
end)

return cpu
