-- SPDX-License-Identifier: GPL-2.0-only
local group = require("../lib/capsule-group").define({
    { name = "bluetooth", widget = require("../lib/noctalia-native-bluetooth") },
    { name = "volume", widget = require("../lib/noctalia-native-volume") },
    { name = "battery-details", widget = require("../lib/noctalia-native-battery-details") },
})

function render(ctx)
    return group.render(ctx)
end

function popout(ctx)
    return group.popout(ctx)
end
