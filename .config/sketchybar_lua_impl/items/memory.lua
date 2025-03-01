local icons = require("icons")
local colors = require("colors")

local memory = sbar.add("item", {
	position = "right",
	icon = {
		string = icons.memory,
		padding_left = 190,
		color = colors.red,
	},
	background = {
		color = colors.surface0,
		border_color = colors.blue,
		border_width = 1,
		padding_right = 7,
	},
	update_freq = 15,
})

-- TODO:might be better to use the guy's helpers here
memory:subscribe({ "force", "routine", "system_woke" }, function()
	local handle = io.popen("memory_pressure")
	local result = handle:read("*a")
	handle:close()

	local free_percentage = result:match("System%-wide memory free percentage:%s+(%d+)%%")
	local used_percentage = 100 - tonumber(free_percentage)
	local label = string.format("%02d%%", used_percentage)

	memory:set({
		label = label,
	})
end)
