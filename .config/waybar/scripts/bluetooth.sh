#!/bin/bash

# Get list of connected bluetooth devices
mapfile -t connected_devices < <(bluetoothctl devices Connected | awk '{print $2}')

# Count connected devices
device_count=${#connected_devices[@]}

# Build tooltip with device info
tooltip=""
for mac in "${connected_devices[@]}"; do
    # Get device name
    name=$(bluetoothctl info "$mac" | grep -i "Name:" | cut -d ' ' -f 2-)

    # Try to get battery percentage (not all devices support this)
    battery=$(bluetoothctl info "$mac" | grep -i "Battery Percentage:" | awk '{print $4}' | tr -d '()')

    # Assign icons based on device name
    icon=""
    case "$name" in
        *"Corne"*|*"corne"*|*"Keyboard"*|*"keyboard"*)
            icon="⌨"
            ;;
        *"MOMENTUM"*|*"momentum"*|*"Headphone"*|*"headphone"*)
            icon="🎧"
            ;;
        *"Mouse"*|*"mouse"*)
            icon="🖱"
            ;;
        *)
            icon="📱"
            ;;
    esac

    # Build tooltip line
    if [ -n "$battery" ]; then
        tooltip+="$icon $name - $battery%\n"
    else
        tooltip+="$icon $name\n"
    fi
done

# Remove trailing newline
tooltip=$(echo -e "$tooltip" | sed '$ d')

# Output JSON for waybar using jq to properly escape (compact output for single line)
if [ "$device_count" -eq 0 ]; then
    jq -nc --arg text "󰂯" --arg class "disconnected" --arg tooltip "No devices connected" \
        '{text: $text, class: $class, tooltip: $tooltip}'
else
    jq -nc --arg text "󰂯 $device_count" --arg class "connected" --arg tooltip "$tooltip" \
        '{text: $text, class: $class, tooltip: $tooltip}'
fi
