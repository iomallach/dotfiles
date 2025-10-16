local icons = require("icons")
local colors = require("colors")

local volume = sbar.add("item", {
	position = "right",
	label = {
		padding_right = 10,
	},
	icon = {
		padding_left = 10,
		color = colors.lavender,
	},
})

local function set_volume_icon(vol)
	for _, entry in ipairs(icons.volume) do
		if vol >= entry.threshold then
			volume:set({
				icon = entry.icon,
				label = {
					string = vol .. "%",
					padding_left = 10,
				},
			})
			break
		end
	end
end

local function initial_volume_callback(output)
	local vol = tonumber(output)
	if vol then
		set_volume_icon(vol)
	end
end

sbar.exec("osascript -e 'output volume of (get volume settings)'", initial_volume_callback)

volume:subscribe("volume_change", function(env)
	local vol = tonumber(env.INFO)

	set_volume_icon(vol)
end)

return volume

