local colors = require("colors")
local icons = require("icons")

local clock = sbar.add("item", {
	position = "right",
	background = {
		border_color = colors.blue,
		border_width = 1,
		padding_left = 0,
		color = colors.surface0,
	},
	icon = {
		string = icons.datetime,
		color = colors.yellow,
		padding_left = 40,
	},
	update_freq = 10,
})

clock:subscribe({ "force", "routine", "system_woke" }, function()
	clock:set({
		label = os.date("%a %b %e %H:%M"),
	})
end)
