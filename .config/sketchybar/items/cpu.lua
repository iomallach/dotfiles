local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

local icon = {
	string = icons.cpu,
	color = colors.blue,
	padding_right = 5,
	padding_left = 10,
}

local background = {
	padding_right = 0,
	padding_left = 0,
}

local cpu_graph = sbar.add("graph", 42, {
	position = "right",
	icon = icon,
	background = background,
	graph = {
		color = colors.blue,
		line_width = 1,
	},
	label = {
		padding_right = 10,
		padding_left = 2,
		font = {
			family = settings.font.text,
			style = settings.font.style_map["Bold"],
		},
	},
	drawing = true,
})

cpu_graph:subscribe({ "mouse.clicked" }, function(env)
	sbar.exec("open -a 'Activity Monitor'")
end)

cpu_graph:subscribe({ "system_stats" }, function(env)
	local stat = string.gsub(env.CPU_USAGE, "%%", "")
	cpu_graph:push({ tonumber(stat) / 100. })
	cpu_graph:set({
		label = env.CPU_USAGE,
	})
end)

cpu_graph:subscribe({ "mouse.clicked" }, function(env)
	sbar.exec("open -a 'Activity Monitor'")
end)

return cpu_graph
