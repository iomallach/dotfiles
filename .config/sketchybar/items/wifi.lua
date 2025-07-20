local colors = require("colors")
local icons = require("icons")

local wifi = sbar.add("item", {
	position = "right",
	icon = {
		string = icons.wifi.connected,
		color = colors.blue,
		padding_left = 10,
	},
	label = {
		padding_right = 15,
		drawing = true,
	},
	update_freq = 15,
})

local function update_wifi()
	local handle = io.popen("ipconfig getsummary en0 | awk -F ' SSID : '  '/ SSID : / {print $2}'")
	local ssid = handle:read("*a")
	handle:close()

	local icon
	local color
	if ssid == "" then
		icon = icons.wifi.disconnected
		color = colors.red
	else
		icon = icons.wifi.connected
		color = colors.blue
	end

	wifi:set({
		icon = {
			string = icon,
			color = color,
		},
	})
end

update_wifi()

wifi:subscribe({ "force", "routine", "system_woke", "wifi_change" }, function()
	update_wifi()
end)

wifi:subscribe({ "system_stats" }, function(env)
	wifi:set({
		label = {
			string = " "
				.. icons.upload
				.. " "
				.. env.NETWORK_TX_en0
				.. " "
				.. icons.download
				.. " "
				.. env.NETWORK_RX_en0,
		},
	})
end)

return wifi
