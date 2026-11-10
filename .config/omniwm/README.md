# Workbook: AeroSpace → OmniWM

`../nix/modules/hosts/darwin/workbook.nix` selects both the Darwin and Home Manager
`omniwm` modules. Other hosts retain their existing desktop selections.

## Configuration

- `../nix/modules/omniwm.nix` temporarily overrides nixpkgs' OmniWM package with the
  signed **OmniWM 0.8.0** release, including its matching `omniwmctl`. The
  nixpkgs revision and `flake.lock` stay unchanged. Remove the override once
  the pinned nixpkgs provides 0.8.0 or newer (see the TODO in that module).
- Home Manager disables AeroSpace and starts OmniWM through its LaunchAgent.
  Do **not** also enable OmniWM's macOS **Start at Login** option.
- `settings.toml` is a **complete schema-v5** configuration, migrated by 0.8.0
  from the original 0.7.6 schema-v4 settings (see below). OmniWM does not
  merge a short settings fragment with its defaults. Review this file and the
  CLI integration when upgrading the package, especially across schema changes.
- Settings preserve the 0.7.6 default shortcuts except directional focus
  (**Option + H/J/K/L**) and added workspace-to-monitor moves
  (**Control + Option + Shift + H/J/K/L**). The nine numbered workspaces,
  app resize-floor rules, and Niri layout are unchanged. Workspaces 6/7 prefer
  the secondary display and retain their upstream heart/rocket display names.
  The SketchyBar pill shows the raw workspace number.
- OmniWM's native focused-window border, workspace bar, and Hidden Bar are
  enabled in the current settings. SketchyBar remains configured as well;
  the package upgrade does not change any of these selections.
- IPC is enabled for SketchyBar. It permits automation by other processes running
  as your macOS user; OmniWM's secret is not a per-application security boundary.
- SketchyBar's LaunchAgent sets `NOCTALIA_WM=omniwm`. A separate
  `org.nixos.omniwm-sketchybar` agent watches `active-workspace` and triggers
  updates; five-second polling covers startup, reconnects, and previews.
- `org.nixos.omniwm-bluetooth-power` publishes read-only accessory battery data
  every 30 seconds for Noctalia. The editable helper is `bin/bluetooth-power.sh`;
  see [Bluetooth battery data](shell/noctalia/README.md#bluetooth-battery-data)
  for matching, expiry, and stop instructions. It does not start SketchyBar.
- Inner gaps are 20pt **between windows only** (`niri.edgeGaps = false`), so
  single- and multi-window workspaces share the same outer margins. Outer
  side/bottom gaps are 10pt. The 48pt top gap is
  measured from the **physical screen edge** and reserves the 38pt SketchyBar
  plus border clearance. Outer gaps also apply to single-window and WM-fullscreen
  layouts. Native macOS fullscreen is separate. Check spacing visually on each
  display after activation; no display-specific overrides are assumed.

Home Manager installs `~/.config/omniwm/settings.toml` through an out-of-store
symlink to `~/dotfiles/.config/omniwm/settings.toml`. Keep the checkout
at that location. Nix still manages the app, LaunchAgent, and symlink, but the
settings file stays writable in the repository.

Rebuild/switch once to install the symlink. After that, edit **this source** or
change settings in OmniWM's GUI without rebuilding. OmniWM follows and
preserves the symlink when saving, so GUI edits update the tracked source.
OmniWM watches external file edits and applies valid settings automatically.
Review the resulting Git diff before committing: GUI saves reserialize the TOML,
replacing comments and formatting. Later rebuilds relink the same live source;
they do not restore settings from a Nix-store snapshot.

### OmniShell prototype

The config lives in `~/dotfiles/.config/omniwm/`, beside the other application
configs; the directory relocation is complete. Nix manages packages, services,
and links, not the editable application source.

[`shell/noctalia/README.md`](shell/noctalia/README.md) describes the separate
**Noctalia** style: detached Macchiato pills using native OmniShell widgets.
Preview it in **Settings → Styles & Widgets** before choosing **Use Style**.
The initial selector in `shell/shell.toml` keeps **Default** active. Home Manager
links that writable selector and the `shell/noctalia/` profile individually;
OmniWM still owns and updates its bundled `shell/default/` directory.

The old shared AeroSpace configuration and JankyBorders package/configuration
are retained for rollback. AeroSpace's disabled startup hook no longer starts
borders, but the existing Homebrew borders service must be stopped separately.
Homebrew remains disabled in the workbook's Nix configuration; no tap/cask or
flake-lock changes are needed for this migration.

## Upgrade from 0.7.6 to 0.8.0

The package override retains nixpkgs' signed-app installation and changes only
OmniWM and its CLI; SketchyBar remains the desktop bar. The upgrade has already
migrated the settings to schema v5. The existing Workspace Bar and Hidden Bar
enable flags are preserved; the new Dynamic Island defaults to disabled.

On first launch, 0.8.0 backs up the exact old file to
`~/.config/omniwm/settings.toml.pre-v5` (or `.pre-v5.1` if the first slot is used),
then rewrites the symlink's repository target as schema v5. This preserves the
configured bindings while renaming the resize action IDs to `resize...shrink`
and `resize...grow`. The rewrite removes comments and reformats TOML; review the
Git diff afterward. Keep the backup: a Nix generation rollback does **not** undo
changes to this writable file.

To downgrade to 0.7.6, stop OmniWM and its KeepAlive LaunchAgent first, restore
the schema-v4 backup to `~/dotfiles/.config/omniwm/settings.toml`, and then activate the old
package. Version 0.7.6 cannot read schema v5. After upgrading, check
`omniwmctl version` reports 0.8.0; the command reports the running app, not just
the CLI package.

## Shortcut essentials

| Action | Shortcut |
| --- | --- |
| Switch workspace 1–9 | Option + 1–9 |
| Move window to workspace | Option + Shift + 1–9 |
| Focus left/right column (scroll into view) | Option + H / L |
| Focus down/up within a column | Option + J / K |
| Move window | Option + Shift + Arrow |
| Move workspace to left/right monitor | Control + Option + Shift + H / L |
| Move workspace to monitor below/above | Control + Option + Shift + J / K |
| Previous workspace | Control + Option + Tab |
| Focus previous window | Option + Tab |
| Resize column | Option + Minus / Equal |
| Cycle size | Option + Comma / Period |
| Column tabs | Option + T |
| WM fullscreen | Option + Return |
| Overview | Option + Shift + O |
| Command palette | Control + Option + Space |
| Quake terminal | Option + Grave |

Option + H/J/K/L replaces Option + Arrow for directional focus. The workspace
transfer shortcuts move the **entire active workspace** to the adjacent monitor;
use the opposite direction to bring it back. They do not swap the other monitor's
active workspace and do not wrap when there is no monitor in that direction.
Placement is a temporary runtime override: restarting OmniWM or reapplying
settings restores the configured home-monitor assignments. Native fullscreen
and other unsafe window/focus states may block a transfer.

Window movement and other shortcuts retain their OmniWM 0.7.6 defaults. The former
Hyper bindings, lettered workspaces, and AeroSpace service mode are not carried
over. [Release-specific shortcut source](https://github.com/OmniNull/OmniWM/tree/v0.7.6/Sources/OmniWM/Core/Input).

## Prepare without activation

From `~/dotfiles/.config/nix`:

```sh
# path:. includes the new, not-yet-tracked files without staging unrelated work.
nix build --no-link 'path:.#darwinConfigurations.workbook.system'
nixfmt --check modules/omniwm.nix modules/hosts/darwin/workbook.nix

cd ../sketchybar-noctalia
lua tests/run.lua
NOCTALIA_WM=omniwm lua tests/run.lua
NOCTALIA_PREVIEW=1 BAR_NAME=noctalia-test lua tests/run.lua
NOCTALIA_WM=omniwm NOCTALIA_PREVIEW=1 BAR_NAME=noctalia-test lua tests/run.lua
sh tests/launcher.sh
```

These tests fake macOS/network/SketchyBar calls and never switch workspaces.
A system **build** writes to the Nix store; it does not apply the configuration,
start OmniWM, reload SketchyBar, or stop AeroSpace/borders.

## Activate later, only when ready

1. Confirm **System Settings → Desktop & Dock → Mission Control → Displays have
   separate Spaces** is on. If changed, log out/in before proceeding.
2. Save work and finish a successful build using the command above.
3. Stop the old user services so two WMs/border renderers cannot compete:

   ```sh
   brew services stop borders
   launchctl bootout "gui/$(id -u)/org.nix-community.home.aerospace"
   ```

4. Apply the new configuration:

   ```sh
   cd ~/dotfiles/.config/nix
   sudo darwin-rebuild switch --flake 'path:.#workbook'
   ```

5. Grant OmniWM **Accessibility** and **Input Monitoring** when prompted. Screen
   Recording is optional for Overview thumbnails. Full Disk Access is optional
   for tiling, but Noctalia's notification widget needs it to read retained
   notifications. Complete OmniWM's permission/start window.
6. Check `omniwmctl ping`, workspace keys 1–9, moving windows, native borders,
   SketchyBar workspace updates/clicks/scrolling, and laptop/external-display gaps.
   Check that AeroSpace and JankyBorders are no longer running. The full first
   launch, permission flow, tiling, and visual spacing still need live acceptance.

For an OmniWM preview from a normal shell, explicitly select the backend:

```sh
NOCTALIA_WM=omniwm ~/.config/sketchybar/preview
```

The production backend is set by launchd, not by a global shell environment.
The default without this variable is still AeroSpace, preserving other hosts
and allowing the pre-migration bar to reload safely before activation.

### Rollback

For a durable configuration rollback, remove `omniwm` from **both** module lists
in `modules/hosts/darwin/workbook.nix`, then rebuild/switch again. This restores
AeroSpace's original settings/LaunchAgent and the bar's default backend, and
removes the OmniWM and watcher agents. Do not run both window managers together.

For an immediate rollback after a completed switch:

```sh
sudo darwin-rebuild switch --rollback
brew services start borders
```

Check the previous generation first with `darwin-rebuild --list-generations`;
the rollback command returns to the previous whole-system configuration, not
only the window manager. Source changes remain and should also be reverted via
the module-list change before a subsequent normal rebuild.

If the first switch fails before creating a generation and the old AeroSpace
plist is still installed, restart the old services instead:

```sh
launchctl bootstrap "gui/$(id -u)" "$HOME/Library/LaunchAgents/org.nix-community.home.aerospace.plist"
brew services start borders
```
