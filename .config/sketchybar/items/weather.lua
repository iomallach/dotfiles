local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local weather_icon = sbar.add("item", {
	position = "right",
	icon = {
		string = icons.weather,
		color = colors.sapphire,
		y_offset = 5,
		align = "right",
		font = {
			family = settings.font.text,
			style = settings.font.style_map["Bold"],
			size = 15,
		},
	},
	padding_right = 5,
	padding_left = 10,
})

local weather_temp = sbar.add("item", {
	position = "right",
	label = {
		align = "right",
		font = {
			family = settings.font.text,
			style = settings.font.style_map["Bold"],
			size = 10,
		},
	},
	y_offset = -6,
	update_freq = 100,
	padding_right = -27,
	padding_left = 10,
})

local function update_temperature()
	local http = require("socket.http")
	local cjson = require("cjson")

	-- Get IP address
	local ip = http.request("https://ipinfo.io/ip")
	if not ip then
		return
	end
	ip = ip:gsub("%s+", "") -- Trim whitespace

	-- Get location information
	local location_json = http.request("https://ipinfo.io/" .. ip .. "/json")
	if not location_json then
		return
	end

	-- Parse location JSON
	local location_data = cjson.decode(location_json)
	local location = location_data.city
	local region = location_data.region

	-- Create escaped location string
	local location_escaped = string.gsub(location, " ", "+") .. "+" .. string.gsub(region, " ", "+")

	-- Get weather information
	local weather_json = http.request("https://wttr.in/" .. location_escaped .. "?format=j1")

	-- Return on empty result
	if not weather_json or weather_json == "" then
		return
	end

	-- Parse weather JSON
	local weather_data = cjson.decode(weather_json)
	local temperature = weather_data.current_condition[1].temp_C

	weather_temp:set({
		label = temperature .. "°C",
	})
end

update_temperature()

weather_temp:subscribe({ "force", "routine", "system_woke" }, function()
	update_temperature()
end)

weather_temp:subscribe({ "mouse.clicked" }, function(env)
	update_temperature()
end)

return {
	weather_icon = weather_icon,
	weather_temp = weather_temp,
}
