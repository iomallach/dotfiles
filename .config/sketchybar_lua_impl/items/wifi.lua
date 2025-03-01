local colors = require("colors")
local icons = require("icons")

local wifi = sbar.add("item", {
	position = "right",
	background = {
		color = colors.surface0,
		border_color = colors.blue,
		border_width = 1,
	},
	icon = {
		string = icons.wifi,
		color = colors.blue,
	},
	update_freq = 15,
})

wifi:subscribe({ "force", "routine", "system_woke" }, function()
	local handle = io.popen("ipconfig getsummary en0 | awk -F ' SSID : '  '/ SSID : / {print $2}'")
	local ssid = handle:read("*a")
	handle:close()

	wifi:set({
		label = ssid,
	})
end)
