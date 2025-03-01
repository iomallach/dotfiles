-- Add the sketchybar module to the package cpath
package.cpath = package.cpath .. ";/Users/" .. os.getenv("USER") .. "/.local/share/sketchybar_lua/?.so"

sbar = require("sketchybar")

sbar.begin_config()
require("bar")
require("default")
require("items")
sbar.end_config()

sbar.event_loop()
