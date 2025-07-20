-- Add the sketchybar module to the package cpath
package.cpath = package.cpath .. ";/Users/" .. os.getenv("USER") .. "/.local/share/sketchybar_lua/?.so"

sbar = require("sketchybar")

sbar.exec(
	"killall stats_provider >/dev/null; ~/.cargo/bin/stats_provider --network en0 --cpu usage --cpu temperature --disk usage --memory ram_usage --interval 2"
)

sbar.begin_config()
require("bar")
require("default")
require("items")
sbar.end_config()

sbar.event_loop()
