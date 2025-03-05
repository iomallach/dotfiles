local colors = require("colors")
local icons = require("icons")

local wifi = sbar.add("item", {
	position = "right",
	icon = {
		string = icons.wifi,
		color = colors.blue,
		padding_left = 10,
	},
	label = {
		padding_right = 10,
	},
	update_freq = 15,
})

local function update_wifi()
	local handle = io.popen("ipconfig getsummary en0 | awk -F ' SSID : '  '/ SSID : / {print $2}'")
	local ssid = handle:read("*a")
	handle:close()

	wifi:set({
		label = ssid,
	})
end

update_wifi()

wifi:subscribe({ "force", "routine", "system_woke" }, function()
	update_wifi()
end)

return wifi
