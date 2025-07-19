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
		padding_right = 10,
		drawing = true,
	},
	update_freq = 15,
})

local drawing_label = true

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

	if not drawing_label then
		ssid = ""
	end

	wifi:set({
		label = {
			string = ssid,
		},
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

wifi:subscribe({ "mouse.clicked" }, function(env)
	drawing_label = not drawing_label
	update_wifi()
end)

return wifi
