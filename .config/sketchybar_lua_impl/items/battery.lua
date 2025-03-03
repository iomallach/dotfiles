local colors = require("colors")
local icons = require("icons")

local battery = sbar.add("item", {
	position = "right",
	background = {
		color = colors.surface0,
		border_color = colors.blue,
		border_width = 1,
	},
	update_freq = 15,
})

local function getBatteryPercentage()
	local handle = io.popen("pmset -g batt | grep -Eo '\\d+%' | cut -d% -f1")
	local percentage = handle:read("*a"):match("%d+")
	handle:close()
	return tonumber(percentage)
end

local function isCharging()
	local handle = io.popen("pmset -g batt | grep 'AC Power'")
	local chargingInfo = handle:read("*a")
	handle:close()
	return chargingInfo ~= ""
end

local function getBatteryIcon(percentage, charging)
	local state = charging and "charging" or "discharging"
	for _, entry in ipairs(icons.battery[state]) do
		if percentage >= entry.threshold then
			return entry.icon
		end
	end
end

local function update_battery()
	local percentage = getBatteryPercentage()
	local charging = isCharging()

	battery:set({
		icon = getBatteryIcon(percentage, charging),
		label = percentage .. "%",
	})
end

update_battery()

battery:subscribe({ "force", "routine", "system_woke" }, function()
	update_battery()
end)
