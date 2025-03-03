local icons = require("icons")
local colors = require("colors")

local memory = sbar.add("item", {
	position = "right",
	icon = {
		string = icons.memory,
		color = colors.red,
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
	},
	update_freq = 15,
})

local function update_memory()
	local handle = io.popen("memory_pressure")
	local result = handle:read("*a")
	handle:close()

	local free_percentage = result:match("System%-wide memory free percentage:%s+(%d+)%%")
	local used_percentage = 100 - tonumber(free_percentage)
	local label = string.format("%02d%%", used_percentage)

	memory:set({
		label = label,
	})
end

update_memory()

-- TODO:might be better to use the guy's helpers here
memory:subscribe({ "force", "routine", "system_woke" }, function()
	update_memory()
end)

return memory
