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

local handle = io.popen("osascript -e 'output volume of (get volume settings)'")
local init_vol = tonumber(handle:read("*a"))
handle:close()

set_volume_icon(init_vol)

volume:subscribe("volume_change", function(env)
	local vol = tonumber(env.INFO)

	set_volume_icon(vol)
end)

return volume
