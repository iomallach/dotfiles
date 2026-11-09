local sbar = require("sketchybar")
local colors = require("colors")
local config = require("config")
local icons = require("icons")
local model = require("lib.model")
local ui = require("lib.ui")

local bluetooth = ui.pill("noctalia.bluetooth", "right", icons.bluetooth.on, colors.sky, "…", {
  update_freq = config.bluetooth.interval,
})
local heading = ui.heading(bluetooth, "noctalia.bluetooth.heading", "Bluetooth")
heading:set({ width = 300 })
local status = ui.row(bluetooth, "noctalia.bluetooth.status", "Checking connected devices…", { width = 300 })
local settings = ui.action(bluetooth, "noctalia.bluetooth.settings", "Bluetooth settings  ↗", function()
  ui.close_popup()
  sbar.exec("open 'x-apple.systempreferences:com.apple.BluetoothSettings'")
end)
settings:set({ width = 300 })

local rows = {}
local function device_icon(kind)
  kind = kind:lower()
  if kind:find("keyboard", 1, true) then
    return icons.bluetooth.keyboard
  elseif kind:find("mouse", 1, true) then
    return icons.bluetooth.mouse
  elseif kind:find("head", 1, true) then
    return icons.bluetooth.headphones
  end
  return icons.bluetooth.on
end

local function render(data)
  if not data then
    bluetooth:set({ label = "—", icon = { string = icons.bluetooth.on, color = colors.overlay0 } })
    status:set({ label = "Bluetooth information unavailable" })
  else
    local count = #data.devices
    local icon = icons.bluetooth.off
    if data.enabled then
      icon = count > 0 and icons.bluetooth.connected or icons.bluetooth.on
    end
    bluetooth:set({
      label = tostring(count),
      icon = { string = icon, color = count > 0 and colors.sky or colors.overlay0 },
    })
    local text = "Bluetooth is off"
    if data.enabled then
      if count == 0 then
        text = "No connected devices"
      else
        text = count .. (count == 1 and " connected device" or " connected devices")
      end
    end
    status:set({ label = text })
    for index, device in ipairs(data.devices) do
      if not rows[index] then
        local prefix = "noctalia.bluetooth.device." .. index
        rows[index] = {
          name = ui.row(bluetooth, prefix .. ".name", "", {
            width = 300,
            icon = { drawing = true, color = colors.lavender, padding_left = 12, padding_right = 6, font = { size = 14 } },
            label = { padding_left = 0, color = colors.text, font = { style = "Semibold", size = 13 } },
          }),
          battery = ui.row(bluetooth, prefix .. ".battery", "", { width = 300 }),
        }
      end
      local parts = {}
      for _, battery in ipairs(device.batteries) do
        parts[#parts + 1] = battery.label .. " " .. battery.percent .. "%"
      end
      local detail = #parts > 0 and table.concat(parts, "  ·  ") or (device.kind .. " · Battery not reported")
      rows[index].name:set({ drawing = true, label = model.truncate(device.name, 36), icon = { string = device_icon(device.kind) } })
      rows[index].battery:set({ drawing = true, label = detail })
    end
  end
  -- Reuse rows between refreshes and hide entries that disconnected or failed.
  local count = data and #data.devices or 0
  for index = count + 1, #rows do
    rows[index].name:set({ drawing = false })
    rows[index].battery:set({ drawing = false })
  end
end

local busy
local function refresh()
  if busy then
    return
  end
  busy = true
  sbar.exec("/usr/sbin/system_profiler SPBluetoothDataType -json -detailLevel full -timeout 10 2>/dev/null", function(output, code)
    local data = code == 0 and model.bluetooth(output) or nil
    if data then
      for _, device in ipairs(data.devices) do
        if #device.batteries == 0 then
          sbar.exec("/usr/bin/pmset -g accps 2>/dev/null", function(power_output, power_code)
            busy = false
            if power_code == 0 then
              model.merge_accessory_batteries(data, power_output)
            end
            render(data)
          end)
          return
        end
      end
    end
    busy = false
    render(data)
  end)
end
ui.hover_popup(bluetooth, refresh)
bluetooth:subscribe({ "routine", "forced", "system_woke" }, refresh)
bluetooth:subscribe("mouse.clicked", refresh)
refresh()
return bluetooth
