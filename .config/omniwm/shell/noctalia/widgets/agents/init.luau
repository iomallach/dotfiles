-- SPDX-License-Identifier: GPL-2.0-only
local look = require("../lib/look")
local model = require("../lib/agent-status")
interval = 1

function trigger(ctx, event)
    if (event.name ~= "snapshot" and event.name ~= "remove") or type(event.value) ~= "string" then return end
    local value = json.decode(event.value)
    ctx.state.agents = model.receive(ctx.state.agents, event.name, value, ctx.data.seconds)
end

function render(ctx)
    local view = model.view(ctx.state.agents, ctx.data.seconds)
    local label = tostring(view.total)
    if view.attention > 0 then label ..= " · !" .. tostring(view.attention) end
    return look.bar(ctx, { symbol = "sparkles", tint = view.color, onClick = ui.popout,
        help = "Pi agents · " .. view.summary,
        look.text{ text = label, size = 12 * look.scale(ctx), weight = "semibold" } })
end

local function agentRow(ctx, agent, width)
    local style = model.styles[agent.status]
    local rows = { key = agent.instance, w = width, pad = 10, gap = 4,
        ui.row{ w = width - 20, gap = 8,
            ui.symbol{ name = style.symbol, color = style.color, size = 14 },
            look.text{ text = agent.project, weight = "semibold", maxWidth = width - 190, grow = 1 },
            look.text{ text = model.statusLabel(agent, ctx.data.seconds), size = 11, color = style.color } },
        look.text{ text = agent.title, size = 12, maxWidth = width - 20, lines = 1 },
        look.text{ text = agent.cwd, size = 10, color = "secondaryForeground", maxWidth = width - 20, lines = 1,
            help = agent.cwd },
    }
    if agent.review then
        rows[#rows + 1] = look.text{ text = agent.review.tool .. " · " .. agent.review.path,
            size = 11, color = "orange", maxWidth = width - 20, lines = 1, help = agent.review.path }
        rows[#rows + 1] = look.text{ text = agent.review.reason, size = 11, color = "secondaryForeground",
            maxWidth = width - 20, lines = 2, help = agent.review.reason }
    elseif agent.detail ~= "" then
        rows[#rows + 1] = look.text{ text = agent.detail, size = 11, color = "secondaryForeground",
            maxWidth = width - 20, lines = 1 }
    end
    rows[#rows + 1] = look.text{ text = agent.model,
        size = 10, color = "secondaryForeground", maxWidth = width - 20, lines = 1 }
    local usage = model.usageSummary(agent)
    if usage ~= "" then
        rows[#rows + 1] = look.text{ text = usage, size = 11, color = "secondaryForeground",
            maxWidth = width - 20, lines = 1,
            help = "Context is Pi's current usage estimate. Session cost is Pi-reported USD across all session history; unpriced models may report zero." }
    end
    return look.group(rows)
end

function popout(ctx)
    local width = 390
    local view = model.view(ctx.state.agents, ctx.data.seconds)
    local pages = math.max(1, math.ceil(view.total / model.pageSize))
    local page = math.clamp(ctx.state.page or 1, 1, pages)
    local rows = { w = width + 28, gap = 10, look.heading("Pi agents", width),
        look.text{ text = view.summary, size = 11, color = "secondaryForeground", maxWidth = width, lines = 2 } }
    if view.total == 0 then
        rows[#rows + 1] = look.text{ text = "Interactive Pi sessions appear here after loading the status extension.",
            size = 12, color = "secondaryForeground", maxWidth = width, lines = 2 }
    end
    for index = (page - 1) * model.pageSize + 1, math.min(page * model.pageSize, view.total) do
        rows[#rows + 1] = agentRow(ctx, view.agents[index], width)
    end
    if pages > 1 then
        local controls = { w = width, gap = 8 }
        if page > 1 then
            controls[#controls + 1] = look.button("chevron.left", function(next) next.state.page = page - 1 end,
                { help = "Previous agents" })
        end
        controls[#controls + 1] = look.text{ text = tostring(page) .. " / " .. tostring(pages),
            grow = 1, size = 11, color = "secondaryForeground" }
        if page < pages then
            controls[#controls + 1] = look.button("chevron.right", function(next) next.state.page = page + 1 end,
                { help = "More agents" })
        end
        rows[#rows + 1] = ui.row(controls)
    end
    return look.panel(ctx, rows)
end
