#!/usr/bin/env zsh

cores=$(sysctl -n hw.ncpu)
cpu_usage=$(ps -A -o %cpu | awk -v cores="$cores" '{s+=$1} END {printf "%.1f%%", s/cores "%"}')
sketchybar --set cpu label="$cpu_usage"
