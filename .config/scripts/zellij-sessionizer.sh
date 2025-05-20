#!/usr/bin/env bash

if [[ $# -eq 1 ]]; then
    selected=$1
else
    selected=$(find /Users/iomallach/notes ~/dev/c ~/dev/zig ~/dev/rust ~/dev/python ~/dev/go ~/dev/lua ~/dev/thirdparty ~/dotfiles/.config -mindepth 1 -maxdepth 1 -type d | fzf)
fi

if [[ -z $selected ]]; then
    exit 0
fi

selected_name=$(basename "$selected" | tr . _)
zellj_sessions=$(zellij list-sessions -n -s)

if echo "$zellij_sessions" | grep -q "^$selected_name$"; then
    zellij pipe --plugin https://github.com/mostafaqanbaryan/zellij-switch/releases/download/0.2.0/zellij-switch.wasm -- "--session=$selected_name --cwd=/Users/iomallach/dev"
else
    zellij attach -b "$selected_name"
    zellij pipe --plugin https://github.com/mostafaqanbaryan/zellij-switch/releases/download/0.2.0/zellij-switch.wasm -- "--session=$selected_name --cwd=/Users/iomallach/dev"
    # cd "$selected" && zellij -s "$selected_name"
fi
