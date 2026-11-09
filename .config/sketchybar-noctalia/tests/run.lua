local root = (arg[0]:match("^(.*)/tests/run.lua$") or ".")
package.path = root .. "/?.lua;" .. root .. "/?/init.lua;" .. package.path
local model = require("lib.model")
local passed = 0
local function equal(actual, expected)
  assert(actual == expected, string.format("expected %s, got %s", tostring(expected), tostring(actual)))
end
local function test(name, callback)
  local ok, error_message = pcall(callback)
  if not ok then
    error(name .. ": " .. tostring(error_message), 0)
  end
  passed = passed + 1
  print("ok - " .. name)
end

local weather_data = {
  current_condition = { {
    temp_C = "-2", temp_F = "28", FeelsLikeC = "-5", FeelsLikeF = "23",
    weatherCode = "113", weatherDesc = { { value = "Clear" } },
    humidity = "70", localObsDateTime = "2026-11-09 09:30 PM",
  } },
  nearest_area = { { areaName = { { value = "Berlin" } } } },
}

local function bluetooth_report(state, connected)
  return { SPBluetoothDataType = { {
    controller_properties = { controller_state = state },
    device_connected = connected or {},
    device_not_connected = { { ["Old speaker"] = { device_minorType = "Speaker" } } },
  } } }
end
local bluetooth_data = bluetooth_report("attrib_on", {
  { ["Studio Buds"] = { device_minorType = "Headphones", device_address = "aa:01",
    device_batteryLevelLeft = "83%", device_batteryLevelRight = "79%", device_batteryLevelCase = "45%" } },
  { Keyboard = { device_minorType = "Keyboard", device_address = "aa:02", device_batteryLevelMain = "50%" } },
  { Mouse = { device_minorType = "Mouse", device_address = "aa:03" } },
})

local accessory_data = [[Now drawing from 'AC Power'
 -InternalBattery-0 (id=123) 100%; charged; 0:00 remaining present: true
 - mOuSe   (id=456) 80%;
 -Keyboard (id=457) 90%;
 -Studio Buds (id=458) 10%;
 -Old speaker (id=459) 99%;
]]

test("shell quoting and URL encoding keep user input literal", function()
  equal(model.quote("O'Brien; $(id)"), "'O'\\''Brien; $(id)'")
  equal(model.urlencode("New York/52,13"), "New%20York%2F52%2C13")
end)
test("Unicode truncation does not split codepoints", function()
  equal(model.truncate("Björk · 東京", 8), "Björk ·…")
  equal(model.truncate("  one\ntwo  ", 20), "one two")
end)
test("volume distinguishes mute from zero and rejects malformed values", function()
  equal(model.volume("13,false\n").percent, 13)
  equal(model.volume("65,true").muted, true)
  equal(model.volume("0,false").muted, false)
  equal(model.volume("101,false"), nil)
  equal(model.volume("garbage"), nil)
end)
test("battery distinguishes charging, discharging and charge limiting", function()
  local data = model.battery("Now drawing from 'AC Power'\n-InternalBattery-0 71%; charging; 1:10 remaining")
  equal(data.charging, true)
  equal(data.remaining, "1:10")
  data = model.battery("Now drawing from 'Battery Power'\n15%; discharging; 0:30 remaining")
  equal(data.charging, false)
  equal(data.ac, false)
  data = model.battery("Now drawing from 'AC Power'\n80%; AC attached; not charging present: true")
  equal(data.charging, false)
  equal(data.ac, true)
  equal(model.battery("Now drawing from 'AC Power'"), nil)
end)
test("weather parses both units and absent optional details", function()
  local data = model.weather(weather_data, "c")
  equal(data.temperature, -2)
  equal(data.feels, -5)
  equal(data.city, "Berlin")
  equal(model.weather(weather_data, "f").temperature, 28)
  data = model.weather({ current_condition = { { temp_C = "0", weatherCode = "122" } } }, "c")
  equal(data.symbol, "cloud")
  equal(data.city, "Local weather")
  equal(model.weather({ current_condition = { { temp_C = "0", weatherCode = "122" } } }, "f"), nil)
  equal(model.weather("<html>Bad Gateway</html>", "c"), nil)
  equal(model.weather({ current_condition = {} }, "c"), nil)
end)
test("weather handles night observations and unknown condition codes", function()
  local current = { temp_C = "10", weatherCode = "113", localObsDateTime = "2026-11-09 09:30 PM" }
  local data = { current_condition = { current } }
  equal(model.weather(data, "c").symbol, "moon")
  current.localObsDateTime = "2026-11-09 09:30 AM"
  equal(model.weather(data, "c").symbol, "sun")
  current.weatherCode = "999"
  current.weatherDesc = "invalid description"
  data.nearest_area = { false }
  equal(model.weather(data, "c").symbol, "unknown")
end)
test("Spotify preserves delimiters in track names and handles stopped state", function()
  local data = model.spotify("playing\31Song | '東京'\31Björk\31Album\n")
  equal(data.title, "Song | '東京'")
  equal(data.artist, "Björk")
  equal(model.spotify("paused\31Track\31Artist\31").state, "paused")
  equal(model.spotify("stopped\n").state, "stopped")
end)
test("workspace cycling wraps and preserves arbitrary names", function()
  local list = model.workspaces("1\n2\nO'Brien\n")
  equal(model.adjacent(list, "1", -1), "O'Brien")
  equal(model.adjacent(list, "O'Brien", 1), "1")
  equal(model.adjacent({}, "1", 1), nil)
end)
test("Bluetooth counts only connected devices and parses reported battery components", function()
  local data = model.bluetooth(bluetooth_data)
  equal(data.enabled, true)
  equal(#data.devices, 3)
  equal(data.devices[1].name, "Keyboard")
  equal(data.devices[1].batteries[1].percent, 50)
  equal(data.devices[2].name, "Mouse")
  equal(#data.devices[2].batteries, 0)
  equal(data.devices[3].name, "Studio Buds")
  equal(data.devices[3].batteries[1].label, "Left")
  equal(data.devices[3].batteries[2].percent, 79)
  equal(data.devices[3].batteries[3].label, "Case")
end)
test("Bluetooth accepts zero charge and rejects unavailable battery values", function()
  local data = model.bluetooth(bluetooth_report("attrib_on", {
    { Keyboard = { device_batteryLevelMain = "0%", device_batteryLevelLeft = "101%",
      device_batteryLevelRight = "unknown", device_batteryLevelCase = "-1%" } },
    { Mouse = { device_batteryLevelSingle = 100 } },
  }))
  equal(#data.devices[1].batteries, 1)
  equal(data.devices[1].batteries[1].percent, 0)
  equal(data.devices[2].batteries[1].percent, 100)
end)
test("Bluetooth distinguishes disabled, empty, and malformed reports", function()
  local data = model.bluetooth(bluetooth_report("attrib_on"))
  equal(data.enabled, true)
  equal(#data.devices, 0)
  data = model.bluetooth(bluetooth_report("attrib_off", { { Stale = {} } }))
  equal(data.enabled, false)
  equal(#data.devices, 0)
  equal(model.bluetooth("malformed"), nil)
  equal(model.bluetooth({ SPBluetoothDataType = {} }), nil)
  equal(model.bluetooth(bluetooth_report("unknown")), nil)
  equal(model.bluetooth(bluetooth_report("attrib_on", "bad connected list")), nil)
end)
test("Bluetooth deduplicates addresses but keeps separate unnamed-address devices", function()
  local data = bluetooth_report("attrib_on", { { Mouse = { device_address = "AA:01" } } })
  data.SPBluetoothDataType[2] = bluetooth_report("attrib_on", { { Duplicate = { device_address = "aa:01" } } }).SPBluetoothDataType[1]
  equal(#model.bluetooth(data).devices, 1)
  data = bluetooth_report("attrib_on", { { Mouse = {} }, { Mouse = {} } })
  equal(#model.bluetooth(data).devices, 2)
end)
test("accessory power parses names and valid zero levels without the internal battery", function()
  local levels = model.accessory_batteries(accessory_data
    .. " -Jane's Mouse (USB-C) (id=460)\t100%;\r\n -鍵盤 (id=461)\t0%;\n")
  equal(levels.mouse, 80)
  equal(levels.keyboard, 90)
  equal(levels["jane's mouse (usb-c)"], 100)
  equal(levels["鍵盤"], 0)
  equal(levels["internalbattery-0"], nil)
end)
test("accessory power rejects ambiguous names and invalid readings", function()
  local levels = model.accessory_batteries([[
 -Mouse (id=1) 50%;
 - mouse (id=2) 60%;
 -MOUSE (id=3) 70%;
 -Over (id=4) 101%;
 -Negative (id=5) -1%;
 -Unknown (id=6) unknown;
 malformed output
]])
  equal(next(levels), nil)
  equal(next(model.accessory_batteries({})), nil)
end)
test("accessory fallback supplements connected devices without replacing native batteries", function()
  local data = model.merge_accessory_batteries(model.bluetooth(bluetooth_data), accessory_data)
  equal(#data.devices, 3)
  equal(data.devices[1].batteries[1].percent, 50)
  equal(data.devices[2].batteries[1].percent, 80)
  equal(data.devices[3].batteries[1].label, "Left")
  equal(data.devices[3].batteries[1].percent, 83)
  equal(#data.devices[3].batteries, 3)
  data = model.merge_accessory_batteries(model.bluetooth(bluetooth_data), " -Mouse Extra (id=456) 80%;")
  equal(#data.devices[2].batteries, 0)
end)
test("accessory fallback does not guess between duplicate connected names", function()
  local data = model.bluetooth(bluetooth_report("attrib_on", { { Mouse = {} }, { [" mouse "] = {} } }))
  model.merge_accessory_batteries(data, accessory_data)
  equal(#data.devices, 2)
  equal(#data.devices[1].batteries, 0)
  equal(#data.devices[2].batteries, 0)
end)
test("calendar starts Monday and handles leap years and six-week months", function()
  local rows = model.calendar(os.time({ year = 2024, month = 2, day = 1, hour = 12 }))
  equal(rows[1], "Mo Tu We Th Fr Sa Su")
  equal(rows[2], "          1  2  3  4")
  assert(table.concat(rows):find("29", 1, true))
  rows = model.calendar(os.time({ year = 2026, month = 3, day = 1, hour = 12 }))
  equal(#rows, 7)
  equal(rows[7], "30 31")
end)

test("calendar locates today across weekday, month, and leap-year boundaries", function()
  for _, date in ipairs({
    { year = 2024, month = 2, day = 29, row = 6, column = 4 },
    { year = 2026, month = 3, day = 1, row = 2, column = 7 },
    { year = 2026, month = 3, day = 31, row = 7, column = 2 },
    { year = 2026, month = 11, day = 9, row = 4, column = 1 },
    { year = 2026, month = 12, day = 31, row = 6, column = 4 },
    { year = 2027, month = 1, day = 1, row = 2, column = 5 },
  }) do
    local rows, today = model.calendar(os.time({ year = date.year, month = date.month, day = date.day, hour = 12 }))
    equal(today.day, date.day)
    equal(today.row, date.row)
    equal(today.column, date.column)
    local start = (today.column - 1) * 3 + 1
    equal(rows[today.row]:sub(start, start + 1), string.format("%2d", date.day))
  end
end)

-- Exercise the real configuration with fake asynchronous macOS/network results.
-- No commands, GUI actions, audio changes, or network requests are executed.
local items, events, commands, pending, timers = {}, {}, {}, {}, {}
local bar_properties, instance_name
local failures = {}
local bluetooth_response = bluetooth_data
local accessory_response = ""
local spotify_default = "playing\31Test track\31Test artist\31Test album"
local spotify_response, spotify_code = spotify_default, 0
local hold_spotify, held_spotify = false, {}
local function merge(target, values)
  for key, value in pairs(values) do
    if type(value) == "table" then
      if type(target[key]) ~= "table" then
        target[key] = {}
      end
      merge(target[key], value)
    else
      target[key] = value
    end
  end
end
local function response(command)
  if command:find("list-workspaces --focused", 1, true) then
    return failures.aerospace and "" or "1\n", failures.aerospace and 1 or 0
  elseif command:find("list-workspaces --all", 1, true) then
    return "1\n2\n3\n", 0
  elseif command:find("system_profiler SPBluetoothDataType", 1, true) then
    return failures.bluetooth and "" or bluetooth_response, failures.bluetooth and 1 or 0
  elseif command:find("pmset -g accps", 1, true) then
    return failures.accessories and "" or accessory_response, failures.accessories and 1 or 0
  elseif command:find("pmset", 1, true) then
    return failures.battery and "" or "Now drawing from 'Battery Power'\n45%; discharging; 2:10 remaining", failures.battery and 1 or 0
  elseif command:find("set v to get volume settings", 1, true) then
    return failures.volume and "" or "13,false", failures.volume and 1 or 0
  elseif command:find("curl ", 1, true) then
    return failures.weather and "Bad Gateway" or weather_data, failures.weather and 1 or 0
  elseif command:find("set separator", 1, true) then
    if failures.spotify then
      return "stopped", 0
    end
    return spotify_response, spotify_code
  end
  return "", 0
end
local mock = {
  set_bar_name = function(name) instance_name = name end,
  begin_config = function() end,
  end_config = function() end,
  bar = function(properties) bar_properties = properties end,
  default = function() end,
  animate = function(_, _, callback) callback() end,
  delay = function(_, callback) timers[#timers + 1] = callback end,
  exec = function(command, callback)
    commands[#commands + 1] = command
    if callback then
      if hold_spotify and command:find("set separator", 1, true) then
        held_spotify[#held_spotify + 1] = callback
      else
        pending[#pending + 1] = function() callback(response(command)) end
      end
    end
  end,
}
function mock.add(kind, name, value, properties)
  if kind == "event" then
    events[name] = value or true
    return
  end
  assert(not items[name], "Duplicate item: " .. name)
  local item = { name = name, properties = {}, subscriptions = {} }
  merge(item.properties, properties or value)
  function item:set(values) merge(self.properties, values) end
  function item:subscribe(names, callback)
    for _, event in ipairs(type(names) == "table" and names or { names }) do
      self.subscriptions[event] = callback
    end
  end
  items[name] = item
  return item
end
local function drain()
  while #pending > 0 do
    local work = pending
    pending = {}
    for _, callback in ipairs(work) do callback() end
  end
end
local function flush_timers()
  local work = timers
  timers = {}
  for _, callback in ipairs(work) do callback() end
  drain()
end
mock.event_loop = drain
package.preload.sketchybar = function() return mock end
local function emit(name, event, env)
  local item = assert(items["noctalia." .. name])
  local callback = assert(item.subscriptions[event], "Missing subscription: " .. event)
  env = env or {}
  env.SENDER = event
  callback(env)
  drain()
end
local function label(name)
  local value = items["noctalia." .. name].properties.label
  return type(value) == "table" and value.string or value
end

test("complete configuration initializes all requested widgets", function()
  local original_arg = arg
  arg = { [0] = root .. "/init.lua" }
  dofile(root .. "/init.lua")
  arg = original_arg
  equal(instance_name, os.getenv("BAR_NAME") or "sketchybar")
  equal(bar_properties.color, 0x00000000)
  equal(bar_properties.topmost, "window")
  equal(bar_properties.hidden, os.getenv("NOCTALIA_HIDDEN") == "1")
  equal(label("workspace"), "1")
  equal(label("battery"), "45%")
  equal(label("volume"), "13%")
  equal(label("bluetooth"), "3")
  equal(label("weather"), "-2°C")
  equal(label("spotify"), "Test track · Test artist")
  assert(label("clock"):match("%d%d:%d%d"))
  equal(events.noctalia_spotify_change, "com.spotify.client.PlaybackStateChanged")
end)
test("calendar highlights only today and clears stale highlights on refresh", function()
  -- Simulate an old highlight on every row; a refresh must reset all of them.
  for index = 1, 7 do
    items["noctalia.clock.week." .. index]:set({ icon = { drawing = true } })
  end
  emit("clock", "routine")
  local calendar, today = model.calendar()
  local highlighted = 0
  for index = 1, 7 do
    local row = items["noctalia.clock.week." .. index].properties
    local text = label("clock.week." .. index)
    if row.icon.drawing then
      highlighted = highlighted + 1
      equal(index, today.row)
      equal(row.icon.string, string.format("%2d", today.day))
      equal(row.icon.color, require("colors").mauve)
      local start = (today.column - 1) * 3 + 1
      equal(text:sub(start, start + 1), "  ")
      text = text:sub(1, start - 1) .. row.icon.string .. text:sub(start + 2)
    end
    equal(text, calendar[index] or "")
    equal(row.drawing, calendar[index] ~= nil)
  end
  equal(highlighted, 1)
end)
test("workspace event works immediately without changing AeroSpace hooks", function()
  emit("workspace", "aerospace_workspace_change", { FOCUSED_WORKSPACE = "7" })
  equal(label("workspace"), "7")
end)
test("Spotify recovers from a lost callback and ignores late replies", function()
  hold_spotify = true
  emit("spotify", "routine")
  emit("spotify", "noctalia_spotify_change")
  equal(#held_spotify, 1)
  local stale = held_spotify[1]
  flush_timers()
  equal(label("spotify"), "Spotify unavailable")
  equal(label("spotify.artist"), "Spotify read timed out; retrying")
  emit("spotify", "routine")
  equal(#held_spotify, 2)
  stale("playing\31Old track\31Old artist\31Old album", 0)
  equal(label("spotify"), "Spotify unavailable")
  held_spotify[2]("playing\31Fresh track\31Artist\31Album", 0)
  equal(label("spotify"), "Fresh track · Artist")
  stale("playing\31Old track\31Old artist\31Old album", 0)
  equal(label("spotify"), "Fresh track · Artist")
  hold_spotify, held_spotify = false, {}
  spotify_response, spotify_code = spotify_default, 0
  emit("spotify", "routine")
end)
test("Spotify distinguishes read errors from a genuinely stopped player", function()
  for _, case in ipairs({
    { output = "Not authorized to send Apple events (-1743)", reason = "Allow Automation access to Spotify" },
    { output = "AppleEvent timed out (-1712)", reason = "Spotify read timed out; retrying" },
    { output = "Cannot read current track (-1728)", reason = "Could not read Spotify; retrying" },
  }) do
    spotify_response, spotify_code = case.output, 1
    emit("spotify", "routine")
    equal(label("spotify"), "Spotify unavailable")
    equal(label("spotify.artist"), case.reason)
    equal(label("spotify.album"), "")
  end
  spotify_response, spotify_code = spotify_default, 0
  emit("spotify", "routine")
  equal(label("spotify"), "Test track · Test artist")
end)
test("Bluetooth hover lists names, component batteries, and explicitly missing levels", function()
  emit("bluetooth", "mouse.entered")
  equal(items["noctalia.bluetooth"].properties.popup.drawing, true)
  equal(label("bluetooth.status"), "3 connected devices")
  equal(label("bluetooth.device.1.name"), "Keyboard")
  equal(label("bluetooth.device.1.battery"), "Battery 50%")
  equal(label("bluetooth.device.2.battery"), "Mouse · Battery not reported")
  equal(label("bluetooth.device.3.battery"), "Left 83%  ·  Right 79%  ·  Case 45%")
  emit("bluetooth", "mouse.exited")
  emit("bluetooth.device.1.name", "mouse.entered")
  flush_timers()
  equal(items["noctalia.bluetooth"].properties.popup.drawing, true)
  emit("bluetooth.device.1.name", "mouse.exited")
  flush_timers()
  equal(items["noctalia.bluetooth"].properties.popup.drawing, false)
end)
test("Bluetooth refresh reuses rows and hides disconnected devices", function()
  bluetooth_response = bluetooth_report("attrib_on", { { Replacement = { device_batteryLevelMain = "0%" } } })
  emit("bluetooth", "routine")
  equal(label("bluetooth"), "1")
  equal(label("bluetooth.device.1.name"), "Replacement")
  equal(label("bluetooth.device.1.battery"), "Battery 0%")
  equal(items["noctalia.bluetooth.device.2.name"].properties.drawing, false)
  equal(items["noctalia.bluetooth.device.3.battery"].properties.drawing, false)
  bluetooth_response = bluetooth_report("attrib_on")
  emit("bluetooth", "routine")
  equal(label("bluetooth"), "0")
  equal(label("bluetooth.status"), "No connected devices")
  equal(items["noctalia.bluetooth.device.1.name"].properties.drawing, false)
  bluetooth_response = bluetooth_report("attrib_off")
  emit("bluetooth", "routine")
  equal(label("bluetooth"), "0")
  equal(label("bluetooth.status"), "Bluetooth is off")
  bluetooth_response = bluetooth_data
  emit("bluetooth", "routine")
  equal(label("bluetooth"), "3")
  equal(items["noctalia.bluetooth.device.3.name"].properties.drawing, true)
end)
test("Bluetooth refresh displays accessory levels and clears missing readings", function()
  accessory_response = accessory_data
  emit("bluetooth", "mouse.entered")
  equal(label("bluetooth"), "3")
  equal(label("bluetooth.device.1.battery"), "Battery 50%")
  equal(label("bluetooth.device.2.battery"), "Battery 80%")
  equal(label("bluetooth.device.3.battery"), "Left 83%  ·  Right 79%  ·  Case 45%")
  accessory_response = ""
  emit("bluetooth", "routine")
  equal(label("bluetooth"), "3")
  equal(label("bluetooth.device.2.battery"), "Mouse · Battery not reported")
  emit("bluetooth", "mouse.exited")
  flush_timers()
end)
test("accessory query failure preserves the connected list and native battery data", function()
  accessory_response = accessory_data
  emit("bluetooth", "routine")
  equal(label("bluetooth.device.2.battery"), "Battery 80%")
  failures.accessories = true
  emit("bluetooth", "routine")
  equal(label("bluetooth"), "3")
  equal(label("bluetooth.status"), "3 connected devices")
  equal(label("bluetooth.device.1.battery"), "Battery 50%")
  equal(label("bluetooth.device.2.battery"), "Mouse · Battery not reported")
  equal(label("bluetooth.device.3.battery"), "Left 83%  ·  Right 79%  ·  Case 45%")
  failures.accessories = false
  accessory_response = ""
end)
test("all detail popups open on hover without playback or mute actions", function()
  local before = #commands
  for _, name in ipairs({ "clock", "battery", "weather", "volume", "bluetooth", "spotify" }) do
    emit(name, "mouse.entered")
    equal(items["noctalia." .. name].properties.popup.drawing, true)
    equal(items["noctalia." .. name].properties.popup.y_offset, 0)
    equal(items["noctalia." .. name].subscriptions["mouse.exited.global"], nil)
  end
  for index = before + 1, #commands do
    assert(not commands[index]:find("to playpause", 1, true))
    assert(not commands[index]:find("set volume output muted", 1, true))
  end
end)
test("hover switching is exclusive and late exits cannot close another popup", function()
  emit("clock", "mouse.entered")
  emit("clock", "mouse.entered")
  emit("clock", "mouse.clicked")
  equal(items["noctalia.clock"].properties.popup.drawing, true)
  emit("battery", "mouse.entered")
  equal(items["noctalia.clock"].properties.popup.drawing, false)
  emit("clock", "mouse.exited")
  equal(items["noctalia.battery"].properties.popup.drawing, true)
  emit("battery", "mouse.exited")
  flush_timers()
  equal(items["noctalia.battery"].properties.popup.drawing, false)
end)
test("popup row and slider entry cancel pending closes until the pointer leaves", function()
  emit("clock", "mouse.entered")
  emit("clock", "mouse.exited")
  emit("clock.heading", "mouse.entered")
  flush_timers()
  equal(items["noctalia.clock"].properties.popup.drawing, true)
  emit("clock.heading", "mouse.exited")
  emit("clock.week.1", "mouse.entered")
  flush_timers()
  equal(items["noctalia.clock"].properties.popup.drawing, true)
  emit("clock.week.1", "mouse.exited")
  flush_timers()
  equal(items["noctalia.clock"].properties.popup.drawing, false)
  emit("volume", "mouse.entered")
  emit("volume", "mouse.exited")
  emit("volume.slider", "mouse.entered")
  flush_timers()
  equal(items["noctalia.volume"].properties.popup.drawing, true)
  emit("volume.slider", "mouse.exited")
  flush_timers()
  equal(items["noctalia.volume"].properties.popup.drawing, false)
end)
test("popups close on host exit, sleep, and workspace hover", function()
  emit("weather", "mouse.entered")
  emit("workspace", "mouse.entered")
  equal(items["noctalia.weather"].properties.popup.drawing, false)
  equal(items["noctalia.workspace"].properties.popup.drawing, nil)
  emit("volume", "mouse.entered")
  emit("volume", "mouse.exited")
  flush_timers()
  equal(items["noctalia.volume"].properties.popup.drawing, false)
  emit("spotify", "mouse.entered")
  emit("spotify", "system_will_sleep")
  equal(items["noctalia.spotify"].properties.popup.drawing, false)
end)
test("direct media and mute clicks still work without toggling popups", function()
  emit("spotify", "mouse.entered")
  local before = #commands
  emit("spotify", "mouse.clicked", { BUTTON = "left" })
  assert(commands[before + 1]:find("to playpause", 1, true))
  emit("spotify", "mouse.clicked", { BUTTON = "right" })
  equal(items["noctalia.spotify"].properties.popup.drawing, true)
  emit("volume", "mouse.entered")
  before = #commands
  emit("volume", "mouse.clicked", { BUTTON = "left" })
  assert(commands[before + 1]:find("set volume output muted (not", 1, true))
  emit("volume", "mouse.clicked", { BUTTON = "right" })
  equal(items["noctalia.volume"].properties.popup.drawing, true)
end)
test("volume slider clamps to valid range and unmutes", function()
  local before = #commands
  emit("volume.slider", "mouse.clicked", { PERCENTAGE = "120" })
  assert(commands[before + 1]:find("output volume 100", 1, true))
  assert(commands[before + 1]:find("output muted false", 1, true))
end)
test("weather polling is rate limited and failed refresh retains data", function()
  local before = #commands
  emit("weather", "routine")
  equal(#commands, before)
  failures.weather = true
  emit("weather.refresh", "mouse.clicked")
  equal(label("weather"), "-2°C")
end)
test("stale weather is visibly marked without discarding its last reading", function()
  local options = require("config").weather
  local original_threshold = options.stale_after
  options.stale_after = 0
  emit("weather", "routine")
  equal(label("weather"), "-2°C ·")
  assert(label("weather.updated"):find("Stale", 1, true))
  options.stale_after = original_threshold
end)
test("unavailable system data and stopped Spotify degrade gracefully", function()
  failures.aerospace, failures.battery, failures.volume, failures.spotify = true, true, true, true
  failures.bluetooth = true
  emit("workspace", "routine")
  emit("battery", "routine")
  emit("volume", "routine")
  emit("spotify", "routine")
  emit("bluetooth", "routine")
  equal(label("workspace"), "Offline")
  equal(label("battery"), "—")
  equal(label("volume"), "—")
  equal(label("spotify"), "Spotify")
  equal(label("bluetooth"), "—")
  equal(label("bluetooth.status"), "Bluetooth information unavailable")
  equal(items["noctalia.bluetooth.device.1.name"].properties.drawing, false)
end)
print(string.format("\n%d tests passed", passed))
