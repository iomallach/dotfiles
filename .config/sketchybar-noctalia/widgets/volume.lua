local sbar = require("sketchybar")
local colors = require("colors")
local icons = require("icons")
local model = require("lib.model")
local ui = require("lib.ui")

local volume = ui.pill("noctalia.volume", "right", icons.volume.medium, colors.lavender, "—", { update_freq = 30 })
ui.heading(volume, "noctalia.volume.heading", "Output volume")
local slider = sbar.add("slider", "noctalia.volume.slider", 180, {
  position = "popup." .. volume.name,
  padding_left = 20,
  padding_right = 20,
  icon = { drawing = false },
  label = { drawing = false },
  background = { drawing = false },
  slider = {
    highlight_color = colors.lavender,
    background = { height = 5, corner_radius = 3, color = colors.surface1 },
    knob = { string = "●", color = colors.text, font = { size = 13 } },
  },
})
ui.track_popup(slider, volume)
local state, busy
local function refresh()
  if busy then
    return
  end
  busy = true
  local script = [[set v to get volume settings
return ((output volume of v) as text) & "," & ((output muted of v) as text)]]
  sbar.exec("/usr/bin/osascript -e " .. model.quote(script), function(output, code)
    busy = false
    local data = code == 0 and model.volume(output)
    if not data then
      state = nil
      volume:set({ label = "—", icon = { string = icons.volume.muted, color = colors.overlay0 } })
      return
    end
    state = data
    local icon = icons.volume.high
    if data.muted or data.percent == 0 then
      icon = icons.volume.muted
    elseif data.percent < 33 then
      icon = icons.volume.low
    elseif data.percent < 67 then
      icon = icons.volume.medium
    end
    volume:set({
      icon = { string = icon, color = data.muted and colors.overlay0 or colors.lavender },
      label = data.muted and "Muted" or (data.percent .. "%"),
    })
    slider:set({ slider = { percentage = data.muted and 0 or data.percent } })
  end)
end
local function set_volume(percent)
  percent = math.floor(math.max(0, math.min(100, percent)) + 0.5)
  sbar.exec("/usr/bin/osascript -e 'set volume output volume " .. percent
    .. "' -e 'set volume output muted false'", refresh)
end
local function toggle_mute()
  sbar.exec("/usr/bin/osascript -e 'set volume output muted (not (output muted of (get volume settings)))'", refresh)
end
ui.action(volume, "noctalia.volume.mute", "Toggle mute", toggle_mute)
ui.action(volume, "noctalia.volume.settings", "Sound settings  ↗", function()
  ui.close_popup()
  sbar.exec("open 'x-apple.systempreferences:com.apple.Sound-Settings.extension'")
end)
slider:subscribe("mouse.clicked", function(env)
  local percent = tonumber(env.PERCENTAGE)
  if percent then
    set_volume(percent)
  end
end)
ui.hover_popup(volume, refresh)
volume:subscribe({ "routine", "forced", "system_woke", "volume_change" }, refresh)
volume:subscribe("mouse.clicked", function(env)
  if env.BUTTON == "right" then
    refresh()
  else
    toggle_mute()
  end
end)
volume:subscribe("mouse.scrolled", function(env)
  local delta = tonumber(env.SCROLL_DELTA) or 0
  if state and delta ~= 0 then
    set_volume(state.percent + (delta > 0 and 2 or -2))
  end
end)
refresh()
return volume
