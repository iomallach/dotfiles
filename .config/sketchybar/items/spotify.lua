local colors = require("colors")
local icons = require("icons")

local spotify_event = "com.spotify.client.PlaybackStateChanged"
local whitelist = { ["Spotify"] = true }

sbar.add("event", "spotify_change", spotify_event)

local spotify = sbar.add("item", {
	position = "left",
	icon = {
		string = icons.spotify,
		y_offset = 1,
		padding_left = 10,
		padding_right = 5,
	},
	background = {
		border_color = colors.blue,
		border_width = 1,
		color = colors.surface0,
		padding_left = 10,
	},
	label = {
		drawing = false,
		padding_right = 10,
	},
})

spotify:subscribe({ "spotify_change" }, function(env)
	spotify:set({
		label = "Not Playing",
	})
end)

spotify:subscribe("media_change", function(env)
	if whitelist[env.INFO.app] then
		spotify:set({
			label = {
				drawing = true,
				string = env.INFO.title .. " " .. env.INFO.artist,
			},
		})
	end
end)
