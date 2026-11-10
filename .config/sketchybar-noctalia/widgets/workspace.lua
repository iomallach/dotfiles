local sbar = require("sketchybar")
local colors = require("colors")
local config = require("config")
local icons = require("icons")
local model = require("lib.model")
local ui = require("lib.ui")

local omniwm = config.workspace.backend == "omniwm"
assert(omniwm or config.workspace.backend == "aerospace", "Unknown workspace backend")
local event = omniwm and "omniwm_workspace_change" or "aerospace_workspace_change"
sbar.add("event", event)
local workspace = ui.pill("noctalia.workspace", "left", icons.workspace, colors.mauve, "…", {
  update_freq = config.workspace.interval,
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
  local command = omniwm and "omniwmctl query workspaces --current --fields raw-name --json"
    or "aerospace list-workspaces --focused"
  sbar.exec(command .. " 2>/dev/null", function(output, code)
    busy = false
    local name
    if omniwm then
      name = model.omniwm_workspace(output)
    else
      name = model.trim(output)
    end
    if code == 0 and name and name ~= "" then
      render(name)
    else
      current = nil
      workspace:set({ label = "Offline", icon = { color = colors.surface1 } })
    end
  end)
end

workspace:subscribe({ "routine", "forced", "system_woke", "display_change" }, refresh)
workspace:subscribe(event, function(env)
  if not omniwm and env.FOCUSED_WORKSPACE and env.FOCUSED_WORKSPACE ~= "" then
    render(env.FOCUSED_WORKSPACE)
  else
    refresh()
  end
end)
workspace:subscribe("mouse.clicked", function(env)
  if env.BUTTON == "right" then
    sbar.exec(omniwm and "open -a OmniWM" or "open -a AeroSpace")
  else
    local command = omniwm and "omniwmctl command switch-workspace back-and-forth"
      or "aerospace workspace-back-and-forth"
    sbar.exec(command .. " 2>/dev/null", refresh)
  end
end)
workspace:subscribe("mouse.scrolled", function(env)
  local delta = tonumber(env.SCROLL_DELTA) or 0
  if delta == 0 or not current then
    return
  end
  if omniwm then
    local direction = delta > 0 and "prev" or "next"
    sbar.exec("omniwmctl command switch-workspace " .. direction .. " 2>/dev/null", refresh)
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
