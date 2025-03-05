local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

local cpu = sbar.add("item", {
	position = "right",
	icon = {
		string = icons.cpu,
		color = colors.blue,
		padding_right = 5,
		padding_left = 10,
	},
	background = {
		padding_right = 0,
		padding_left = 0,
	},
	label = {
		padding_right = 10,
		padding_left = 0,
		font = {
			family = settings.font.text,
			style = settings.font.style_map["Bold"],
		},
	},
	update_freq = 4,
})
local function update_cpu()
	local handle = io.popen("sysctl -n hw.ncpu")
	local ncpu = handle:read("*a"):match("%d+")
	handle:close()

	handle = io.popen("ps -A -o %cpu | awk '{s+=$1} END {printf s}'")
	local total_percent = handle:read("*a"):match("%d+%.?%d*")
	handle:close()

	local cpu_usage = tonumber(total_percent) / tonumber(ncpu)
	local formatted_cpu_usage = string.format("%.2f%%", cpu_usage)

	cpu:set({
		label = formatted_cpu_usage,
	})
end

update_cpu()

cpu:subscribe({ "force", "routine" }, function()
	update_cpu()
end)

return cpu
