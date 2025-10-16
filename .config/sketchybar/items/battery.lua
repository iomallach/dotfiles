local icons = require("icons")

local battery = sbar.add("item", {
	position = "right",
	label = {
		padding_right = 10,
	},
	icon = {
		padding_left = 10,
	},
	update_freq = 15,
})

local function getBatteryIcon(percentage, charging)
	local state = charging and "charging" or "discharging"
	for _, entry in ipairs(icons.battery[state]) do
		if percentage >= entry.threshold then
			return entry.icon
		end
	end
end

local function update_battery(output)
	local percentage = output:match("(%d+)%%")
	local charging = output:match("AC Power")

	if not percentage then
		battery:set({ label = "N/A" })
		return
	end

	battery:set({
		icon = getBatteryIcon(tonumber(percentage), charging),
		label = percentage .. "%",
	})
end

local function battery_callback_handler()
	sbar.exec("pmset -g batt", update_battery)
end

battery_callback_handler()

battery:subscribe({ "force", "routine", "system_woke", "power_source_change" }, battery_callback_handler)

return battery