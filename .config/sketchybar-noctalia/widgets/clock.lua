local sbar = require("sketchybar")
local colors = require("colors")
local config = require("config")
local icons = require("icons")
local model = require("lib.model")
local ui = require("lib.ui")

local clock = ui.pill("noctalia.clock", "right", icons.clock, colors.lavender, "", { update_freq = 15 })
local heading = ui.heading(clock, "noctalia.clock.heading", "")
local font_size = 12
-- JetBrains Mono advances 0.6 em per character. Anchor all weeks to the same
-- 20-character grid, including weeks with leading/trailing empty cells.
local character_width = font_size * 0.6
local grid_left = math.floor((250 - 20 * character_width) / 2)
local rows = {}
for index = 1, 7 do
  rows[index] = ui.row(clock, "noctalia.clock.week." .. index, "", {
    icon = {
      drawing = false,
      width = 0, -- overlay today's two digits without shifting the label
      align = "left",
      color = colors.mauve,
      padding_right = 0,
      font = { family = config.mono_font, style = "Bold", size = font_size },
    },
    label = {
      align = "left",
      padding_left = grid_left,
      padding_right = 0,
      font = { family = config.mono_font, style = "Regular", size = font_size },
      color = index == 1 and colors.mauve or colors.subtext,
    },
  })
end
ui.action(clock, "noctalia.clock.open", "Open Calendar  ↗", function()
  ui.close_popup()
  sbar.exec("open -a Calendar")
end)

local function refresh()
  local now = os.time()
  clock:set({ label = os.date(config.clock.format, now) })
  heading:set({ label = os.date("%A, %d %B %Y", now) })
  local calendar, today = model.calendar(now)
  local start = (today.column - 1) * 3 + 1
  for index, row in ipairs(rows) do
    local text = calendar[index] or ""
    local highlight = index == today.row
    if highlight then
      text = text:sub(1, start - 1) .. "  " .. text:sub(start + 2)
    end
    row:set({
      drawing = calendar[index] ~= nil,
      label = { string = text },
      icon = {
        drawing = highlight,
        string = string.format("%2d", today.day),
        padding_left = math.floor(grid_left + (start - 1) * character_width + 0.5),
      },
    })
  end
end
ui.hover_popup(clock, refresh)
clock:subscribe({ "routine", "forced", "system_woke" }, refresh)
clock:subscribe("mouse.clicked", refresh)
refresh()
return clock
