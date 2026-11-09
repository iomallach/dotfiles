# Noctalia-inspired SketchyBar

A standalone **Lua** configuration with Catppuccin **Macchiato** colors, floating
rounded capsules, pastel accents, restrained typography, and small popovers.
Inspired by Noctalia rather than a port of its Qt/Wayland shell.

```text
 ╭────────╮  ╭─────────────────────────────╮        ╭────────╮ ╭──────╮ ╭───────╮ ╭───────╮ ╭────────────────────────╮
 │ ▣   1  │  │   Track title · Artist     │        │ ☀ 14°C │ │ 󰂯  2 │ │ ◖ 32% │ │ ▰ 71% │ │ ◷ Mon 09 Nov · 14:32  │
 ╰────────╯  ╰─────────────────────────────╯        ╰────────╯ ╰──────╯ ╰───────╯ ╰───────╯ ╰────────────────────────╯
 workspace             Spotify                      weather  Bluetooth  volume   battery            date/time
```

The center stays empty for the MacBook notch. The bar is transparent; each
capsule has its own dark background, fine border, and animated accent on hover.
Only the focused AeroSpace workspace is shown, not a row of empty workspaces.

**Active installation:** `~/.config/sketchybar` now links to this directory,
and Nix's `configSources.sketchybar` points here. The older repository config
in `../sketchybar` is untouched; the previously installed configuration was
backed up separately. Preview and tests do not change the active link or service.

## Requirements

- macOS, SketchyBar, Lua 5.4, and [SbarLua](https://github.com/FelixKratz/SbarLua).
- SbarLua's `sketchybar.so` on Lua's normal C module path or in
  `~/.local/share/sketchybar_lua/` (already installed on this machine).
- AeroSpace CLI on `PATH`; Spotify installed for media integration.
- **SF Pro Text** (macOS) and **JetBrainsMono Nerd Font**. Fonts are configurable.
- macOS's `osascript`, `pmset`, `system_profiler`, `open`, and `curl`; no extra
  Lua packages, compiled helpers, Bluetooth utility, weather API key, Python,
  or Node are needed.

Spotify uses Apple Events. macOS may ask for Automation permission; if blocked,
allow the requesting process to control Spotify under **System Settings →
Privacy & Security → Automation**. Routine polling does not launch Spotify.
Metadata reads use a five-second Apple Events timeout and an eight-second
in-flight watchdog, so a missing callback cannot freeze updates indefinitely.
Failures show **Spotify unavailable** with a permission/timeout/read-error reason
in the popup; later polls or notifications retry automatically. Late replies
from expired requests cannot overwrite newer track information.

## Preview without switching

```sh
cd ~/dotfiles/.config/sketchybar-noctalia
./preview
```

This starts a **separate, named `sketchybar-noctalia` instance**, below the current
bar (`y_offset = 52`). Both the installed bar and preview use a floating window
layer so tiled apps cannot cover widgets or interrupt entry into their popups.
Stop the preview with **Ctrl-C**. The launcher cleans up its own bar and Lua process; it never
kills/reloads the production bar or changes gaps. Only one preview can run at
a time. It can overlap application windows because it deliberately does not
edit AeroSpace's layout.

The existing AeroSpace hook targets the production instance, so the installed
bar updates immediately on workspace changes. A separate preview still uses
the five-second focused-workspace polling fallback. Native Spotify, volume,
power, and wake events work in either instance.

For a non-visible runtime check: `NOCTALIA_HIDDEN=1 ./preview`.

## Widgets and interactions

| Widget | Hover | Click / scroll |
| --- | --- | --- |
| AeroSpace | No popup | Left: previous workspace; right: open AeroSpace; scroll: cycle workspaces |
| Spotify | Track/artist/album + previous/play/next + open Spotify | Left: play/pause, if Spotify is running |
| Date/time | Current-month calendar with today in bold mauve, link to Calendar | — |
| Weather | Conditions, feels-like, humidity, last update, refresh, forecast | Click: retry if weather is unavailable |
| Volume | Draggable volume slider + Sound settings | Left: toggle mute; scroll: ±2% |
| Bluetooth | Connected-device names, type icons, reported battery levels, settings | Click: refresh |
| Battery | Charge state, remaining time, Battery settings | — |

Popovers open on hover and stay open while moving into their controls. A brief
150ms close grace period prevents flicker between the pill and popup rows.
They close after leaving the owning widget and its controls, and are mutually
exclusive; clicking a hovered widget does not toggle its popup shut. Weather keeps the
last good reading during failures; after an hour
it dims the icon, adds a `·` marker, and labels the popup **Stale**. Without any
reading it shows `—`, not a made-up temperature. Desktops show **AC** instead of
a missing battery percentage. Missing AeroSpace shows **Offline**. Spotify
remains as a quiet launcher/control pill when not playing.

Bluetooth shows the **number of connected devices**, not the number of paired
ones. `system_profiler` supplies the connected list and any main/left/right/case
battery details. When a connected device has no battery details, the widget
also reads **`pmset -g accps`**, macOS's built-in accessory-power report. This
supplies percentages for the Corne and MX Master 3S even though the Bluetooth
profiler report omits them; no additional utility or firmware change is needed.

Accessory readings are matched by exact device name after whitespace/case
normalization. Only unique matches are used; existing profiler battery details
are preserved, and the laptop battery is ignored. No cached percentage is kept
when a reading disappears. Missing or ambiguous values remain **Battery not
reported** instead of being guessed. Corne currently reports a single battery
value, not separate left/right levels.

Bluetooth-off and no-device states show `0`. A device-list query failure shows
`—` and hides old entries; an optional accessory-power query failure preserves
the connected list and any profiler battery data. Both reads are asynchronous.
Discovery is read-only: no device is connected, disconnected, paired, or
queried directly over BLE.

## Customize

Edit **`config.lua`**:

- `weather.location`: empty for IP-based detection, or a city / `"lat,lon"`.
  A fixed location avoids VPN-related surprises. `weather.unit`: `"c"` or `"f"`.
- `weather.interval`: request interval in seconds (default 15 minutes).
- `clock.format`: standard Lua `os.date` format; default 24-hour time.
- `bluetooth.interval`: local polling interval in seconds (default 15).
  Hovering also refreshes immediately. Both reports are read asynchronously;
  `system_profiler` uses a 10-second reporting timeout. No additional
  AeroSpace/launchd wiring is needed.
- `bar.display`: `"main"` or `"all"`; dimensions, margins, fonts, and Spotify
  truncation are configurable too.

Weather makes one bounded HTTPS request to **wttr.in**, which sees your public
IP and any configured location. IP location uses that service's geolocation;
there is no separate location lookup. Requests run asynchronously, time out
after 15 seconds, and never block the bar. All other external commands are also
asynchronous. Spotify metadata is Unicode-truncated to avoid crowding the bar.

Palette: **`colors.lua`**. Icons: **`icons.lua`**. Widget modules: **`widgets/`**.
The launcher resolves modules relative to its own location, not the working
directory, and explicitly targets SketchyBar's `BAR_NAME` for IPC isolation.

## Validate

```sh
lua tests/run.lua
sh tests/launcher.sh
find . -name '*.lua' -exec luac -p '{}' \;
sh -n sketchybarrc preview tests/launcher.sh
```

Tests use fake SketchyBar/macOS/network responses. They do not touch your audio,
workspace, apps, weather service, or active bar.

Validated on this machine with **SketchyBar 2.24.0 / Lua 5.4.7**: 36 regression
tests in both normal and preview modes, two launchd-style launcher checks,
Lua syntax checks, ShellCheck, and isolated runtime checks. All seven widgets initialized with live data or their
stopped-state fallback. The live Bluetooth count and device names matched the
macOS report; Corne and MX Master 3S battery levels matched `pmset -g accps`
in both an isolated instance and the active bar. Missing readings and optional
query failures are covered by the regression suite. Real pointer
tests verified two complete hover cycles across all six popups: opening,
entering controls, closing on exit, and reopening. Exclusive switching was
also checked. Native calendar checks confirmed the current-day
accent, the installed font's character spacing, and highlight retention after
reopening. Native Spotify checks matched live playing metadata and fault-tested
an unanswered read, watchdog expiry, successful retry, and rejection of a late
stale reply in an isolated instance. No playback commands or Spotify restart
were used. The production bar's configuration query was identical
before and after; the test instance was stopped and the pointer restored.
Font appearance, multiple displays, and Automation prompts still need visual
acceptance on the intended display.

## Active installation and rollback

Activated on 2026-11-09:

- `~/.config/sketchybar` → `~/dotfiles/.config/sketchybar-noctalia`.
- `../nix/modules/desktop-gui.nix` registers
  `sketchybar.source = "sketchybar-noctalia";` for future Nix/Home Manager activations.
- The existing `org.nixos.sketchybar` LaunchAgent still starts SketchyBar normally;
  no generated plist was edited. The launcher adds concrete user-profile paths
  because launchd does not expand `$HOME`/`$USER` embedded in its configured PATH.
- Only the SketchyBar service was restarted; no full Nix rebuild or unrelated
  pending Nix changes were applied. AeroSpace's hooks and gaps are unchanged.
- The original installed directory is preserved at
  `~/.config/sketchybar.before-noctalia-20261109-134741`. This is not the same
  version as the older `../sketchybar` repository copy.
- Activation/rollback metadata is in
  `~/.local/state/sketchybar-noctalia/activation.json`.

Reload after editing:

```sh
sketchybar --reload
```

Restart the persistent service:

```sh
launchctl kickstart -k "gui/$(id -u)/org.nixos.sketchybar"
```

To restore the previous installed configuration without deleting either version:

```sh
test -L "$HOME/.config/sketchybar" &&
  unlink "$HOME/.config/sketchybar" &&
  mv "$HOME/.config/sketchybar.before-noctalia-20261109-134741" "$HOME/.config/sketchybar" &&
  launchctl kickstart -k "gui/$(id -u)/org.nixos.sketchybar"
```

For a rollback to survive future Nix activations as well, remove the
`sketchybar.source = "sketchybar-noctalia";` entry from `desktop-gui.nix`.
The preview launcher and test suite never perform activation or rollback.
