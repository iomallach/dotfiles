local colors = require("colors")
local icons = require("icons")

local tempcpu = sbar.add("item", {
	position = "right",
	background = {
		padding_right = 0,
		padding_left = 0,
	},
	icon = {
		string = icons.temperature,
		color = colors.peach,
		padding_right = 5,
		padding_left = 10,
	},
	label = {
		padding_right = 10,
		padding_left = 0,
	},
	update_freq = 10,
})

local function update_tempcpu()
	local handle = io.popen("/usr/local/bin/smctemp -c")
	local temp = handle:read("*a")
	handle:close()

	tempcpu:set({
		label = temp .. "°C",
	})
end

update_tempcpu()

tempcpu:subscribe({ "force", "routine", "system_woke" }, function()
	update_tempcpu()
end)

return tempcpu
