local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local clock = sbar.add("item", {
	position = "right",
	background = {
		padding_left = 0,
	},
	icon = {
		string = icons.datetime,
		color = colors.yellow,
	},
	label = {
		padding_right = 10,
		padding_left = 10,
		font = {
			family = settings.font.text,
			style = settings.font.style_map["SemiBold"],
		},
	},
	update_freq = 10,
})

clock:set({
	label = os.date("%a %b %e %H:%M"),
})

clock:subscribe({ "force", "routine", "system_woke" }, function()
	clock:set({
		label = os.date("%a %b %e %H:%M"),
	})
end)

return clock
