#!/usr/bin/env bash
set -euo pipefail

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/zellij"
STATE_FILE="$STATE_DIR/previous-session"

[ -n "${ZELLIJ_SESSION_NAME:-}" ] || exit 1
[ -f "$STATE_FILE" ] || exit 0

previous_session="$(<"$STATE_FILE")"
[ -n "$previous_session" ] || exit 0
[ "$previous_session" != "$ZELLIJ_SESSION_NAME" ] || exit 0

mkdir -p "$STATE_DIR"
printf '%s\n' "$ZELLIJ_SESSION_NAME" > "$STATE_FILE"
exec zellij action switch-session "$previous_session"
