-- SPDX-License-Identifier: GPL-2.0-only
-- Native widgets/actions with Noctalia presentation and read-only Bluetooth details.
local bluetoothDetails = require("./bluetooth-details")
local mediaProgress = require("./media-progress")
local look

local function line(vertical, props)
    return if vertical then ui.column(props) else ui.row(props)
end

local function spacer(vertical, size)
    return if vertical then ui.box{ w = 1, h = size } else ui.box{ w = size, h = 1 }
end

local function text(props)
    props.size = props.size or 12
    props.weight = props.weight or "medium"
    if props.color == nil and props.role == "secondary" then
        props.color = "secondaryForeground"
    end
    props.role = nil
    if props.style ~= "mono" then
        props.font = props.font or "SF Pro Text"
    end
    return ui.text(props)
end

local function symbol(ctx, name, color)
    return ui.symbol{ name = name, size = 15 * look.scale(ctx), color = color, weight = "medium" }
end

local function pill(ctx, props)
    local style = ctx.data.bar.style
    local scale = look.scale(ctx)
    local height = math.max(16, style.height - 8 * scale)
    props.gap = props.gap or 6 * scale
    props.pad = 0
    props.radius = height / 2
    props[if style.vertical then "w" else "h"] = height
    if style.backgrounds then
        props.fill = props.fill or "surface"
        props.border = props.border or "border"
        props.borderWidth = props.borderWidth or 1
    end
    props.hover = props.hover or "elevatedSurface"
    props.hoverAnimate = 0.12
    if props.symbol then
        table.insert(props, 1, symbol(ctx, props.symbol, props.tint or "indigo"))
    end
    props.symbol, props.tint, props.hue, props.joined = nil, nil, nil, nil
    table.insert(props, 1, spacer(style.vertical, 4 * scale))
    props[#props + 1] = spacer(style.vertical, 4 * scale)
    return line(style.vertical, props)
end

look = require("./skin")({
    base = 38,
    capsules = true,
    width = 300,
    hover = "elevatedSurface",
    size = { text = 12, small = 11, symbol = 15, icon = 16, slot = 20 },
    text = text,
    bar = pill,
    panel = function(_, props)
        props.pad = props.pad or 14
        props.gap = props.gap or 10
        props.radius = 16
        props.material = "clear"
        props.fill = "background"
        props.border = "border"
        props.borderWidth = 1
        props.center = false
        return ui.column(props)
    end,
    workspaceMetrics = function(ctx)
        return { item = 24 * look.scale(ctx), separator = false, focusCue = true }
    end,
    workspaceMarker = function(ctx, workspace, style, metrics)
        if metrics.indicator ~= "pills" then
            return nil
        end
        return ui.stack{ w = 18 * metrics.scale, h = 18 * metrics.scale,
            text{ text = workspace.name, size = 12 * look.scale(ctx), weight = "semibold",
                color = if workspace.focused then (if style.accents then "accentForeground" else "background")
                    else "secondaryForeground",
                maxWidth = 18 * metrics.scale } }
    end,
    workspacePill = function(props, workspace, style, metrics)
        if metrics.indicator ~= "pills" then
            return
        end
        props.radius = metrics.item / 2
        props.fill = if workspace.focused then (if style.accents then "accent" else "foreground") else nil
        props.hover = if workspace.focused then "indigo" else "elevatedSurface"
    end,
    workspaceGroup = function(ctx, pills)
        pills.gap = 4 * look.scale(ctx)
        return pill(ctx, { line(ctx.data.bar.style.vertical, pills) })
    end,
    mediaBar = function(ctx, state)
        local scale = look.scale(ctx)
        local title = state.title
        if state.artist and state.artist ~= "" then
            title = state.artist .. " — " .. title
        end
        local bundle = ctx.select("media", "bundle")
        if type(bundle) ~= "string" or bundle == "" then
            bundle = nil
        end
        local source = ctx.select("media", "app")
        local label = ui.column{ gap = 0, center = false,
            text{ text = title, size = 12 * scale, maxWidth = 200 * scale,
                color = if state.playing then "foreground" else "secondaryForeground" } }
        local content = { key = "media-content", label }
        local progress = mediaProgress(ctx, state.playing)
        if progress ~= nil then
            label[#label + 1] = ui.box{ w = 0, h = 5 * scale }
            -- Unsized paths fill their stack without affecting its text-measured width.
            content[#content + 1] = ui.path{ key = "media-progress-track", h = 2 * scale, align = "bottomLeading",
                viewBox = { 0, 0, 1, 1 }, d = "M0 0 H1 V1 H0 Z", fill = "border", radius = scale }
            content[#content + 1] = ui.path{ key = "media-progress:" .. (bundle or "unknown") .. ":" .. title,
                h = 2 * scale, align = "bottomLeading", viewBox = { 0, 0, 1, 1 },
                d = string.format("M0 0 H%.6f V1 H0 Z", progress), radius = scale,
                fill = if state.playing then "indigo" else "mutedForeground", animate = "none" }
        end
        return pill(ctx, {
            ui.stack{ key = "media-source", w = 22 * scale, h = 22 * scale,
                help = if type(source) == "string" and source ~= "" then source else omniwm.l10n("Media source"),
                ui.icon{ app = bundle, placeholder = "music.note", w = 20 * scale, h = 20 * scale },
                ui.stack{ key = "playback-state", align = "bottomTrailing", dx = 2 * scale, dy = 2 * scale,
                    w = 10 * scale, h = 10 * scale, radius = 5 * scale,
                    fill = "surface", border = "border", borderWidth = 1,
                    help = if state.playing then omniwm.l10n("Playing") else omniwm.l10n("Paused"),
                    ui.symbol{ name = if state.playing then "play.fill" else "pause.fill",
                        size = 6 * scale, weight = "black", color = if state.playing then "green" else "yellow" } } },
            ui.stack(content),
        })
    end,
    clockBar = function(ctx, state)
        local scale = look.scale(ctx)
        -- Load lazily: the native calendar library also imports look.
        local calendar = require("./calendar").state(ctx)
        local event = calendar and calendar.event
        local size = (if event then 11 else 12) * scale
        local props = { gap = 7 * scale }
        if state.showIcon then
            props[#props + 1] = ui.symbol{ name = "calendar", size = (if event then 12 else 15) * scale,
                color = "accent", weight = "medium" }
        end
        if state.showDate then
            props[#props + 1] = text{ text = state.date, size = size, color = "secondaryForeground" }
        end
        props[#props + 1] = text{ text = state.time, size = size, weight = "semibold", reserve = "00:00 PM" }
        if not event then
            return pill(ctx, props)
        end
        local summary = event.countdown .. " · " .. event.title
        return pill(ctx, { gap = props.gap, help = summary,
            ui.column{ key = "clock-content", gap = 0,
                ui.row(props),
                text{ key = "clock-event", text = summary, size = 9 * scale, lines = 1,
                    maxWidth = 160 * scale, color = "secondaryForeground" } },
        })
    end,
    volumeBar = function(ctx, state)
        local color = if state.muted then "mutedForeground" else "orange"
        local props = { symbol(ctx, state.symbol, color) }
        if state.volume ~= nil then
            props[#props + 1] = text{ text = state.percent, size = 12 * look.scale(ctx), reserve = ctx.format.percent(1) }
        end
        return pill(ctx, props)
    end,
    batteryDetailsBar = function(ctx, state)
        -- Keep the native inside/off percentage layouts available in widget options.
        if state.mode ~= "beside" then
            return nil
        end
        local color = if state.low then state.tint else "green"
        return pill(ctx, {
            symbol(ctx, state.symbol, color),
            text{ text = state.percent, size = 12 * look.scale(ctx), reserve = state.reserve },
        })
    end,
    weatherBar = function(ctx, state)
        return pill(ctx, {
            symbol(ctx, state.symbol, "yellow"),
            text{ text = state.temp, size = 12 * look.scale(ctx), reserve = "-00°" },
        })
    end,
    bluetoothBar = function(ctx, state)
        local size = 16 * look.scale(ctx)
        local color = if state.power and state.granted then "cyan" else "mutedForeground"
        local count = if not state.granted then "—"
            elseif state.power then tostring(state.connected) else omniwm.l10n("Off")
        return pill(ctx, {
            ui.path{ w = size, h = size, viewBox = { 0, 0, 24, 24 },
                d = "M8 7 L17 16 L12 21 L12 3 L17 8 L8 17", border = color, borderWidth = 2 },
            text{ text = count, size = 12 * look.scale(ctx), reserve = "00" },
        })
    end,
    bluetoothPanel = function(ctx, model)
        local width = look.width
        local props = { w = width + 28,
            look.heading(omniwm.l10n("Bluetooth"), width) }
        if not model then
            props[#props + 1] = text{ text = omniwm.l10n("Unavailable"), color = "secondaryForeground" }
            return look.panel(ctx, props)
        end
        if model.status then
            props[#props + 1] = text{ text = model.status, color = "secondaryForeground" }
        end
        if model.granted and model.power then
            local count = if model.connected == 1 then omniwm.l10n("1 connected device")
                else omniwm.l10n("%lld connected devices", model.connected)
            props[#props + 1] = text{ text = count, color = "secondaryForeground" }
            local readings = bluetoothDetails.readings(ctx)
            for _, device in model.devices do
                local rows = { key = device.id, w = width, gap = 6,
                    ui.row{ w = width - 24, gap = 8,
                        look.glyph{ name = device.symbol, w = 18, h = 18,
                            color = if device.connected then "cyan" else "mutedForeground" },
                        text{ text = device.name, weight = "semibold", maxWidth = width - 50 } },
                    text{ text = device.status, size = 11, color = "secondaryForeground" } }
                if device.connected then
                    local values = readings[device.id] or {}
                    if #values == 0 then
                        rows[#rows + 1] = text{ text = omniwm.l10n("Battery not reported"), size = 11, color = "mutedForeground" }
                    end
                    for _, reading in values do
                        rows[#rows + 1] = ui.row{ key = reading.label, w = width - 24, gap = 8,
                            help = if reading.source == "accessory" then omniwm.l10n("Accessory power report")
                                else omniwm.l10n("Native Bluetooth reading"),
                            text{ text = omniwm.l10n(reading.label), size = 11, color = "secondaryForeground", grow = 1 },
                            text{ text = ctx.format.percent(reading.percent / 100), size = 12, reserve = ctx.format.percent(1),
                                color = if reading.percent <= 20 then "error" else "foreground" } }
                    end
                end
                props[#props + 1] = look.group(rows)
            end
        end
        local actions = require("./actions")
        for _, action in model.actions do
            props[#props + 1] = actions.row(action.symbol, action.text, action.command, width, action.wrap)
        end
        return look.panel(ctx, props)
    end,
})

return look
