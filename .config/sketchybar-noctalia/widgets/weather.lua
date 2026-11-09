local sbar = require("sketchybar")
local colors = require("colors")
local config = require("config")
local icons = require("icons")
local model = require("lib.model")
local ui = require("lib.ui")

local options = config.weather
local unit = options.unit == "f" and "f" or "c"
local suffix = unit == "f" and "°F" or "°C"
local location = model.urlencode(options.location)
local weather = ui.pill("noctalia.weather", "right", icons.weather.cloud, colors.sky, "…", { update_freq = 60 })
local heading = ui.heading(weather, "noctalia.weather.heading", "Weather")
local condition = ui.row(weather, "noctalia.weather.condition", "Fetching weather…")
local detail = ui.row(weather, "noctalia.weather.detail", "")
local updated = ui.row(weather, "noctalia.weather.updated", "")
local busy, last_attempt, last_success, cached

local function render()
  if not cached then
    weather:set({ label = busy and "…" or "—", icon = { color = colors.overlay0 } })
    return
  end
  local stale = os.time() - last_success >= options.stale_after
  weather:set({
    label = string.format("%g%s%s", cached.temperature, suffix, stale and " ·" or ""),
    icon = { string = icons.weather[cached.symbol], color = stale and colors.overlay0 or colors.sky },
  })
  heading:set({ label = model.truncate(cached.city, 30) })
  condition:set({ label = model.truncate(cached.description, 34) })
  local details = {}
  if cached.feels then
    details[#details + 1] = string.format("Feels like %g%s", cached.feels, suffix)
  end
  if cached.humidity then
    details[#details + 1] = cached.humidity .. "% humidity"
  end
  detail:set({ label = table.concat(details, "  ·  ") })
  updated:set({ label = (stale and "Stale · last update " or "Updated ") .. os.date("%H:%M", last_success) })
end

local function refresh(force)
  render()
  if busy or (not force and last_attempt and os.time() - last_attempt < options.interval) then
    return
  end
  busy = true
  last_attempt = os.time()
  local url = "https://wttr.in/" .. location .. "?format=j1"
  -- One HTTPS request, no API key or Lua HTTP/JSON packages. SbarLua decodes JSON.
  sbar.exec("curl --fail --silent --show-error --connect-timeout 5 --max-time 15 "
    .. model.quote(url) .. " 2>/dev/null", function(output, code)
    busy = false
    local data = code == 0 and model.weather(output, unit)
    if data then
      cached = data
      last_success = os.time()
    elseif not cached then
      condition:set({ label = "Weather unavailable · click to retry" })
      detail:set({ label = "Check connection or configured location" })
    end
    render()
  end)
end
ui.action(weather, "noctalia.weather.refresh", "Refresh weather", function()
  refresh(true)
end)
ui.action(weather, "noctalia.weather.open", "Full forecast  ↗", function()
  ui.close_popup()
  sbar.exec("open " .. model.quote("https://wttr.in/" .. location .. (unit == "f" and "?u" or "?m")))
end)
weather:subscribe({ "routine", "forced", "system_woke" }, function(env)
  refresh(env.SENDER ~= "routine")
end)
ui.hover_popup(weather, function()
  refresh(false)
end)
weather:subscribe("mouse.clicked", function()
  refresh(not cached)
end)
refresh(true)
return weather
