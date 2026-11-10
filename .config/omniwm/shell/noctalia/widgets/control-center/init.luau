-- SPDX-License-Identifier: GPL-2.0-only
local group = require("../lib/capsule-group").define({
    { name = "notifications", widget = require("../lib/noctalia-native-notifications") },
    { name = "control-center", widget = require("../lib/noctalia-native-control-center") },
})

function render(ctx)
    return group.render(ctx)
end

function popout(ctx)
    return group.popout(ctx)
end
