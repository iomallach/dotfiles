local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local wifi_up = sbar.add("item", {
	position = "right",
	icon = {
		string = icons.upload,
		color = colors.red,
		font = {
			size = 15,
		},
	},
	label = {
		font = {
			family = settings.font.text,
			style = settings.font.style_map["Bold"],
			size = 10,
		},
	},
	padding_right = 5,
})

local wifi_down = sbar.add("item", {
	position = "right",
	icon = {
		string = icons.download,
		color = colors.green,
		font = {
			size = 15,
		},
	},
	label = {
		font = {
			family = settings.font.text,
			style = settings.font.style_map["Bold"],
			size = 10,
		},
	},
	padding_right = 5,
})

local wifi = sbar.add("item", {
	position = "right",
	icon = {
		string = icons.wifi.connected,
		color = colors.blue,
		padding_left = 10,
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
	wifi_up:set({
		label = {
			string = env.NETWORK_TX_en0,
		},
	})
	wifi_down:set({
		label = {
			string = env.NETWORK_RX_en0,
		},
	})
end)

return {
	wifi = wifi,
	wifi_up = wifi_up,
}
