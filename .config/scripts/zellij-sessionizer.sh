set -euo pipefail

# ----------------------------------------
# Configure where your projects live
# ----------------------------------------
ROOTS=(
  "$HOME/dev/go"
  "$HOME/dev/rust"
  "$HOME/dev/python"
)

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/zellij"
STATE_FILE="$STATE_DIR/previous-session"

# Optional: set a layout to use when creating a new session
# Leave empty to use Zellij's default layout
DEFAULT_LAYOUT=""

# ----------------------------------------
# Helpers
# ----------------------------------------

have() {
  command -v "$1" >/dev/null 2>&1
}

die() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

list_projects() {
  local root
  for root in "${ROOTS[@]}"; do
    [ -d "$root" ] || continue
    fd . "$root" --max-depth 1 --type d --hidden --exclude .git
  done
}

create_or_switch_session() {
  local path="$1"
  local session_name
  session_name="$(basename "$path")"

  mkdir -p "$STATE_DIR"
  if [ -n "${ZELLIJ_SESSION_NAME:-}" ] && [ "$ZELLIJ_SESSION_NAME" != "$session_name" ]; then
    printf '%s\n' "$ZELLIJ_SESSION_NAME" > "$STATE_FILE"
  fi

  if [ -n "$DEFAULT_LAYOUT" ]; then
    zellij action switch-session --cwd "$path" --layout "$DEFAULT_LAYOUT" "$session_name"
  else
    zellij action switch-session --cwd "$path" "$session_name"
  fi
}

main() {
  have zellij || die "zellij not found"
  have fzf || die "fzf not found"

  local selection
  selection="$(
    list_projects \
      | sort -u \
      | fzf \
          --prompt='project > ' \
          --height=80% \
          --border \
          --preview 'test -d {} && eza --color=always --icons -lha {}'
  )"

  [ -n "${selection:-}" ] || exit 0
  [ -d "$selection" ] || die "selected path is not a directory: $selection"

  create_or_switch_session "$selection"
}

main "$@"
