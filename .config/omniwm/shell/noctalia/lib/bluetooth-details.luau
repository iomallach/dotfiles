-- SPDX-License-Identifier: GPL-2.0-only
-- Pure data shaping: no device commands or external processes run in the widget.
local details = {}
local FIELDS = {
    { key = "battery", label = "Battery" },
    { key = "left", label = "Left" },
    { key = "right", label = "Right" },
    { key = "case", label = "Case" },
}

local function level(value)
    return if type(value) == "number" and value >= 0 and value <= 100 and value % 1 == 0 then value else nil
end

local function name(value)
    return string.lower(value:gsub("^%s+", ""):gsub("%s+$", ""):gsub("%s+", " "))
end

local function accessoryLevels(payload, now)
    if type(payload) ~= "string" or #payload > 16384 or type(now) ~= "number" then
        return {}
    end
    local timestamp, report = payload:match("^(%d+)\n(.*)$")
    local sampled = tonumber(timestamp)
    if not sampled or sampled > now + 5 or now - sampled > 90 then
        return {}
    end
    local levels = {}
    for line in report:gmatch("[^\r\n]+") do
        local device, percent = line:match("^%s*%-(.-)%s+%(id=%d+%)%s+(%d+)%%;")
        local value = level(tonumber(percent))
        if device and value ~= nil then
            local key = name(device)
            if key ~= "" and not key:match("^internalbattery") then
                -- Two power sources with the same name are ambiguous, even at equal charge.
                levels[key] = if levels[key] == nil then value else false
            end
        end
    end
    return levels
end

function details.readings(ctx)
    local data = ctx.data.bluetooth
    if not data or data.access ~= "granted" or not data.power then
        return {}
    end
    local connectedNames = {}
    for _, device in data.devices do
        if device.connected then
            local key = name(device.name)
            connectedNames[key] = (connectedNames[key] or 0) + 1
        end
    end
    local fallback = accessoryLevels(ctx.select("vars", "noctalia_bluetooth_power"), ctx.data.seconds)
    local byID = {}
    for _, device in data.devices do
        local readings = {}
        if device.connected then
            for _, field in FIELDS do
                local value = level(device[field.key])
                if value ~= nil then
                    readings[#readings + 1] = { label = field.label, percent = value, source = "native" }
                end
            end
            local key = name(device.name)
            local value = fallback[key]
            if #readings == 0 and connectedNames[key] == 1 and type(value) == "number" then
                readings[1] = { label = "Battery", percent = value, source = "accessory" }
            end
        end
        byID[device.id] = readings
    end
    return byID
end

return table.freeze(details)
