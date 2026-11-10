-- SPDX-License-Identifier: GPL-2.0-only
local group = require("../lib/capsule-group").define({
    { name = "weather", widget = require("../lib/weather-widget") },
    { name = "clock", widget = require("../lib/noctalia-native-clock") },
})

function render(ctx)
    return group.render(ctx)
end

function popout(ctx)
    return group.popout(ctx)
end
