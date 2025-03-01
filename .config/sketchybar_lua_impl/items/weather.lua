local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

sbar.add("item", {
	position = "right",
	icon = {
		string = icons.weather,
		color = colors.sapphire,
		y_offset = 5,
		font = {
			family = settings.font.text,
			style = settings.font.style_map["Regular"],
			size = 15,
		},
	},
	background = {
		padding_right = -50,
	},
})

local weather_temp = sbar.add("item", {
	position = "right",
	label = {
		padding_left = 0,
		padding_right = 0,
		align = "right",
		font = {
			family = settings.font.text,
			style = settings.font.style_map["Regular"],
			size = 10,
		},
	},
	background = {
		padding_right = -37,
		padding_left = 0,
	},
	y_offset = -6,
	update_freq = 600,
})

-- TODO:temperature requests are kind of broken at the moment?
weather_temp:subscribe({ "force", "routine", "system_woke" }, function()
	-- sbar:exec("curl -s https://ipinfo.io/ip", function(result)
	-- 	local ip = result
	--
	-- 	sbar:exec("curl -s https://ipinfo.io/" .. ip .. "/json", function(result)
	-- 		local location_json = result

	-- sbar:exec("echo " .. location_json .. " | jq '.city'", function(result)
	-- 	local location = result:gsub("\n", "")
	-- 	sbar:exec("echo " .. location_json .. " | jq '.region'", function(result)
	-- 		local region = result:gsub("\n", "")
	-- 		local location_escaped = location:gsub(" ", "+") .. "+" .. region:gsub(" ", "+")
	--
	-- 		sbar:exec("curl -s 'https://wttr.in/" .. location_escaped .. "?format=j1'", function(result)
	-- 			local weather_json = result
	-- 			if weather_json == "" then
	-- 				return
	-- 			end
	-- 			sbar:exec("echo " .. weather_json .. " | jq '.current_condition[0].temp_C'", function(result)
	-- 				local temperature = result:gsub("\n", "")
	-- 				weather_temp:set({
	-- 					label = temperature .. "°C",
	-- 				})
	-- 			end)
	-- 		end)
	-- 	end)
	-- end)
	-- 	end)
	-- end)
	weather_temp:set({
		label = "0°C",
	})
end)
