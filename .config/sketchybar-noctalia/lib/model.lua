-- Pure data handling: no SketchyBar or macOS dependencies.
local M = {}

function M.trim(value)
  return tostring(value or ""):match("^%s*(.-)%s*$")
end

function M.single_line(value)
  return M.trim(value):gsub("%s+", " ")
end

function M.quote(value)
  return "'" .. tostring(value):gsub("'", "'\\''") .. "'"
end

function M.urlencode(value)
  return (tostring(value):gsub("([^%w%-_%.~])", function(char)
    return string.format("%%%02X", string.byte(char))
  end))
end

function M.truncate(value, limit)
  value = M.single_line(value)
  local length = utf8.len(value)
  if length and length > limit then
    return value:sub(1, utf8.offset(value, limit) - 1) .. "…"
  end
  return value
end

function M.volume(output)
  local percent, muted = M.trim(output):match("^(%d+)%s*,%s*(%a+)$")
  percent = tonumber(percent)
  if not percent or percent > 100 or (muted ~= "true" and muted ~= "false") then
    return nil
  end
  return { percent = percent, muted = muted == "true" }
end

function M.battery(output)
  local percent = tonumber(tostring(output):match("(%d+)%%"))
  if not percent or percent > 100 then
    return nil
  end
  local ac = output:find("AC Power", 1, true) ~= nil
  -- Match the semicolon-delimited state, not "discharging" / "not charging".
  local charging = output:match(";%s*charging%s*;") ~= nil
  local remaining = output:match("(%d+:%d+)%s+remaining")
  local detail = "On battery"
  if charging then
    detail = "Charging"
  elseif ac then
    detail = "Connected to power"
  end
  return {
    percent = percent,
    ac = ac,
    charging = charging,
    detail = detail,
    remaining = remaining,
  }
end

-- World Weather Online condition codes used by wttr.in.
local weather_codes = {
  sun = { 113 },
  partly_cloudy = { 116 },
  cloud = { 119, 122 },
  fog = { 143, 248, 260 },
  storm = { 200, 386, 389, 392, 395 },
  rain = { 176, 263, 266, 293, 296, 299, 302, 305, 308, 353, 356, 359 },
  snow = { 179, 182, 185, 227, 230, 281, 284, 311, 314, 317, 320, 323, 326,
    329, 332, 335, 338, 350, 362, 365, 368, 371, 374, 377 },
}
local weather_symbols = {}
for symbol, codes in pairs(weather_codes) do
  for _, code in ipairs(codes) do
    weather_symbols[code] = symbol
  end
end
local function first_value(list)
  if type(list) == "table" and type(list[1]) == "table" then
    return list[1].value
  end
end

function M.weather(data, unit)
  if type(data) ~= "table" or type(data.current_condition) ~= "table" then
    return nil
  end
  local current = data.current_condition[1]
  if type(current) ~= "table" then
    return nil
  end
  local temperature = tonumber(current[unit == "f" and "temp_F" or "temp_C"])
  local feels = tonumber(current[unit == "f" and "FeelsLikeF" or "FeelsLikeC"])
  local code = tonumber(current.weatherCode)
  if not temperature or not code then
    return nil
  end
  local description = first_value(current.weatherDesc)
  local area = type(data.nearest_area) == "table" and data.nearest_area[1]
  local city = type(area) == "table" and first_value(area.areaName)
  local symbol = weather_symbols[code] or "unknown"
  if code == 113 then
    local observed = tostring(current.localObsDateTime)
    local hour = tonumber(observed:match(" (%d%d):"))
    local meridiem = observed:match("(%u%u)$")
    if hour and (meridiem == "AM" or meridiem == "PM") then
      hour = hour % 12 + (meridiem == "PM" and 12 or 0)
    end
    if hour and (hour < 6 or hour >= 20) then
      symbol = "moon"
    end
  end
  return {
    temperature = temperature,
    feels = feels,
    symbol = symbol,
    description = M.single_line(description or "Current weather"),
    city = M.single_line(city or "Local weather"),
    humidity = tonumber(current.humidity),
  }
end

function M.spotify(output)
  local fields = {}
  for field in (tostring(output):gsub("[\r\n]+$", "") .. "\31"):gmatch("(.-)\31") do
    fields[#fields + 1] = M.single_line(field)
  end
  if fields[1] ~= "playing" and fields[1] ~= "paused" then
    return { state = "stopped" }
  end
  return { state = fields[1], title = fields[2] or "", artist = fields[3] or "", album = fields[4] or "" }
end

function M.omniwm_workspace(output)
  if type(output) ~= "table" or output.ok ~= true or type(output.result) ~= "table"
    or output.result.kind ~= "workspaces" or type(output.result.payload) ~= "table" then
    return nil
  end
  local list = output.result.payload.workspaces
  if type(list) ~= "table" or #list ~= 1 or type(list[1]) ~= "table"
    or type(list[1].rawName) ~= "string" then
    return nil
  end
  local name = M.trim(list[1].rawName)
  return name ~= "" and name or nil
end

function M.workspaces(output)
  local list = {}
  for line in tostring(output):gmatch("[^\r\n]+") do
    local name = M.trim(line)
    if name ~= "" then
      list[#list + 1] = name
    end
  end
  return list
end

function M.adjacent(list, current, direction)
  for index, name in ipairs(list) do
    if name == current then
      return list[(index - 1 + direction) % #list + 1]
    end
  end
end

local function bluetooth_percent(value)
  if type(value) ~= "number" and type(value) ~= "string" then
    return nil
  end
  local text = M.trim(value):gsub("%%$", "")
  local percent = tonumber(text)
  if percent and percent >= 0 and percent <= 100 then
    return math.floor(percent + 0.5)
  end
end

function M.accessory_batteries(output)
  local levels, seen = {}, {}
  if type(output) ~= "string" then
    return levels
  end
  for line in output:gmatch("[^\r\n]+") do
    local name, value = line:match("^%s*%-(.-)%s+%(id=%d+%)%s+([^;]+);")
    if name then
      local key = M.single_line(name):lower()
      if key ~= "" and not key:match("^internalbattery%-%d+$") then
        -- pmset has no Bluetooth address to disambiguate repeated names.
        if seen[key] then
          levels[key] = nil
        else
          levels[key] = bluetooth_percent(value)
        end
        seen[key] = true
      end
    end
  end
  return levels
end

function M.merge_accessory_batteries(data, output)
  local levels = M.accessory_batteries(output)
  local names = {}
  for _, device in ipairs(data.devices) do
    local key = device.name:lower()
    names[key] = (names[key] or 0) + 1
  end
  for _, device in ipairs(data.devices) do
    local key = device.name:lower()
    local percent = levels[key]
    if #device.batteries == 0 and names[key] == 1 and percent ~= nil then
      device.batteries[1] = { label = "Battery", percent = percent }
    end
  end
  return data
end

function M.bluetooth(data)
  local reports = type(data) == "table" and data.SPBluetoothDataType
  if type(reports) ~= "table" then
    return nil
  end
  local result = { enabled = false, devices = {} }
  local recognized, seen = false, {}
  for _, controller in ipairs(reports) do
    if type(controller) ~= "table" or type(controller.controller_properties) ~= "table" then
      return nil
    end
    local state = controller.controller_properties.controller_state
    if state == "attrib_on" or state == "attrib_off" then
      recognized = true
    end
    if state == "attrib_on" then
      result.enabled = true
      local connected = controller.device_connected or {}
      if type(connected) ~= "table" then
        return nil
      end
      for _, group in ipairs(connected) do
        if type(group) ~= "table" then
          return nil
        end
        for name, details in pairs(group) do
          if type(details) ~= "table" then
            return nil
          end
          local address = type(details.device_address) == "string" and details.device_address:lower()
          if not address or address == "" or not seen[address] then
            if address and address ~= "" then
              seen[address] = true
            end
            local batteries = {}
            local main = bluetooth_percent(details.device_batteryLevelMain)
              or bluetooth_percent(details.device_batteryLevelSingle)
              or bluetooth_percent(details.device_batteryLevel)
            if main then
              batteries[#batteries + 1] = { label = "Battery", percent = main }
            end
            for _, component in ipairs({ "Left", "Right", "Case" }) do
              local percent = bluetooth_percent(details["device_batteryLevel" .. component])
              if percent then
                batteries[#batteries + 1] = { label = component, percent = percent }
              end
            end
            result.devices[#result.devices + 1] = {
              name = M.single_line(name),
              kind = M.single_line(details.device_minorType or "Bluetooth device"),
              batteries = batteries,
            }
          end
        end
      end
    end
  end
  if not recognized then
    return nil
  end
  table.sort(result.devices, function(a, b)
    return a.name:lower() < b.name:lower()
  end)
  return result
end

function M.calendar(now)
  now = now or os.time()
  local today = os.date("*t", now)
  local first = os.time({ year = today.year, month = today.month, day = 1, hour = 12 })
  local last = os.date("*t", os.time({ year = today.year, month = today.month + 1, day = 0, hour = 12 })).day
  local offset = (os.date("*t", first).wday + 5) % 7 -- Monday first
  local rows, cells = { "Mo Tu We Th Fr Sa Su" }, {}
  for slot = 0, offset + last - 1 do
    local day = slot - offset + 1
    cells[#cells + 1] = day < 1 and "  " or string.format("%2d", day)
    if #cells == 7 then
      rows[#rows + 1] = table.concat(cells, " ")
      cells = {}
    end
  end
  if #cells > 0 then
    rows[#rows + 1] = table.concat(cells, " ")
  end
  local position = offset + today.day - 1
  return rows, {
    day = today.day,
    row = math.floor(position / 7) + 2, -- row 1 contains weekday names
    column = position % 7 + 1,
  }
end

return M
