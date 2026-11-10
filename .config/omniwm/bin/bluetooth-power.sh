#!/bin/sh
# One-shot publisher; launchd schedules it. The optional second path is for tests.
set -eu
ctl=${1:?Usage: bluetooth-power.sh /path/to/omniwmctl [path/to/pmset]}
power=${2:-/usr/bin/pmset}

if report=$("$power" -g accps 2>/dev/null); then
  timestamp=$(/bin/date +%s)
  exec "$ctl" shell set noctalia_bluetooth_power "$timestamp
$report" >/dev/null
else
  exec "$ctl" shell unset noctalia_bluetooth_power >/dev/null
fi
