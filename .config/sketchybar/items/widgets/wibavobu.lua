local colors = require("colors")
local wifi = require("items.wifi")
local battery = require("items.battery")
local volume = require("items.volume")

sbar.add("bracket", "wibavobu.bracket", { battery.name, wifi.wifi.name, wifi.wifi_up.name, volume.name }, {
	background = {
		color = colors.surface0,
		border_color = colors.blue,
		border_width = 1,
	},
})
