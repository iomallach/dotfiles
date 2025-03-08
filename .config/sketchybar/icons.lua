return {
	datetime = "󰃰",
	weather = "",
	memory = "",
	cpu = " ",
	temperature = "",
	wifi = {
		connected = " ",
		disconnected = "󰖪",
	},
	spotify = " ",
	battery = {
		charging = {
			{ threshold = 90, icon = "󰂋" },
			{ threshold = 60, icon = "󰂊" },
			{ threshold = 30, icon = "󰂉" },
			{ threshold = 10, icon = "󰂇" },
			{ threshold = 0, icon = "󰢜" },
		},
		discharging = {
			{ threshold = 90, icon = "󰂂" },
			{ threshold = 60, icon = "󰁿" },
			{ threshold = 30, icon = "󰁾" },
			{ threshold = 10, icon = "󰁻" },
			{ threshold = 0, icon = "󰁺" },
		},
	},
	volume = {
		{ threshold = 70, icon = "􀊩" },
		{ threshold = 50, icon = "􀊧" },
		{ threshold = 20, icon = "􀊥" },
		{ threshold = 1, icon = "􀊡" },
		{ threshold = 0, icon = "􀊣" },
	},
}
