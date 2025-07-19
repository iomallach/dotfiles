local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

local memory = sbar.add("item", {
	position = "right",
	icon = {
		string = icons.memory,
		color = colors.red,
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

memory:subscribe({ "system_stats" }, function(env)
	memory:set({
		label = env.RAM_USAGE,
	})
end)

return memory
