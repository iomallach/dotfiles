local icons = require("icons")
local colors = require("colors")

local cpu = sbar.add("item", {
	position = "right",
	icon = {
		string = icons.cpu,
		color = colors.blue,
	},
	background = {
		padding_right = -200,
	},
	update_freq = 4,
})

cpu:subscribe({ "force", "routine" }, function()
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
end)
