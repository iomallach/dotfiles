-- SPDX-License-Identifier: GPL-2.0-only
local function finite(value)
    return type(value) == "number" and value == value and math.abs(value) < math.huge
end

return function(ctx, playing)
    local duration = ctx.select("media", "duration")
    local elapsed = ctx.select("media", "elapsed")
    if not finite(duration) or duration <= 0 or not finite(elapsed) or elapsed < 0 then
        return nil
    end
    local position = elapsed
    if playing then
        local rate = ctx.select("media", "rate")
        local sampledAt = ctx.select("media", "sampledAt")
        local now = ctx.select("seconds")
        if finite(rate) and rate >= 0 and finite(sampledAt) and finite(now) then
            position += math.max(0, now - sampledAt) * rate
        end
    end
    if not finite(position) then
        return nil
    end
    return math.clamp(position / duration, 0, 1)
end
