local colors = require("colors")
local cpu = require("items.cpu")
local memory = require("items.memory")
local tempcpu = require("items.tempcpu")

sbar.add("bracket", "temecpu.bracket", { cpu.name, tempcpu.name, memory.name }, {
	background = {
		color = colors.surface0,
		border_color = colors.blue,
		border_width = 1,
	},
})

sbar.add("item", {
	position = "right",
	label = "",
	padding_right = 10,
})
