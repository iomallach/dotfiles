local sbar = require("sketchybar")
local colors = require("colors")
local icons = require("icons")
local model = require("lib.model")
local ui = require("lib.ui")

local battery = ui.pill("noctalia.battery", "right", icons.battery.full, colors.green, "—", { update_freq = 60 })
ui.heading(battery, "noctalia.battery.heading", "Battery")
local status = ui.row(battery, "noctalia.battery.status", "Checking power source…")
local remaining = ui.row(battery, "noctalia.battery.remaining", "")
ui.action(battery, "noctalia.battery.settings", "Battery settings  ↗", function()
  ui.close_popup()
  sbar.exec("open 'x-apple.systempreferences:com.apple.Battery-Settings.extension'")
end)

local busy
local function refresh()
  if busy then
    return
  end
  busy = true
  sbar.exec("/usr/bin/pmset -g batt", function(output, code)
    busy = false
    if code ~= 0 then
      battery:set({ label = "—", icon = { color = colors.overlay0 } })
      status:set({ label = "Power information unavailable" })
      remaining:set({ label = "" })
      return
    end
    local data = model.battery(output)
    if not data then
      battery:set({ label = "AC", icon = { string = icons.battery.plug, color = colors.subtext } })
      status:set({ label = "No internal battery" })
      remaining:set({ label = "External power" })
      return
    end
    local icon = icons.battery.empty
    if data.charging then
      icon = icons.battery.charging
    elseif data.percent >= 80 then
      icon = icons.battery.full
    elseif data.percent >= 40 then
      icon = icons.battery.medium
    elseif data.percent >= 15 then
      icon = icons.battery.low
    end
    local color = colors.green
    if not data.ac then
      if data.percent <= 15 then
        color = colors.red
      elseif data.percent <= 30 then
        color = colors.yellow
      end
    end
    battery:set({ label = data.percent .. "%", icon = { string = icon, color = color } })
    status:set({ label = data.detail .. "  ·  " .. data.percent .. "%" })
    remaining:set({
      label = data.remaining and (data.remaining .. (data.charging and " until full" or " remaining"))
        or (data.percent == 100 and "Fully charged" or "Time estimate unavailable"),
    })
  end)
end
ui.hover_popup(battery, refresh)
battery:subscribe({ "routine", "forced", "system_woke", "power_source_change" }, refresh)
battery:subscribe("mouse.clicked", refresh)
refresh()
return battery
