-- SPDX-License-Identifier: GPL-2.0-only
-- Self-contained snapshots, not event deltas: any heartbeat can rehydrate a reloaded widget.
local model = {}
model.expiry = 30
model.pageSize = 4
model.styles = {
    awaiting_approval = { label = "Awaiting approval", color = "orange", symbol = "hand.raised.fill", priority = 1 },
    waiting_input = { label = "Waiting for input", color = "yellow", symbol = "questionmark.bubble.fill", priority = 2 },
    interactive = { label = "Interactive UI", color = "indigo", symbol = "rectangle.on.rectangle", priority = 3 },
    working = { label = "Working", color = "cyan", symbol = "gearshape.2.fill", priority = 4 },
    idle = { label = "Idle", color = "secondaryForeground", symbol = "moon", priority = 5 },
}

local function finite(value)
    return type(value) == "number" and value == value and math.abs(value) < math.huge
end

local function identifier(value)
    return type(value) == "string" and #value == 36 and value:match("^[%x%-]+$") ~= nil
end

local function live(agent, now)
    return finite(agent.updatedAt) and agent.updatedAt <= (now + 5) * 1000
        and agent.updatedAt > (now - model.expiry) * 1000
end

local function text(value, fallback)
    return if type(value) == "string" and #value <= 2048 then value else fallback or ""
end

function model.duration(since, now)
    if not finite(since) or since < 0 or since > (now + 5) * 1000 then return nil end
    local seconds = math.max(0, math.floor(now - since / 1000))
    if seconds >= 86400 then return string.format("%dd %02dh", math.floor(seconds / 86400), math.floor(seconds % 86400 / 3600)) end
    if seconds >= 3600 then return string.format("%dh %02dm", math.floor(seconds / 3600), math.floor(seconds % 3600 / 60)) end
    if seconds >= 60 then return string.format("%dm %02ds", math.floor(seconds / 60), seconds % 60) end
    return tostring(seconds) .. "s"
end

function model.statusLabel(agent, now)
    local elapsed = model.duration(agent.statusSince, now)
    local label = model.styles[agent.status].label
    return if elapsed then label .. " · " .. elapsed else label
end

local function tokens(value)
    if value >= 1000000 then return (string.format("%.1fM", value / 1000000):gsub("%.0M$", "M")) end
    if value >= 1000 then return (string.format("%.1fk", value / 1000):gsub("%.0k$", "k")) end
    return tostring(math.floor(value))
end

function model.usageSummary(agent)
    local parts = {}
    if agent.context then
        local context = agent.context
        local count = if context.tokens ~= nil then tokens(context.tokens) else "—"
        local label = "Context " .. count .. "/" .. tokens(context.window)
        if context.percent ~= nil then
            local percent = string.format("%.1f", context.percent):gsub("%.0$", "")
            label ..= " (" .. percent .. "%)"
        end
        parts[#parts + 1] = label
    end
    if agent.costUsd ~= nil then
        local cost = agent.costUsd
        local amount = if cost > 0 and cost < 0.001 then "<$0.001"
            elseif cost >= 10 then string.format("$%.2f", cost) else string.format("$%.3f", cost)
        parts[#parts + 1] = "Session " .. amount
    end
    return table.concat(parts, " · ")
end

function model.receive(previous, name, value, now)
    local agents = {}
    for instance, agent in previous or {} do
        if live(agent, now) then agents[instance] = agent end
    end
    if type(value) ~= "table" or value.version ~= 1 or not identifier(value.instance) then return agents end
    if name == "remove" then
        agents[value.instance] = nil
        return agents
    end
    if name ~= "snapshot" or not model.styles[value.status] or not live(value, now)
        or not finite(value.sequence) or value.sequence < 1 or value.sequence % 1 ~= 0
        or type(value.sessionId) ~= "string" or type(value.project) ~= "string" then return agents end
    local old = agents[value.instance]
    if old and old.sequence >= value.sequence then return agents end
    local count = 0
    for _ in agents do count += 1 end
    if not old and count >= 128 then return agents end
    local agent = {
        instance = value.instance, sequence = value.sequence, updatedAt = value.updatedAt,
        sessionId = text(value.sessionId), project = text(value.project), title = text(value.title, "Pi"),
        cwd = text(value.cwd), model = text(value.model), status = value.status, detail = text(value.detail),
    }
    if finite(value.statusSince) and value.statusSince >= 0 and value.statusSince <= value.updatedAt then
        agent.statusSince = value.statusSince
    end
    if type(value.context) == "table" and finite(value.context.window) and value.context.window > 0 then
        agent.context = { window = value.context.window }
        if finite(value.context.tokens) and value.context.tokens >= 0 then
            agent.context.tokens = value.context.tokens
            if finite(value.context.percent) and value.context.percent >= 0 then agent.context.percent = value.context.percent end
        end
    end
    if finite(value.costUsd) and value.costUsd >= 0 then agent.costUsd = value.costUsd end
    if value.status == "awaiting_approval" and type(value.review) == "table" then
        agent.review = { path = text(value.review.path), reason = text(value.review.reason),
            tool = text(value.review.tool), view = text(value.review.view) }
    end
    agents[value.instance] = agent
    return agents
end

function model.view(agents, now)
    local list, counts = {}, {}
    for status in model.styles do counts[status] = 0 end
    for _, agent in agents or {} do
        if live(agent, now) then
            list[#list + 1] = agent
            counts[agent.status] += 1
        end
    end
    table.sort(list, function(a, b)
        local left, right = model.styles[a.status].priority, model.styles[b.status].priority
        if left ~= right then return left < right end
        if a.project ~= b.project then return a.project < b.project end
        if a.title ~= b.title then return a.title < b.title end
        return a.instance < b.instance
    end)
    local parts = {}
    for _, item in {
        { "awaiting_approval", "approval" }, { "waiting_input", "waiting" },
        { "interactive", "in UI" }, { "working", "working" }, { "idle", "idle" },
    } do
        local count = counts[item[1]]
        if count > 0 then parts[#parts + 1] = tostring(count) .. " " .. item[2] end
    end
    return { agents = list, counts = counts, total = #list,
        attention = counts.awaiting_approval + counts.waiting_input,
        color = if list[1] then model.styles[list[1].status].color else "secondaryForeground",
        summary = if #parts > 0 then table.concat(parts, " · ") else "No agents connected" }
end

return table.freeze(model)
