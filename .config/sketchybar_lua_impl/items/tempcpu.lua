local colors = require("colors")
local icons = require("icons")

local tempcpu = sbar.add("item", {
	position = "right",
	background = {
		padding_right = -20,
	},
	icon = {
		string = icons.temperature,
		color = colors.peach,
	},
	update_freq = 10,
})

tempcpu:subscribe({ "force", "routine", "system_woke" }, function()
	local handle = io.popen("/usr/local/bin/smctemp -c")
	local temp = handle:read("*a")
	handle:close()

	tempcpu:set({
		label = temp .. "°C",
	})
end)
