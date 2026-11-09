local sbar = require("sketchybar")
local colors = require("colors")
local config = require("config")
local icons = require("icons")
local model = require("lib.model")
local ui = require("lib.ui")

sbar.add("event", "noctalia_spotify_change", "com.spotify.client.PlaybackStateChanged")
local spotify = ui.pill("noctalia.spotify", "left", icons.spotify, colors.green, "Spotify", {
  update_freq = config.spotify.interval,
})
local title = ui.heading(spotify, "noctalia.spotify.title", "Spotify")
local artist = ui.row(spotify, "noctalia.spotify.artist", "Not playing")
local album = ui.row(spotify, "noctalia.spotify.album", "")
local playback
local request_generation = 0
local pending_request

local function render(data)
  local playing = data.state == "playing"
  local stopped = data.state == "stopped"
  local text = stopped and "Spotify" or (data.title .. "  ·  " .. data.artist)
  spotify:set({
    icon = { string = (playing or stopped) and icons.spotify or icons.pause, color = playing and colors.green or colors.overlay0 },
    label = { string = model.truncate(text, config.spotify.max_chars), color = playing and colors.text or colors.subtext },
  })
  title:set({ label = model.truncate(stopped and "Spotify" or data.title, 34) })
  artist:set({ label = model.truncate(stopped and "Open Spotify to start listening" or data.artist, 36) })
  album:set({ label = model.truncate(data.album or "", 36) })
  playback:set({ label = playing and (icons.pause .. "  Pause") or (icons.play .. "  Play") })
end
local function render_error(reason)
  spotify:set({
    icon = { string = icons.spotify, color = colors.yellow },
    label = { string = "Spotify unavailable", color = colors.subtext },
  })
  title:set({ label = "Spotify unavailable" })
  artist:set({ label = reason })
  album:set({ label = "" })
  playback:set({ label = icons.play .. "  Play / pause" })
end

local function refresh()
  if pending_request then
    return
  end
  request_generation = request_generation + 1
  local request = request_generation
  pending_request = request
  -- A killed/stalled sbar.exec child may never deliver a callback. Expire the
  -- request so later polling/notifications can retry, and reject late replies.
  sbar.delay(8, function()
    if pending_request == request then
      pending_request = nil
      render_error("Spotify read timed out; retrying")
    end
  end)
  -- Unit separators preserve punctuation/Unicode without constructing JSON.
  -- The running check avoids launching Spotify during routine polling.
  local script = [[with timeout of 5 seconds
  if application "Spotify" is running then
    tell application "Spotify"
      if player state is stopped then return "stopped"
      set separator to ASCII character 31
      return (player state as text) & separator & (name of current track) & separator & (artist of current track) & separator & (album of current track)
    end tell
  else
    return "stopped"
  end if
end timeout]]
  -- -s o captures AppleScript errors without mixing other stderr into metadata.
  sbar.exec("/usr/bin/osascript -s o -e " .. model.quote(script) .. " 2>/dev/null", function(output, code)
    if pending_request ~= request then
      return
    end
    pending_request = nil
    if code == 0 then
      render(model.spotify(output))
    elseif tostring(output):find("-1743", 1, true) then
      render_error("Allow Automation access to Spotify")
    elseif tostring(output):find("-1712", 1, true) then
      render_error("Spotify read timed out; retrying")
    else
      render_error("Could not read Spotify; retrying")
    end
  end)
end
local function control(command)
  local script = 'if application "Spotify" is running then\n'
    .. 'tell application "Spotify" to ' .. command .. '\nend if'
  sbar.exec("/usr/bin/osascript -e " .. model.quote(script), refresh)
end
ui.action(spotify, "noctalia.spotify.previous", icons.previous .. "  Previous track", function()
  control("previous track")
end)
playback = ui.action(spotify, "noctalia.spotify.play", icons.play .. "  Play", function()
  control("playpause")
end)
ui.action(spotify, "noctalia.spotify.next", icons.next .. "  Next track", function()
  control("next track")
end)
ui.action(spotify, "noctalia.spotify.open", "Open Spotify  ↗", function()
  ui.close_popup()
  sbar.exec("open -a Spotify")
end)
ui.hover_popup(spotify, refresh)
spotify:subscribe({ "routine", "forced", "system_woke", "noctalia_spotify_change" }, refresh)
spotify:subscribe("mouse.clicked", function(env)
  if env.BUTTON == "right" then
    refresh()
  else
    control("playpause")
  end
end)
refresh()
return spotify
