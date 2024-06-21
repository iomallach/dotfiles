#!/bin/bash

TEMPERATURE=$(/usr/local/bin/smctemp -c)

if [ $? -ne 0 ]; then
  echo "Error: Unable to get temperature"
  exit 1
fi

sketchybar --set $NAME label="${TEMPERATURE}"
