#!/bin/bash

temperature=(
  script="$PLUGIN_DIR/temperature_cpu.sh"
  icon="󱤋"
  icon.color="$WHITE"
  icon.font="$FONT:Regular:19.0"
  icon.padding_right=0
  padding_right=0
  padding_left=0
  label.padding_right=5
  update_freq=10
)
temp=$(/usr/local/bin/smctemp -c)
sketchybar --add item tempcpu right \
           --set tempcpu label="${temp}󰔄" \
           --set tempcpu icon="󱤋" \
           --set tempcpu script="$PLUGIN_DIR/temperature_cpu.sh" \
           --set tempcpu label.padding_right=5 \
           --set temocpu icon.font="$FONT:Regular:19.0" \
           --set tempcpu update_freq=10
