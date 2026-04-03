#!/usr/bin/env sh
set -eu

focused_output=$(niri msg --json focused-output 2>/dev/null | jq -r '(.name // .Ok.FocusedOutput.name // .FocusedOutput.name // empty)' | head -n1)

if [ -z "$focused_output" ]; then
  fw_json=$(niri msg --json focused-window 2>/dev/null || true)
  ws_id=$(printf "%s" "$fw_json" | jq -r '(.Ok.FocusedWindow.workspace_id // .FocusedWindow.workspace_id // empty)')
  if [ -n "$ws_id" ]; then
    ws_json=$(niri msg --json workspaces 2>/dev/null || true)
    focused_output=$(printf "%s" "$ws_json" | jq -r --argjson ws_id "$ws_id" '((.Ok.Workspaces // .Workspaces // []) | map(select(.id==$ws_id)) | .[0] | (.output.name // .output // .output_name // empty))')
  fi
fi

if [ -z "$focused_output" ]; then
  echo "Could not determine focused output" >&2
  exit 1
fi

if [ "$focused_output" = "eDP-1" ]; then
  niri msg action move-workspace-to-monitor-left >/dev/null
else
  niri msg action move-workspace-to-monitor-right >/dev/null
fi
