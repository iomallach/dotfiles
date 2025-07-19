local colors = require("colors")
local icons = require("icons")

local spotify_event = "com.spotify.client.PlaybackStateChanged"
-- local whitelist = { ["Spotify"] = true }

sbar.add("event", "spotify_change", spotify_event)

local spotify = sbar.add("item", {
	position = "left",
	drawing = false,
	icon = {
		string = icons.spotify,
		y_offset = 1,
		padding_left = 1,
		padding_right = 5,
	},
	background = {
		padding_left = 10,
	},
})

local playback_icon = sbar.add("item", {
	position = "left",
	drawing = false,
	icon = {
		string = "",
		y_offset = 1,
		padding_left = 10,
		padding_right = 5,
	},
})

sbar.add("bracket", "spotify.bracket", { spotify.name, playback_icon.name }, {
	background = {
		color = colors.surface0,
		border_color = colors.blue,
		border_width = 1,
	},
})

local separator = " "

spotify:subscribe({ "spotify_change" }, function(env)
	local info = env.INFO

	local drawing = true
	local label = nil
	local icon = nil
	local playback_color = nil
	if info["Player State"] == "Playing" then
		label = info["Artist"] .. separator .. info["Name"]
		icon = icons.playing
		playback_color = colors.green
	elseif info["Player State"] == "Paused" then
		label = info["Artist"] .. separator .. info["Name"]
		icon = icons.paused
		playback_color = colors.red
	else
		drawing = false
	end

	spotify:set({
		label = {
			string = label,
		},
		drawing = drawing,
	})
	playback_icon:set({
		drawing = drawing,
		icon = {
			string = icon,
			color = playback_color,
		},
	})
end)

-- spotify:subscribe("media_change", function(env)
-- if whitelist[env.INFO.app] then
-- 	spotify:set({
-- 		label = {
-- 			drawing = true,
-- 			string = env.INFO.title .. " " .. env.INFO.artist,
-- 		},
-- 	})
-- end
-- end)
