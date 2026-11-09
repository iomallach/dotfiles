local sbar = require("sketchybar")
local colors = require("colors")
local config = require("config")
local icons = require("icons")
local model = require("lib.model")
local ui = require("lib.ui")

sbar.add("event", "aerospace_workspace_change")
local workspace = ui.pill("noctalia.workspace", "left", icons.workspace, colors.mauve, "…", {
  update_freq = config.aerospace.interval,
  icon = {
    background = { drawing = true, color = colors.mauve, corner_radius = 11, height = 22 },
    color = colors.crust,
    padding_left = 8,
    padding_right = 8,
  },
  label = { padding_left = 9, font = { style = "Semibold", size = 13 } },
})
local current, busy
local function render(name)
  current = name
  workspace:set({ label = model.truncate(name, 18), icon = { color = colors.crust } })
end

local function refresh()
  if busy then
    return
  end
  busy = true
  sbar.exec("aerospace list-workspaces --focused 2>/dev/null", function(output, code)
    busy = false
    local name = model.trim(output)
    if code == 0 and name ~= "" then
      render(name)
    else
      current = nil
      workspace:set({ label = "Offline", icon = { color = colors.surface1 } })
    end
  end)
end

workspace:subscribe({ "routine", "forced", "system_woke", "display_change" }, refresh)
workspace:subscribe("aerospace_workspace_change", function(env)
  if env.FOCUSED_WORKSPACE and env.FOCUSED_WORKSPACE ~= "" then
    render(env.FOCUSED_WORKSPACE)
  else
    refresh()
  end
end)
workspace:subscribe("mouse.clicked", function(env)
  if env.BUTTON == "right" then
    sbar.exec("open -a AeroSpace")
  else
    sbar.exec("aerospace workspace-back-and-forth 2>/dev/null", refresh)
  end
end)
workspace:subscribe("mouse.scrolled", function(env)
  local delta = tonumber(env.SCROLL_DELTA) or 0
  if delta == 0 or not current then
    return
  end
  sbar.exec("aerospace list-workspaces --all 2>/dev/null", function(output, code)
    if code ~= 0 then
      return
    end
    local next_workspace = model.adjacent(model.workspaces(output), current, delta > 0 and -1 or 1)
    if next_workspace then
      sbar.exec("aerospace workspace " .. model.quote(next_workspace), refresh)
    end
  end)
end)
refresh()
return workspace
