-- SPDX-License-Identifier: GPL-2.0-only
local look = require("../lib/look")
local weather = require("../lib/weather")

function render(ctx)
    local message = weather.accessMessage(ctx)
    local state = if not message then weather.state(ctx) else nil
    local button
    if state then
        button = look.weatherBar(ctx, state)
    else
        button = look.bar(ctx, {
            look.glyph{ name = "cloud.sun", size = look.px(ctx, "symbol"), color = "yellow" },
            look.text{ text = message or omniwm.l10n("Weather —"), size = 12 * look.scale(ctx), maxWidth = 200 },
        })
    end
    button.onClick = ui.popout
    button.help = message or (state and state.condition)
        or omniwm.l10n("No weather reading yet. Check Weather Location in Styles & Widgets.")
    return button
end

function popout(ctx)
    if weather.accessMessage(ctx) or weather.state(ctx) then
        return weather.popout(ctx)
    end
    return look.panel(ctx, { w = look.width + 28,
        look.heading(omniwm.l10n("Weather"), look.width),
        look.text{ text = omniwm.l10n("No weather reading yet."), color = "secondaryForeground" },
        look.text{
            text = omniwm.l10n("Set a city or coordinates under Settings → Styles & Widgets → Noctalia → Bar → Weather → Weather Location. If already configured, check the Weather service and network connection."),
            size = 12, color = "secondaryForeground", maxWidth = look.width, lines = 8,
        },
    })
end
