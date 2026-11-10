-- Offline host for the installed widgets: no commands, network, or native windows.
local loaders = {}
local cache = {}
local commands = {}
local ui = setmetatable({ popout = "test:popout" }, {
    __index = function(_, kind)
        return function(props)
            props.kind = kind
            return props
        end
    end,
})
local omniwm = {
    run = function(command) commands[#commands + 1] = command end,
    l10n = function(format, ...)
        return string.format((format:gsub("%%@", "%%s"):gsub("%%lld", "%%d")), ...)
    end,
}

local function requireModule(path)
    local name = path:gsub("^%.%./lib/", "lib/"):gsub("^%./", "lib/")
    if not cache[name] then
        cache[name] = assert(loaders[name], "Missing library: " .. name)(requireModule, ui, omniwm)
    end
    return cache[name]
end

local function context(settings)
    local workspaces = {}
    for number = 1, 9 do
        workspaces[number] = { id = "workspace:" .. number, name = tostring(number), focused = number == 3, windows = {} }
    end
    workspaces[3].windows = {
        { id = "window:ghostty", bundle = "com.mitchellh.ghostty", name = "Ghostty", focused = true,
            count = 1, hidden = 0, badge = "", floating = false, windows = {} },
    }
    local ctx = {
        state = {},
        data = {
            app = "Ghostty", bundle = "com.mitchellh.ghostty", title = "project — Ghostty",
            notifications = { state = "empty", membershipComplete = true, metadataComplete = true, items = {} },
            clock = "14:30", date = "Tue 10 Nov", seconds = 1000, vars = {},
            settings = settings or {},
            bar = {
                style = { height = 38, vertical = false, transparent = true, backgrounds = true,
                    accents = true, labels = true, inactive = -1, position = "overlappingMenuBar" },
                workspaces = workspaces, island = "all", badges = "off",
            },
            media = { title = "Track 🎵", artist = "Artist", album = "Album", bundle = "com.spotify.client",
                app = "Spotify", playing = true, rate = 1, sampledAt = 1000 },
            battery = 87, charging = false, power = { source = "battery" },
            volume = 42, muted = false, outputs = {},
            bluetooth = { power = true, access = "granted", devices = {
                { id = "keyboard", name = "Corne", kind = "keyboard", connected = true, battery = 0 },
            } },
            weather = { access = "ok", temp = 12, unit = "°C", symbol = "sun.max.fill", condition = "Clear",
                day = true, code = 0, hours = {}, days = {}, status = "ok" },
        },
        format = {
            percent = function(value) return tostring(math.round(value * 100)) .. "%" end,
            number = function(value, digits) return string.format("%." .. tostring(digits or 0) .. "f", value) end,
        },
    }
    ctx.select = function(...)
        local value = ctx.data
        for _, key in { ... } do
            if value == nil then return nil end
            value = value[key]
        end
        return value
    end
    return ctx
end

local function calendarContext(settings)
    local ctx = context(settings)
    ctx.data.calendar = { access = "full", events = {
        { id = "team-sync", title = "Team sync", start = 2080, ["end"] = 3880, allDay = false,
            color = "blue", time = "14:48", day = "Today" },
    } }
    return ctx
end

local function find(node, predicate)
    if predicate(node) then return node end
    for _, child in node do
        if type(child) == "table" and child.kind then
            local match = find(child, predicate)
            if match then return match end
        end
    end
    return nil
end

local function hasText(node, value)
    return find(node, function(entry) return entry.text == value end) ~= nil
end

local function mediaProgressPath(node)
    return find(node, function(entry)
        return type(entry.key) == "string" and entry.key:match("^media%-progress:") ~= nil
    end)
end

local function renderedProgress(node)
    local path = mediaProgressPath(node)
    return path and tonumber(path.d:match("H%s*([%d.]+)"))
end

local function valid(node)
    assert(type(node) == "table" and type(node.kind) == "string", "Expected a UI element")
    for key, value in node do
        if type(key) == "number" then valid(value) end
        if key == "w" or key == "h" or key == "radius" then
            assert(type(value) == "number" and value >= 0 and value < math.huge, "Invalid geometry: " .. key)
        end
    end
end

local function capsule(node)
    valid(node)
    assert(node.h == 30 and node.radius == 15, "Expected a 30pt pill on the 38pt canvas")
    assert(node.fill == "surface" and node.border == "border" and node.borderWidth == 1)
end

local function runTests()
    local count = 0
    local function test(name, fn)
        fn()
        count += 1
        print("ok - " .. name)
    end
    local widgets = {}
    local options = { workspaces = { compact = false, indicator = "pills" }, clock = { date = true, icon = true } }
    for _, name in { "workspaces", "media", "active-window", "weather", "notifications", "bluetooth", "volume",
        "battery-details", "control-center", "clock" } do
        widgets[name] = requireModule("units/" .. name)
        test(name .. " renders a pill and valid available popout", function()
            local ctx = context(options[name])
            local before = #commands
            capsule(widgets[name].render(ctx))
            if widgets[name].popout then
                valid(widgets[name].popout(ctx))
            end
            assert(#commands == before, "Rendering must not invoke desktop actions")
        end)
    end
    test("workspace pills retain native targets, focus, menus, and drop destinations", function()
        local node = widgets.workspaces.render(context(options.workspaces))
        for number = 1, 9 do
            local cell = find(node, function(entry) return entry.key == "workspace:" .. number end)
            assert(cell and cell.target == "workspace workspace:" .. number)
            assert(cell.onClick == "switch-workspace workspace:" .. number and cell.menu and cell.drop)
            assert((cell.fill == "accent") == (number == 3))
        end
    end)
    test("workspace labels and native app icons stay visible together", function()
        local node = widgets.workspaces.render(context(options.workspaces))
        assert(hasText(node, "3"))
        local app = find(node, function(entry) return entry.kind == "icon" and entry.window == "window:ghostty" end)
        assert(app and app.w == 16 and app.h == 16)
        assert(find(node, function(entry) return entry.target == "window window:ghostty" and entry.preview and entry.drag end))
    end)
    test("center item retains the focused app icon, title, and native window-picker action", function()
        local node = widgets["active-window"].render(context())
        assert(node.onClick == "open-command-palette windows")
        assert(hasText(node, "project — Ghostty"))
        assert(find(node, function(entry) return entry.kind == "icon" and entry.app == "com.mitchellh.ghostty" end))
    end)
    test("notifications expose native access guidance without performing an action", function()
        local ctx = context()
        ctx.data.notifications = { state = "accessDenied", items = {} }
        local node = widgets.notifications.render(ctx)
        capsule(node)
        assert(node.onClick == ui.popout and string.find(node.help, "Full Disk Access", 1, true))
        assert(find(widgets.notifications.popout(ctx), function(entry) return entry.onClick == "notifications settings" end))
    end)
    test("control center retains its native tabs and controls", function()
        for _, tab in { "overview", "audio", "media", "calendar", "weather", "system" } do
            local ctx = context({ tab = tab })
            local node = widgets["control-center"].popout(ctx)
            valid(node)
            assert(find(node, function(entry) return entry.help == "Control Center" end))
            assert(find(node, function(entry) return entry.help == "System" end))
        end
    end)
    test("media uses source app icons while preserving native actions and bounded text", function()
        local ctx = context()
        local node = widgets.media.render(ctx)
        assert(node.onClick == ui.popout and node.onRightClick == "media toggle")
        local label = find(node, function(entry) return entry.text == "Artist — Track 🎵" end)
        assert(label and label.maxWidth == 200)
        assert(find(node, function(entry) return entry.kind == "icon" and entry.app == "com.spotify.client" end))
        ctx.data.media.bundle, ctx.data.media.app, ctx.data.media.title = "com.google.Chrome", "Chrome", "YouTube video"
        node = widgets.media.render(ctx)
        assert(find(node, function(entry) return entry.kind == "icon" and entry.app == "com.google.Chrome" end))
        ctx.data.media.bundle, ctx.data.media.app = "", ""
        node = widgets.media.render(ctx)
        assert(find(node, function(entry) return entry.kind == "icon" and entry.app == nil and entry.placeholder == "music.note" end))
    end)
    test("media shows playing/paused badges and freezes progress when paused", function()
        local ctx = context()
        ctx.data.media.duration, ctx.data.media.elapsed = 200, 50
        ctx.data.seconds = 1010
        local node = widgets.media.render(ctx)
        local badge = find(node, function(entry) return entry.key == "playback-state" end)
        assert(badge.help == "Playing" and find(badge, function(entry) return entry.name == "play.fill" end))
        local progress = mediaProgressPath(node)
        assert(progress and renderedProgress(node) == 0.3 and progress.h == 2)
        ctx.data.media.playing, ctx.data.media.elapsed = false, 60
        ctx.data.seconds = 1100
        node = widgets.media.render(ctx)
        badge = find(node, function(entry) return entry.key == "playback-state" end)
        assert(badge.help == "Paused" and find(badge, function(entry) return entry.name == "pause.fill" end))
        progress = mediaProgressPath(node)
        assert(renderedProgress(node) == 0.3 and progress.animate == "none")
        ctx.data.seconds = 5000
        assert(renderedProgress(widgets.media.render(ctx)) == 0.3)
    end)
    test("media progress follows the capped label width for short, long, and Unicode text", function()
        local ctx = context()
        ctx.data.media.artist = ""
        ctx.data.media.duration, ctx.data.media.elapsed = 100, 25
        for _, title in { "Hi", string.rep("W", 100), "晚安 🎵" } do
            ctx.data.media.title = title
            local node = widgets.media.render(ctx)
            local content = find(node, function(entry) return entry.key == "media-content" end)
            local label = find(content, function(entry) return entry.text == title end)
            assert(content.kind == "stack" and content.w == nil and content[1].w == nil)
            assert(label.w == nil and label.maxWidth == 200)
            local track = find(content, function(entry) return entry.key == "media-progress-track" end)
            for _, path in { track, mediaProgressPath(content) } do
                assert(path.kind == "path" and path.w == nil and path.h == 2 and path.align == "bottomLeading")
            end
            assert(content[1][2].w == 0 and content[1][2].h == 5)
        end
        ctx.data.media.duration = nil
        local content = find(widgets.media.render(ctx), function(entry) return entry.key == "media-content" end)
        assert(content.w == nil and #content == 1 and #content[1] == 1)
    end)
    test("media progress follows native rate without guessing missing timing", function()
        local fraction = requireModule("lib/media-progress")
        local ctx = context()
        ctx.data.media.duration, ctx.data.media.elapsed = 200, 40
        ctx.data.media.rate, ctx.data.seconds = 2, 1010
        assert(fraction(ctx, true) == 0.3)
        ctx.data.media.sampledAt = 1020
        assert(fraction(ctx, true) == 0.2)
        ctx.data.media.sampledAt = 1000
        ctx.data.media.rate = 0
        assert(fraction(ctx, true) == 0.2)
        ctx.data.media.rate = nil
        assert(fraction(ctx, true) == 0.2)
        ctx.data.media.rate, ctx.data.media.sampledAt = 1, nil
        assert(fraction(ctx, true) == 0.2)
    end)
    test("media progress accepts zero, caps overruns, and hides unusable metadata", function()
        local ctx = context()
        ctx.data.media.duration, ctx.data.media.elapsed = 100, 0
        local function progress()
            local node = widgets.media.render(ctx)
            valid(node)
            return renderedProgress(node)
        end
        assert(progress() == 0)
        ctx.data.media.elapsed = 500
        assert(progress() == 1)
        ctx.data.media.duration = nil
        assert(progress() == nil)
        for _, value in { 0, -1, math.huge, 0 / 0, "100" } do
            ctx.data.media.duration = value
            assert(progress() == nil)
        end
        ctx.data.media.duration, ctx.data.media.elapsed = 100, nil
        assert(progress() == nil)
        for _, value in { -1, math.huge, 0 / 0, "10" } do
            ctx.data.media.elapsed = value
            assert(progress() == nil)
        end
    end)
    test("media track/source changes reset progress instead of retaining the old item", function()
        local ctx = context()
        ctx.data.media.duration, ctx.data.media.elapsed = 200, 100
        local before = widgets.media.render(ctx)
        ctx.data.media.title, ctx.data.media.elapsed = "Next track", 0
        local after = widgets.media.render(ctx)
        assert(renderedProgress(before) == 0.5 and renderedProgress(after) == 0)
        assert(mediaProgressPath(before).key ~= mediaProgressPath(after).key)
        ctx.data.media.bundle, ctx.data.media.duration, ctx.data.media.elapsed = "com.google.Chrome", nil, nil
        local node = widgets.media.render(ctx)
        assert(not mediaProgressPath(node))
        assert(find(node, function(entry) return entry.kind == "icon" and entry.app == "com.google.Chrome" end))
    end)
    test("volume keeps scroll control, a zero value, and muted styling", function()
        local ctx = context()
        ctx.data.volume, ctx.data.muted = 0, true
        local node = widgets.volume.render(ctx)
        assert(node.onClick == ui.popout and type(node.onScroll) == "function")
        assert(hasText(node, "0%"))
        assert(find(node, function(entry) return entry.kind == "symbol" and entry.color == "mutedForeground" end))
    end)
    test("empty feeds disappear without stale values or render errors", function()
        local fields = { media = "media", bluetooth = "bluetooth", ["battery-details"] = "battery", ["active-window"] = "app" }
        for name, field in fields do
            local ctx = context()
            ctx.data[field] = if field == "app" then "" else nil
            local node = widgets[name].render(ctx)
            valid(node)
            assert(node.w == 0 and node.h == 0)
            if widgets[name].popout then
                valid(widgets[name].popout(ctx))
            end
        end
    end)
    test("weather remains visible without a reading and recovers to native forecast data", function()
        local ctx = context()
        local reading = ctx.data.weather
        ctx.data.weather = nil
        local node = widgets.weather.render(ctx)
        capsule(node)
        assert(hasText(node, "Weather —") and node.onClick == ui.popout)
        assert(hasText(widgets.weather.popout(ctx), "No weather reading yet."))
        ctx.data.weather = reading
        node = widgets.weather.render(ctx)
        capsule(node)
        assert(hasText(node, "12°") and not hasText(node, "Weather —"))
        valid(widgets.weather.popout(ctx))
    end)
    test("denied Bluetooth and disabled weather still expose native permission/status panels", function()
        local ctx = context()
        ctx.data.bluetooth.access = "denied"
        capsule(widgets.bluetooth.render(ctx))
        local panel = widgets.bluetooth.popout(ctx)
        assert(find(panel, function(entry) return entry.onClick == "bluetooth authorize" end))
        ctx.data.weather = { access = "off" }
        local node = widgets.weather.render(ctx)
        capsule(node)
        assert(hasText(node, "Turned off in Settings"))
        valid(widgets.weather.popout(ctx))
    end)
    test("Bluetooth count excludes paired-only devices and distinguishes off/unknown", function()
        local ctx = context()
        ctx.data.bluetooth.devices[2] = { id = "mouse", name = "Mouse", kind = "mouse", connected = false }
        assert(hasText(widgets.bluetooth.render(ctx), "1"))
        ctx.data.bluetooth.devices[1].connected = false
        assert(hasText(widgets.bluetooth.render(ctx), "0"))
        ctx.data.bluetooth.power = false
        assert(hasText(widgets.bluetooth.render(ctx), "Off"))
        ctx.data.bluetooth.access = "denied"
        assert(hasText(widgets.bluetooth.render(ctx), "—"))
    end)
    test("Bluetooth popup shows native main/left/right/case percentages including zero", function()
        local ctx = context()
        local device = ctx.data.bluetooth.devices[1]
        device.battery, device.left, device.right, device.case = 42, 0, 81, 100
        local node = widgets.bluetooth.popout(ctx)
        for _, value in { "Battery", "Left", "Right", "Case", "42%", "0%", "81%", "100%" } do
            assert(hasText(node, value), value)
        end
        assert(find(node, function(entry) return entry.text == "0%" and entry.color == "error" end))
        assert(find(node, function(entry) return entry.onClick == "bluetooth settings" end))
    end)
    local report = "1000\nNow drawing from 'AC Power'\n -InternalBattery-0 (id=1) 100%; charged;\n -Corne (id=2) 45%;\n"
    test("fresh accessory data supplies missing battery without replacing native components", function()
        local ctx = context()
        local device = ctx.data.bluetooth.devices[1]
        device.battery = nil
        ctx.data.vars.noctalia_bluetooth_power = report
        local node = widgets.bluetooth.popout(ctx)
        assert(hasText(node, "45%") and not hasText(node, "100%"))
        device.left = 77
        node = widgets.bluetooth.popout(ctx)
        assert(hasText(node, "77%") and not hasText(node, "45%"))
    end)
    test("accessory name matching is normalized, connected-only, and rejects ambiguities", function()
        local ctx = context()
        local device = ctx.data.bluetooth.devices[1]
        device.name, device.battery = "  corne  ", nil
        ctx.data.vars.noctalia_bluetooth_power = report
        assert(hasText(widgets.bluetooth.popout(ctx), "45%"))
        device.connected = false
        assert(not hasText(widgets.bluetooth.popout(ctx), "45%"))
        device.connected = true
        ctx.data.bluetooth.devices[2] = { id = "duplicate", name = "Corne", kind = "keyboard", connected = true }
        assert(not hasText(widgets.bluetooth.popout(ctx), "45%"))
        ctx.data.bluetooth.devices[2] = nil
        ctx.data.vars.noctalia_bluetooth_power = report .. " -Corne (id=3) 45%;\n"
        assert(hasText(widgets.bluetooth.popout(ctx), "Battery not reported"))
        assert(not hasText(widgets.bluetooth.popout(ctx), "45%"))
    end)
    test("accessory values expire and invalid reports never fabricate battery levels", function()
        local ctx = context()
        ctx.data.bluetooth.devices[1].battery = nil
        ctx.data.vars.noctalia_bluetooth_power = report
        ctx.data.seconds = 1091
        assert(hasText(widgets.bluetooth.popout(ctx), "Battery not reported"))
        ctx.data.seconds = 1000
        for _, value in { "broken", "9999\n -Corne (id=2) 45%;", "1000\n -Corne (id=2) 101%;" } do
            ctx.data.vars.noctalia_bluetooth_power = value
            assert(hasText(widgets.bluetooth.popout(ctx), "Battery not reported"))
        end
        ctx.data.vars.noctalia_bluetooth_power = "1000\n -Corne (id=2) 0%;"
        assert(hasText(widgets.bluetooth.popout(ctx), "0%"))
    end)
    test("disconnected or unreadable devices never retain stale battery percentages", function()
        local ctx = context()
        ctx.data.bluetooth.devices[1].connected = false
        local node = widgets.bluetooth.popout(ctx)
        assert(not hasText(node, "0%"))
        ctx.data.bluetooth.devices[1].connected = true
        ctx.data.bluetooth.devices[1].battery = -1
        node = widgets.bluetooth.popout(ctx)
        assert(hasText(node, "Battery not reported"))
    end)
    test("zero battery is displayed with its native warning color", function()
        local ctx = context()
        ctx.data.battery = 0
        local node = widgets["battery-details"].render(ctx)
        assert(hasText(node, "0%"))
        assert(find(node, function(entry) return entry.kind == "symbol" and entry.color == "error" end))
    end)
    test("native clock and battery options remain effective", function()
        local ctx = context({ date = false, icon = false })
        local clock = widgets.clock.render(ctx)
        assert(hasText(clock, "14:30") and not hasText(clock, "Tue 10 Nov"))
        assert(not find(clock, function(entry) return entry.name == "calendar" end))
        for _, mode in { "inside", "off" } do
            ctx.data.settings = { percent = mode }
            local node = widgets["battery-details"].render(ctx)
            capsule(node)
            assert(not hasText(node, "87%"))
        end
    end)
    test("clock stacks the next event below date/time without adding a capsule or action", function()
        local ctx = calendarContext(options.clock)
        local before = #commands
        local node = widgets.clock.render(ctx)
        capsule(node)
        assert(node.onClick == ui.popout and node.help == "In 18 min · Team sync")
        local content = find(node, function(entry) return entry.key == "clock-content" end)
        assert(content.kind == "column" and content.gap == 0 and #content == 2)
        assert(content[1].kind == "row" and hasText(content[1], "Tue 10 Nov") and hasText(content[1], "14:30"))
        assert(find(content[1], function(entry) return entry.name == "calendar" and entry.size == 12 end))
        assert(find(content[1], function(entry) return entry.text == "14:30" and entry.size == 11 end))
        local event = content[2]
        assert(event.key == "clock-event" and event.text == node.help)
        assert(event.size == 9 and event.maxWidth == 160 and event.lines == 1)
        assert(#commands == before, "Reading calendar data must not request permissions or perform desktop actions")
    end)
    test("clock follows native countdowns, skips all-day/ended entries, and advances after expiry", function()
        local ctx = calendarContext()
        local event = ctx.data.calendar.events[1]
        local ended, allDay, later = table.clone(event), table.clone(event), table.clone(event)
        ended.start, ended["end"], ended.title = 0, 1000, "Ended"
        allDay.allDay, allDay.title = true, "All day"
        later.start, later["end"], later.title, later.time = 6000, 7000, "Planning", "16:00"
        ctx.data.calendar.events = { ended, allDay, event, later }
        assert(hasText(widgets.clock.render(ctx), "In 18 min · Team sync"))
        ctx.data.seconds = 1060
        assert(hasText(widgets.clock.render(ctx), "In 17 min · Team sync"))
        ctx.data.seconds = event.start
        assert(hasText(widgets.clock.render(ctx), "Now · Team sync"))
        ctx.data.seconds = event["end"]
        assert(hasText(widgets.clock.render(ctx), "In 36 min · Planning"))
        ctx.data.seconds = later["end"]
        assert(not find(widgets.clock.render(ctx), function(entry) return entry.key == "clock-event" end))
        ctx.data.seconds = 1000
        event.start, event["end"] = 8200, 10000
        ctx.data.calendar.events = { event }
        assert(hasText(widgets.clock.render(ctx), "14:48 · Team sync"))
        event.start, event["end"] = 1000 + 12 * 3600, 1000 + 13 * 3600
        assert(not find(widgets.clock.render(ctx), function(entry) return entry.key == "clock-event" end))
    end)
    test("clock hides unavailable or empty calendar data and recovers without a stale line", function()
        local ctx = calendarContext()
        local data = ctx.data.calendar
        local before = #commands
        for _, access in { "notDetermined", "denied", "restricted", "writeOnly", "full" } do
            data.access = access
            data.events = if access == "full" then {} else calendarContext().data.calendar.events
            local node = widgets.clock.render(ctx)
            assert(hasText(node, "14:30") and not find(node, function(entry) return entry.key == "clock-content" end))
            assert(node.help == nil)
        end
        ctx.data.calendar = calendarContext().data.calendar
        assert(hasText(widgets.clock.render(ctx), "In 18 min · Team sync"))
        ctx.data.calendar = nil
        local node = widgets.clock.render(ctx)
        assert(not find(node, function(entry) return entry.key == "clock-event" end))
        assert(find(node, function(entry) return entry.text == "14:30" and entry.size == 12 end))
        assert(#commands == before)
    end)
    test("clock caps long Unicode event lines and scales them with the bar", function()
        local ctx = calendarContext({ date = false, icon = false })
        local title = string.rep("Planning 晚安 🎵 ", 20)
        ctx.data.calendar.events[1].title = title
        for _, scale in { 1, 2 } do
            ctx.data.bar.style.height = 38 * scale
            local node = widgets.clock.render(ctx)
            valid(node)
            local event = find(node, function(entry) return entry.key == "clock-event" end)
            assert(event.text == "In 18 min · " .. title and event.maxWidth == 160 * scale)
            assert(event.w == nil and event.size == 9 * scale and event.lines == 1)
            assert(node.help == event.text and node.h == 30 * scale)
            assert(hasText(node, "14:30") and not hasText(node, "Tue 10 Nov"))
            assert(not find(node, function(entry) return entry.name == "calendar" end))
        end
    end)
    test("popouts use matte rounded surfaces instead of native menu glass", function()
        for _, name in { "media", "weather", "notifications", "bluetooth", "volume", "battery-details", "control-center", "clock" } do
            local node = widgets[name].popout(context(options[name]))
            assert(node.material == "clear" and node.fill == "background" and node.radius == 16)
        end
    end)
    local groups = {}
    local members = {
        weather = { "weather", "clock" },
        bluetooth = { "bluetooth", "volume", "battery-details" },
        ["control-center"] = { "notifications", "control-center" },
    }
    local function surfaces(node)
        local total = if node.fill == "surface" and node.border == "border" then 1 else 0
        for key, child in node do
            if type(key) == "number" then total += surfaces(child) end
        end
        return total
    end
    for name, parts in members do
        groups[name] = requireModule("widgets/" .. name)
        test(name .. " group draws one shared capsule and routes each clickable section", function()
            local ctx = context()
            local before = #commands
            local node = groups[name].render(ctx)
            capsule(node)
            assert(surfaces(node) == 1, "Child bubbles must not retain their own backgrounds")
            for _, part in parts do
                local section = find(node, function(entry) return entry.key == part end)
                assert(section and section.popout == true and type(section.onClick) == "function")
                section.onClick(ctx, { button = "left" })
                assert(ctx.state.active == part)
                valid(groups[name].popout(ctx))
            end
            assert(#commands == before, "Opening/rendering a panel must not perform its actions")
        end)
    end
    test("control-center tab state stays separate from notification drafts", function()
        local ctx = context()
        local widget = groups["control-center"]
        local node = widget.render(ctx)
        find(node, function(entry) return entry.key == "control-center" end).onClick(ctx, {})
        local panel = widget.popout(ctx)
        find(panel, function(entry) return entry.help == "Audio" end).onClick(ctx, {})
        assert(ctx.state.members["control-center"].tab == "audio" and ctx.state.tab == nil)
        find(node, function(entry) return entry.key == "notifications" end).onClick(ctx, {})
        panel = widget.popout(ctx)
        assert(hasText(panel, "Notifications"))
        assert(ctx.state.members.notifications.drafts ~= nil)
        assert(ctx.state.members["control-center"].tab == "audio")
    end)
    test("volume scroll remains local to its section and preserves configured step", function()
        local ctx = context({ step = 5 })
        local node = groups.bluetooth.render(ctx)
        local volume = find(node, function(entry) return entry.key == "volume" end)
        local before = #commands
        volume.onScroll(ctx, { precise = true, dy = 6 })
        assert(#commands == before and ctx.state.members.volume.scroll == 0.5)
        volume.onScroll(ctx, { precise = true, dy = 6 })
        assert(#commands == before + 1 and commands[#commands] == "volume up 5")
        assert(ctx.state.scroll == nil and ctx.state.members.bluetooth.scroll == nil)
        assert(ctx.state.active == nil, "Scrolling must not select or open a popup")
    end)
    test("device capsule hides unavailable children without empty separators", function()
        local ctx = context()
        ctx.data.bluetooth, ctx.data.battery = nil, nil
        local node = groups.bluetooth.render(ctx)
        capsule(node)
        assert(not find(node, function(entry) return entry.key == "bluetooth" or entry.key == "battery-details" end))
        assert(find(node, function(entry) return entry.key == "volume" end))
        assert(not find(node, function(entry) return entry.fill == "border" and entry.w == 1 and entry.h == 14 end))
    end)
    test("grouped Bluetooth popup retains accessory battery details", function()
        local ctx = context()
        ctx.data.bluetooth.devices[1].battery = nil
        ctx.data.vars.noctalia_bluetooth_power = report
        local node = groups.bluetooth.render(ctx)
        find(node, function(entry) return entry.key == "bluetooth" end).onClick(ctx, {})
        assert(hasText(groups.bluetooth.popout(ctx), "45%"))
    end)
    test("grouped event line still opens the native calendar inside one shared weather capsule", function()
        local ctx = calendarContext(options.clock)
        local before = #commands
        local node = groups.weather.render(ctx)
        capsule(node)
        assert(surfaces(node) == 1)
        local clock = find(node, function(entry) return entry.key == "clock" end)
        assert(hasText(clock, "In 18 min · Team sync"))
        clock.onClick(ctx, {})
        assert(ctx.state.active == "clock" and clock.popout == true)
        local panel = groups.weather.popout(ctx)
        valid(panel)
        assert(hasText(panel, "Team sync"))
        assert(find(panel, function(entry) return entry.onClick == "calendar open team-sync" end))
        assert(#commands == before)
    end)
    test("grouped clock options still hide its date and calendar icon", function()
        local ctx = calendarContext({ date = false, icon = false })
        local node = groups.weather.render(ctx)
        local clock = find(node, function(entry) return entry.key == "clock" end)
        assert(hasText(clock, "14:30") and not hasText(clock, "Tue 10 Nov"))
        assert(not find(clock, function(entry) return entry.name == "calendar" end))
    end)
    print(string.format("%d widget tests passed (mock host; native visual preview still required)", count))
end
