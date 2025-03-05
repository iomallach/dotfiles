#!/usr/bin/env zsh

temp=$(/usr/local/bin/smctemp -c)

sketchybar --set tempcpu label="${temp}󰔄"
