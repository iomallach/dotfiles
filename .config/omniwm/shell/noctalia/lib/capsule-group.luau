-- SPDX-License-Identifier: GPL-2.0-only
local look = require("./look")
local group = {}

local function context(root, name)
    root.state.members = root.state.members or {}
    root.state.members[name] = root.state.members[name] or {}
    return {
        data = root.data, select = root.select, format = root.format,
        state = root.state.members[name],
    }
end

local function bind(tree, member, view)
    local opens = view == "bar" and (tree.onClick == ui.popout or tree.popout == true)
    for key, value in tree do
        if type(key) == "number" and type(value) == "table" then
            bind(value, member, view)
        elseif type(key) == "string" and key:match("^on") and type(value) == "function" and value ~= ui.popout then
            tree[key] = function(root, event)
                return value(context(root, member), event)
            end
        end
    end
    if opens then
        local click = tree.onClick
        tree.onClick = function(root, event)
            root.state.active = member
            if type(click) == "function" and click ~= ui.popout then
                return click(root, event)
            end
        end
        -- The host queues the callback before rendering and anchors to this section.
        tree.popout = true
    end
    return tree
end

function group.define(members)
    local byName = {}
    for _, member in members do
        byName[member.name] = member.widget
    end
    return {
        render = function(ctx)
            local children = { gap = 0 }
            local vertical = ctx.data.bar.style.vertical
            for _, member in members do
                local child = member.widget.render(context(ctx, member.name))
                if child.w == 0 and child.h == 0 then
                    continue
                end
                if #children > 0 then
                    children[#children + 1] = ui.box{
                        w = if vertical then 14 else 1,
                        h = if vertical then 1 else 14,
                        fill = "border",
                    }
                end
                child.fill, child.border, child.borderWidth = nil, nil, nil
                child.key = member.name
                children[#children + 1] = bind(child, member.name, "bar")
            end
            if #children == 0 then
                return ui.box{ w = 0, h = 0 }
            end
            local bubble = look.bar(ctx, children)
            bubble.hover, bubble.hoverAnimate = nil, nil
            return bubble
        end,
        popout = function(ctx)
            local name = if byName[ctx.state.active] then ctx.state.active else members[1].name
            local widget = byName[name]
            return bind(widget.popout(context(ctx, name)), name, "popout")
        end,
    }
end

return table.freeze(group)
