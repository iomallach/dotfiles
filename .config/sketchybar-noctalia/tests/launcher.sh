#!/bin/sh
set -eu
ROOT=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
TEMP=$(mktemp -d "${TMPDIR:-/tmp}/noctalia-launcher-test.XXXXXX")
trap 'rm -rf -- "$TEMP"' EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
mkdir -p "$TEMP/home/.nix-profile/bin"
printf '#!/bin/sh\nexit 0\n' > "$TEMP/home/.nix-profile/bin/aerospace"
printf '#!/bin/sh\nexit 0\n' > "$TEMP/home/.nix-profile/bin/omniwmctl"
# The stub records startup inputs without loading SbarLua or touching the bar.
cat > "$TEMP/home/.nix-profile/bin/lua" <<'STUB'
#!/bin/sh
printf '%s\n' "$1" "$PATH" "$(command -v aerospace)" "$(command -v omniwmctl)" "${NOCTALIA_WM:-aerospace}" > "$CHECK_OUTPUT"
STUB
chmod +x "$TEMP/home/.nix-profile/bin/"*

check_launcher() {
  expected_user=$1
  expected_backend=$2
  shift 2
  env -i HOME="$TEMP/home" PATH=/usr/bin:/bin:/usr/sbin:/sbin \
    CHECK_OUTPUT="$TEMP/output" "$@" "$ROOT/sketchybarrc"
  {
    IFS= read -r init_path
    IFS= read -r launch_path
    IFS= read -r aerospace_path
    IFS= read -r omniwm_path
    IFS= read -r backend
  } < "$TEMP/output"
  [ "$init_path" = "$ROOT/init.lua" ]
  [ "$aerospace_path" = "$TEMP/home/.nix-profile/bin/aerospace" ]
  [ "$omniwm_path" = "$TEMP/home/.nix-profile/bin/omniwmctl" ]
  [ "$backend" = "$expected_backend" ]
  case "$launch_path" in
    *":/etc/profiles/per-user/$expected_user/bin:"*) ;;
    *) printf 'Missing concrete user profile in PATH: %s\n' "$launch_path" >&2; exit 1 ;;
  esac
  printf 'ok - launchd-style startup resolves user profiles (%s, %s)\n' "$expected_user" "$backend"
}

check_launcher noctalia-test-user aerospace USER=noctalia-test-user
check_launcher "$(id -un)" aerospace
check_launcher noctalia-test-user omniwm USER=noctalia-test-user NOCTALIA_WM=omniwm
check_launcher "$(id -un)" omniwm NOCTALIA_WM=omniwm
