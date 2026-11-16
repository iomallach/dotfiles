# Noctalia — OmniShell prototype

Detached Catppuccin Macchiato pills, matching the existing SketchyBar theme rather
than imitating the macOS menu bar. This is a local style for OmniWM **0.8.0**.

```text
[ 1 Apps · 2 Apps · ●3 Apps … ] [ ♫ Track ]   [ Focused app / window ]   [ ✨ Pi agents ] [ Notifications | Controls ] [ ᛒ 2 | Volume | Battery ] [ Weather | Clock ]
```

The 38pt transparent canvas holds 30pt dark capsules with subtle borders, rounded
ends, pastel icons, and matte popouts. Workspaces show their labels and native
app icons, retaining focus, previews, context-menu, Shift-click, and drag/drop
behavior. The center shows Default's focused app/window widget. The right side
starts with a separate **Pi agents** information pill, followed by three shared
capsules: **notifications + control center**, **Bluetooth + volume + battery**,
and **weather + clock**. Each has one background
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

The native Settings lane editor now lists four trailing entries: **Agents**,
**Control Center**, **Bluetooth**, and **Weather**. The last three represent groups. Weather's
options include clock date/icon and forecast hours; Bluetooth's include battery
percentage layout and volume scroll step. Control Center retains its initial-tab
option. The shared Weather Location editor remains available.

| Widget section | Native interaction |
| --- | --- |
| Workspaces | Labels + app icons; click to focus; app previews; native menus and drag/drop |
| Media | Source app icon, playing/paused badge, and progress; click for controls, right-click to toggle |
| Active window (center) | Focused app icon/title; click to open the native window picker |
| Pi agents | Agent/attention count; click only opens an informational status popout, with page navigation |
| Weather | Click for conditions/forecast, or setup guidance when no reading is available |
| Notifications | Native retained notifications, permission/status messages, and supported actions |
| Control center | Native overview, audio, media, calendar, weather, and system tabs |
| Bluetooth | Connected count; click for labeled battery percentages and native permission/settings actions |
| Volume | Click for slider/output controls; scroll to adjust |
| Battery | Click for power details; percentage layout remains configurable |
| Clock | Compact next-event line below date/time; click for calendar; date and icon remain configurable |

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

### Pi agent status

`widgets/agents/` and `lib/agent-status.luau` implement an informational popout.
The pill shows the number of connected interactive Pi sessions and adds `!N`
when approval or input is needed. The panel lists working, idle, waiting-for-input,
interactive-UI, and explicit Editgate approval states, with project/session/model
and the proposed path/reason where available. Each status shows its elapsed
duration (for example `Working · 2m 13s`), which is not reset by heartbeat,
tool, model or usage updates. Available metrics below the model show current
context tokens/capacity/percentage and Pi's recorded session cost in USD. Cost
uses all recorded session history and is an estimate; unpriced models can report
zero. Unknown values are not fabricated as zero. Timing starts with the reporter;
a widget reload preserves it, but a Pi extension reload starts a new observer.
Run `/reload` in existing Pi sessions to load the new timing/usage fields.
Four agents fit per page; arrows
only change the information page. There are **no terminal/browser launches,
focus commands, messages, or approve/deny controls**.

The companion extension is
`~/dev/pi-extensions/extensions/omniwm-agents/`. It is installed through Pi's
extension-discovery symlink; running Pi sessions must `/reload` to start sending
status. New sessions load it automatically. It sends complete snapshots through
`omniwmctl shell trigger agents snapshot` every five seconds and on transitions.
A source/profile reload rehydrates within one heartbeat. Normal shutdown removes
an entry; crashes expire after 30 seconds. No per-agent shell variables, network
permissions, macOS notifications, or additional daemon are needed.

Generic custom Pi screens may be loaders or questions, so they are labeled
**Interactive UI**, not guessed to be waiting for input. Editgate emits its own
review events, which stay **Awaiting approval** across fullscreen/editor/feedback
transitions. No prompts, full diffs, file contents or browser approval tokens are
sent to the widget. Existing Editgate review UIs remain unchanged.

Remove `agents` from this profile's trailing list to hide it; remove the Pi
reporter symlink and `/reload` to stop reporting. The companion extension's README
contains the event protocol and real-Pi/OmniWM test command.

### Media source and progress

The pill uses the Now Playing source app's icon: Spotify for Spotify, the browser
for browser playback, and a music-note fallback if app identity is unavailable.
It does not infer a YouTube logo from the title or inspect browser tabs. A small
green play/yellow pause badge and paused text/progress styling show playback state.

The thin line matches the label's native measured width, up to the existing
200pt long-title cap. Short titles shrink the text area and progress track
together; Unicode and proportional fonts need no character-count estimate.
Progress appears only when a finite positive duration and valid elapsed position
are reported. Native sample time/rate advance
it while playing; pausing freezes it. Missing timing information leaves the last
known sample rather than inventing a rate, and missing duration/position hides the
line. Values stay within the track bounds; new tracks/sources do not retain the
previous item's progress.

The media widget refreshes once per second using native data. No Spotify polling,
browser scripting, new permission, or background service is involved. Click still
opens the original media popup; right-click still toggles playback.

### Next calendar event

The clock shows a small second line beneath the date/time, for example
`In 18 min · Team sync`, inside the existing weather/clock capsule. It stays on
one line, capped at 160pt (scaled with the bar); long titles truncate, with the
full summary available on hover. The bar and capsule heights are unchanged.
Clicking anywhere in the clock section still opens the native calendar popup.

This reuses OmniWM's native calendar feed and selection: the first ongoing or
upcoming timed event within the next 12 hours. Events starting within an hour
show a countdown, ongoing events show `Now`, and later events show their start
time. All-day and ended events are skipped. With no matching event or no calendar
access, the extra line disappears and the original date/time layout remains.

Calendars must be synced into macOS Calendar. Grant access explicitly through
**Allow Calendar Access** in the clock popup if needed; rendering the bar never
requests permission. There is no new helper, network integration, or event store.

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
    ├── lib/media-progress.luau # bounded native playback position/extrapolation
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
