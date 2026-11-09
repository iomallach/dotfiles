local sbar = require("sketchybar")
local colors = require("colors")
local config = require("config")
local M = {}
local open_popup
local hover_popups = {}
local close_generation = 0

function M.close_popup()
  close_generation = close_generation + 1
  if open_popup then
    open_popup:set({ popup = { drawing = false } })
    open_popup = nil
  end
end

local function keep_popup(item)
  if open_popup == item then
    close_generation = close_generation + 1
  end
end

local function schedule_close(item)
  if open_popup ~= item then
    return
  end
  close_generation = close_generation + 1
  local generation = close_generation
  sbar.delay(0.15, function()
    if close_generation == generation and open_popup == item then
      M.close_popup()
    end
  end)
end

function M.hover_popup(item, refresh)
  hover_popups[item.name] = refresh
end

-- Popup rows have their own native windows. Track them as well as the host
-- so exits from a row close reliably and entering another row cancels closure.
function M.track_popup(item, parent)
  item:subscribe("mouse.entered", function()
    keep_popup(parent)
  end)
  item:subscribe("mouse.exited", function()
    schedule_close(parent)
  end)
end

local function show_popup(item)
  if open_popup ~= item then
    M.close_popup()
    item:set({ popup = { drawing = true } })
    open_popup = item
  end
  keep_popup(item)
end

function M.pill(name, position, icon, accent, label, properties)
  local item = sbar.add("item", name, {
    position = position,
    icon = { string = icon, color = accent },
    label = { string = label or "—" },
    popup = {
      align = "center",
      height = 30,
      -- Keep controls adjacent to the pill for hover transitions.
      y_offset = 0,
      background = {
        color = colors.mantle,
        border_color = colors.surface1,
        border_width = 1,
        corner_radius = 16,
      },
    },
  })
  if properties then
    item:set(properties)
  end
  item:subscribe("mouse.entered", function()
    sbar.animate("tanh", 12, function()
      item:set({ background = { color = colors.surface0, border_color = accent } })
    end)
    local refresh = hover_popups[item.name]
    if refresh then
      refresh()
      show_popup(item)
    else
      M.close_popup()
    end
  end)
  item:subscribe("mouse.exited", function()
    sbar.animate("tanh", 12, function()
      item:set({ background = { color = colors.mantle, border_color = colors.surface0 } })
    end)
    -- Do not subscribe the host to mouse.exited.global: SketchyBar would
    -- suppress this exit into its popup and latch the native hover state.
    -- Row entry cancels the close instead, allowing later hovers to reopen.
    schedule_close(item)
  end)
  item:subscribe("system_will_sleep", M.close_popup)
  return item
end

function M.row(parent, name, text, properties)
  local row = sbar.add("item", name, {
    position = "popup." .. parent.name,
    width = 250,
    padding_left = 6,
    padding_right = 6,
    icon = { drawing = false },
    label = {
      string = text or "",
      color = colors.subtext,
      padding_left = 12,
      padding_right = 12,
      font = { family = config.font, style = "Regular", size = 12 },
    },
    background = { drawing = false },
  })
  if properties then
    row:set(properties)
  end
  M.track_popup(row, parent)
  return row
end

function M.heading(parent, name, text)
  return M.row(parent, name, text, {
    label = { color = colors.text, font = { style = "Semibold", size = 13 } },
  })
end

function M.action(parent, name, text, callback)
  local row = M.row(parent, name, text, { label = { color = colors.lavender } })
  row:subscribe("mouse.clicked", callback)
  return row
end

return M
