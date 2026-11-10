# Noctalia — OmniShell prototype

Detached Catppuccin Macchiato pills, matching the existing SketchyBar theme rather
than imitating the macOS menu bar. This is a local style for OmniWM **0.8.0**.

```text
[ 1 Apps · 2 Apps · ●3 Apps … ] [ ♫ Track ]   [ Focused app / window ]   [ Notifications | Controls ] [ ᛒ 2 | Volume | Battery ] [ Weather | Clock ]
```

The 38pt transparent canvas holds 30pt dark capsules with subtle borders, rounded
ends, pastel icons, and matte popouts. Workspaces show their labels and native
app icons, retaining focus, previews, context-menu, Shift-click, and drag/drop
behavior. The center shows Default's focused app/window widget. The right side
has three shared capsules, in order: **notifications + control center**,
**Bluetooth + volume + battery**, and **weather + clock**. Each has one background
and border with subtle internal dividers, not smaller bubbles inside it. There
are no Apple/app-menu labels or extra system-stat buttons.

## Preview without changing the desktop

1. Open OmniWM **Settings → Styles & Widgets**.
2. Select **Noctalia** in the style strip to inspect its preview.
3. Leave **Use Style** alone until you want to try it on the desktop.

The initial repository selector is `profile = "default"`: installing the profile
does not select it. Stock Default sources, window gaps, and the Dynamic Island
enable switch are untouched. SketchyBar has been stopped separately; selecting
or editing this style does not start it. The style is linked into
`~/.config/omniwm/shell/noctalia/`; no app restart is needed.

Settings previews use **sample data**, not the live music/weather/Bluetooth
integrations. Native rendering, display/notch fit, and popout interaction still
need visual acceptance when the style is selected.

## Try it later / roll back

Use **Use Style**, or explicitly select it from a terminal:

```sh
omniwmctl shell profile noctalia
omniwmctl query shell-widgets
```

Return to the stock style with:

```sh
omniwmctl shell profile default
```

Like stock Default, this is a full-width top bar, but its background is fully
transparent. OmniWM manages the native menu bar's auto-hide preference for these
full-width styles. The profile does not add replacement Apple/app-menu widgets.
It uses the existing 48pt outer top gap without requesting an additional bar
reservation; it does not modify the gap settings themselves.

## Widgets

Each section remains its own click target and opens its original panel content,
anchored to that section. A shared capsule uses native popup-toggle behavior:
clicking it again closes its popup. Popup state is scoped per section, so the
control-center tab, notification drafts, and volume scroll accumulation do not
leak into one another. Volume scrolling acts only on the volume section and does
not open a popup. Missing Bluetooth/battery feeds leave no empty separators.

The native Settings lane editor now lists three trailing entries: **Control
Center**, **Bluetooth**, and **Weather**, representing the groups. Weather's
options include clock date/icon and forecast hours; Bluetooth's include battery
percentage layout and volume scroll step. Control Center retains its initial-tab
option. The shared Weather Location editor remains available.

| Widget section | Native interaction |
| --- | --- |
| Workspaces | Labels + app icons; click to focus; app previews; native menus and drag/drop |
| Media | Click for Now Playing controls; right-click to toggle playback |
| Active window (center) | Focused app icon/title; click to open the native window picker |
| Weather | Click for conditions/forecast, or setup guidance when no reading is available |
| Notifications | Native retained notifications, permission/status messages, and supported actions |
| Control center | Native overview, audio, media, calendar, weather, and system tabs |
| Bluetooth | Connected count; click for labeled battery percentages and native permission/settings actions |
| Volume | Click for slider/output controls; scroll to adjust |
| Battery | Click for power details; percentage layout remains configurable |
| Clock | Click for calendar; date and icon remain configurable |

This first pass inherits OmniWM's native **click popouts**, not SketchyBar's
hover-to-open behavior. Media follows macOS Now Playing, rather than polling
Spotify directly. Missing media/Bluetooth/battery feeds disappear, but Weather
stays visible as `Weather —` with setup/unavailable guidance until a reading is
available; disabled or blocked Weather shows the native status instead.
Bluetooth access is requested only through its native permission action.
Notifications require **Full Disk Access** to read retained entries; the native
panel explains missing access without automatically granting/requesting it.

Weather needs a city or coordinates: open **Settings → Styles & Widgets →
Noctalia → Bar → Weather → Weather Location**, or set
`profiles.noctalia.weather.city` in `../shell.toml`. The GUI location editor is
shared across styles; the profile-specific key scopes a hand-edited location to
Noctalia. No location is guessed and no network request runs from a Settings
preview.

### Bluetooth battery data

The pill shows the number of **connected** devices, not all paired devices;
`Off` means Bluetooth is off and `—` means permission/data is unavailable.
The popup labels available **Battery / Left / Right / Case** percentages and
shows `Battery not reported` when no trustworthy reading exists. Disconnected
devices never keep old battery numbers. Permission and Bluetooth Settings
buttons retain their native actions; opening the popup does not pair or connect
anything.

[`../../bin/bluetooth-power.sh`](../../bin/bluetooth-power.sh) reads the same
`pmset -g accps` accessory report
used by SketchyBar. The `org.nixos.omniwm-bluetooth-power` user LaunchAgent runs
it at login and every **30 seconds**, publishing one timestamped runtime value
through `omniwmctl shell set`. No network, new package, or device-control command
is involved. Nix wires the service; the editable helper stays in dotfiles.

Native readings always win. Accessory data only fills a device with **no native
battery values**, matching a uniquely named connected device. Duplicate names,
the laptop battery, invalid values, reports over 90 seconds old, and future-dated
reports are rejected. Zero percent is valid. Collection failures clear the
runtime value; IPC/startup failures retry at the next scheduled run. A 15-second
widget refresh also expires a stopped helper's old data.

Check or stop just the helper:

```sh
launchctl print "gui/$(id -u)/org.nixos.omniwm-bluetooth-power"
launchctl bootout "gui/$(id -u)/org.nixos.omniwm-bluetooth-power"
```

Stopping the helper leaves native Bluetooth readings available; accessory
fallbacks expire without restarting OmniWM. Normal Nix activation/login starts
the configured helper again. Missing device readings remain explicit rather
than being guessed.

## Source ownership

```text
.config/omniwm/shell/
├── shell.toml                 # active selector + per-style GUI overrides
└── noctalia/
    ├── style.toml             # local style metadata
    ├── shell.toml             # default layout and bar appearance
    ├── themes/macchiato.toml  # palette, deliberately dark in either appearance
    ├── lib/look.luau          # presentation hooks shared by native widgets
    ├── lib/bluetooth-details.luau # validated native/accessory battery merge
    ├── lib/capsule-group.luau # shared surfaces, callback/state scoping, popup routing
    ├── lib/weather-widget.luau # visible unavailable state + native weather forecast
    └── widgets/              # weather/clock, Bluetooth/volume/battery, notifications/controls
```

Home Manager links the selector and this profile separately. OmniWM continues to
own `~/.config/omniwm/shell/default/`; it can update that directory normally.
GUI style choices/options write through the selector's writable symlink into the
repository. Per-style overrides there take precedence over the profile defaults.
There are no top-level widget/library overrides that would change other styles.

Nix also generates six uniquely named `shell/lib/noctalia-native-*.luau` modules
from the **same pinned OmniWM package**. These make the native render/popout
functions importable and adapt their relative library paths. No upstream widget
implementation is copied into the repository. Flat file links are deliberate:
OmniShell does not traverse a symlinked library subdirectory. The adapters use
Noctalia's palette/hooks but retain upstream notification actions, controls,
calendar behavior, and permissions. Stock Default does not import them.

## Checks

From `~/dotfiles/.config/nix`:

```sh
nix shell 'path:.#darwinConfigurations.workbook.pkgs.luau' \
  --command python3 ../omniwm/tests/run.py
nixfmt --check modules/omniwm.nix
nix build --no-link 'path:.#darwinConfigurations.workbook.system'
```

The Python/Luau checks render the resolved profile/native widgets against an
offline mock host, exercise missing/zero data, native actions, accessory matching
and expiry, and verify capsule geometry. Isolated subprocess fakes test publisher
quoting and failure handling without invoking device commands. Group tests check
one background per capsule, popup routing, isolated state, retained scrolling,
and missing-data layout. They do **not** validate AppKit layout or activate a
style. The installed Home Manager adapter links are required for these checks.
`OMNIWM_SHELL_DIR` can point at another installed shell directory for testing.

## Credits

- [Noctalia](https://noctalia.dev/) for the detached-pill visual direction.
- [Catppuccin Macchiato](https://catppuccin.com/palette/) for the palette.
- [OmniWM](https://github.com/OmniNull/OmniWM) for the inherited GPL-2.0-only
  widgets, libraries, integrations, and style API. The custom Luau presentation
  hooks use GPL-2.0-only as well; no bundled sources or assets are vendored.
