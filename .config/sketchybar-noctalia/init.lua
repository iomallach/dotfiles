local root = assert(arg[0]:match("^(.*)/[^/]+$"), "Run through sketchybarrc")
package.path = root .. "/?.lua;" .. root .. "/?/init.lua;" .. package.path
package.cpath = package.cpath .. ";" .. assert(os.getenv("HOME")) .. "/.local/share/sketchybar_lua/?.so"

local ok, sbar = pcall(require, "sketchybar")
if not ok then
  error("SbarLua is required; see " .. root .. "/README.md\n" .. tostring(sbar))
end
-- Essential: an isolated preview must never address the production bar.
sbar.set_bar_name(os.getenv("BAR_NAME") or "sketchybar")

local colors = require("colors")
local config = require("config")
sbar.begin_config()
sbar.bar({
  color = colors.transparent,
  border_width = 0,
  shadow = false,
  -- Keep the entire widget-to-popup pointer path above app windows, even
  -- where the bar's transparent edge overlaps AeroSpace's reserved gap.
  topmost = "window",
  sticky = true,
  height = config.bar.height,
  margin = config.bar.margin,
  y_offset = os.getenv("NOCTALIA_PREVIEW") == "1" and 52 or config.bar.y_offset,
  padding_left = 0,
  padding_right = 0,
  display = config.bar.display,
  -- The existing AeroSpace gaps are retained; preview never changes them.
  hidden = os.getenv("NOCTALIA_HIDDEN") == "1",
})
sbar.default({
  updates = true,
  padding_left = 4,
  padding_right = 4,
  scroll_texts = false,
  icon = {
    font = { family = config.icon_font, style = "Regular", size = 17 },
    color = colors.lavender,
    padding_left = 12,
    padding_right = 6,
  },
  label = {
    font = { family = config.font, style = "Medium", size = 12 },
    color = colors.text,
    padding_left = 0,
    padding_right = 12,
  },
  background = {
    drawing = true,
    color = colors.mantle,
    border_width = 1,
    border_color = colors.surface0,
    height = config.bar.pill_height,
    corner_radius = config.bar.pill_height / 2,
  },
})

require("widgets.aerospace")
require("widgets.spotify")
-- Right-positioned items are laid out from the outside inward.
require("widgets.clock")
require("widgets.battery")
require("widgets.volume")
require("widgets.bluetooth")
require("widgets.weather")
sbar.end_config()
sbar.event_loop()
