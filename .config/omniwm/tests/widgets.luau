-- Offline host for the installed widgets: no commands, network, or native windows.
local loaders = {}
local cache = {}
local ui = setmetatable({ popout = "test:popout" }, {
    __index = function(_, kind)
        return function(props)
            props.kind = kind
            return props
        end
    end,
})
local omniwm = {
    run = function() error("Rendering must not invoke desktop actions") end,
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
        widgets[name] = requireModule("widgets/" .. name)
        test(name .. " renders a pill and valid available popout", function()
            local ctx = context(options[name])
            capsule(widgets[name].render(ctx))
            if widgets[name].popout then
                valid(widgets[name].popout(ctx))
            end
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
    test("media keeps native click/right-click behavior and bounded Unicode text", function()
        local node = widgets.media.render(context())
        assert(node.onClick == ui.popout and node.onRightClick == "media toggle")
        local label = find(node, function(entry) return entry.text == "Artist — Track 🎵" end)
        assert(label and label.maxWidth == 200)
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
    test("popouts use matte rounded surfaces instead of native menu glass", function()
        for _, name in { "media", "weather", "notifications", "bluetooth", "volume", "battery-details", "control-center", "clock" } do
            local node = widgets[name].popout(context(options[name]))
            assert(node.material == "clear" and node.fill == "background" and node.radius == 16)
        end
    end)
    print(string.format("%d widget tests passed (mock host; native visual preview still required)", count))
end
