local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local tempcpu = sbar.add("item", {
	position = "right",
	background = {
		padding_right = 0,
		padding_left = 0,
	},
	icon = {
		string = icons.temperature,
		color = colors.peach,
		padding_right = 5,
		padding_left = 10,
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

tempcpu:subscribe({ "system_stats" }, function(env)
	tempcpu:set({
		label = env.CPU_TEMP,
	})
end)

return tempcpu
