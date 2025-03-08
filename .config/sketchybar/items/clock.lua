local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local date = sbar.add("item", {
	position = "right",
	label = {
		font = {
			family = settings.font.text,
			style = settings.font.style_map["SemiBold"],
			size = 14,
		},
		align = "right",
	},
	padding_left = -63,
	padding_right = 10,
	y_offset = 6,
	update_freq = 10,
})

local time = sbar.add("item", {
	position = "right",
	label = {
		font = {
			family = settings.font.text,
			style = settings.font.style_map["SemiBold"],
			size = 14,
		},
		align = "right",
	},
	padding_left = 20,
	y_offset = -6,
	update_freq = 10,
})

local icon = sbar.add("item", {
	position = "right",
	icon = {
		string = icons.datetime,
		color = colors.yellow,
		align = "right",
	},
	padding_left = 5,
})

date:set({
	label = os.date("%a %b %e"),
})

time:set({
	label = os.date("%H:%M"),
})

date:subscribe({ "force", "routine", "system_woke" }, function()
	date:set({
		label = os.date("%a %b %e"),
	})

	time:set({
		label = os.date("%H:%M"),
	})
end)

return {
	icon = icon,
	date = date,
	time = time,
}
