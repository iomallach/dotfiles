local colors = require("colors")
local clock = require("items.clock")
local weather = require("items.weather")

sbar.add(
	"bracket",
	"cweather.bracket",
	{ weather.weather_icon.name, weather.weather_temp.name, clock.date.name, clock.time.name, clock.icon.name },
	{
		background = {
			color = colors.surface0,
			border_color = colors.blue,
			border_width = 1,
		},
	}
)

sbar.add("item", {
	position = "right",
	label = "",
	padding_right = 10,
})
