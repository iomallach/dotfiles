#!/bin/sh
set -eu
ROOT=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
TEMP=$(mktemp -d "${TMPDIR:-/tmp}/noctalia-launcher-test.XXXXXX")
trap 'rm -rf -- "$TEMP"' EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
mkdir -p "$TEMP/home/.nix-profile/bin"
printf '#!/bin/sh\nexit 0\n' > "$TEMP/home/.nix-profile/bin/aerospace"
# The stub records startup inputs without loading SbarLua or touching the bar.
cat > "$TEMP/home/.nix-profile/bin/lua" <<'STUB'
#!/bin/sh
printf '%s\n' "$1" "$PATH" "$(command -v aerospace)" > "$CHECK_OUTPUT"
STUB
chmod +x "$TEMP/home/.nix-profile/bin/lua" "$TEMP/home/.nix-profile/bin/aerospace"

check_launcher() {
  expected_user=$1
  shift
  env -i HOME="$TEMP/home" PATH=/usr/bin:/bin:/usr/sbin:/sbin \
    CHECK_OUTPUT="$TEMP/output" "$@" "$ROOT/sketchybarrc"
  {
    IFS= read -r init_path
    IFS= read -r launch_path
    IFS= read -r aerospace_path
  } < "$TEMP/output"
  [ "$init_path" = "$ROOT/init.lua" ]
  [ "$aerospace_path" = "$TEMP/home/.nix-profile/bin/aerospace" ]
  case "$launch_path" in
    *":/etc/profiles/per-user/$expected_user/bin:"*) ;;
    *) printf 'Missing concrete user profile in PATH: %s\n' "$launch_path" >&2; exit 1 ;;
  esac
  printf 'ok - launchd-style startup resolves user profiles (%s)\n' "$expected_user"
}

check_launcher noctalia-test-user USER=noctalia-test-user
check_launcher "$(id -un)"
