#!/usr/bin/env zsh

output="$(ipconfig getsummary en0 | awk -F ' SSID : '  '/ SSID : / {print $2}')"

sketchybar --set wifi label="$output"
