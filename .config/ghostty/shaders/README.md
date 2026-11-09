# Ghostty cursor presets

Neovide-inspired effects, matched to the green/cyan `onedark_vaporwave` theme:

- **Comet** (default): bold green/cyan tapered smear with a wider glow; retracts
  over 480 ms. Short moves get a minimum tail so ordinary typing stays visible.
  The trail starts at the cursor edge, with comparable horizontal/vertical width.
- **Particles**: 14 bright cyan/pink sparks that scatter above and below the
  latest movement; fades in 850 ms, visibly distinct from the solid comet.
- **Off**: no shader or continuous shader animation.

These are post-processing effects, not Neovide's real cursor interpolation or
smooth scrolling. Only the most recent cursor movement is available, so a new
movement replaces the previous trail. Both shaders cap long jumps, fade away at
rest, preserve the real cursor/glyph, and leave terminal alpha unchanged. Hidden
cursor detection is supported when Ghostty exposes the newer visibility uniform.

## Activate

The shared Nix module (`.config/nix/modules/terminals.nix`) and standalone
`.config/ghostty/config` both include `shaders/preset.conf`. If using Home Manager,
apply your normal host rebuild once to activate that include. The shader directory
is already linked from this repository.

## Switch without rebuilding

Edit `~/.config/ghostty/shaders/preset.conf` (the symlink points into this repo).
Keep the initial empty `custom-shader =` line: it clears any previously selected
shaders. Then select **one** shader:

```ini
# Comet
custom-shader =
custom-shader = cursor_comet.glsl
custom-shader-animation = true
```

```ini
# Particles
custom-shader =
custom-shader = cursor_particles.glsl
custom-shader-animation = true
```

```ini
# Off
custom-shader =
custom-shader-animation = false
```

Reload using **Reload Config** in Ghostty's command palette, or the default
**Ctrl+Shift+,** on Linux / **Cmd+Shift+,** on macOS. Changes affect open terminals.
Don't stack these with the old blaze/smear shaders; those files are retained for
reference but are no longer selected.

### Linux: if the old effect persists

Send a reload directly to the running GTK app (verified on this Niri setup):

```sh
busctl --user call com.mitchellh.ghostty /com/mitchellh/ghostty \
  org.gtk.Actions Activate 'sava{sv}' reload-config 0 0
```

This reloads existing windows without closing sessions. With
`gtk-single-instance=true`, opening another window reuses the existing process;
it is not a fresh application start. Also, `ghostty +show-config` reads the files
on disk, not the configuration currently applied to that running process. A
correct CLI result alone does not verify that the visible shader changed.

## Tune

Edit the constants at the top of either `.glsl` file, then reload:

- `DURATION`: lifetime in seconds.
- `STRENGTH`: blend amount (lower is subtler and keeps text clearer).
- `MIN_LENGTH_CELLS`: minimum initial trail length for short moves (comet only).
- `MAX_LENGTH_CELLS`: maximum trail length, measured in cursor heights.
- `ACCENT`: cyan RGB accent; comet's other color follows Ghostty's cursor color.
- `SPARK_ACCENT`: contrasting pink RGB accent (particles only).
- `PARTICLE_COUNT`: spark count (particles only).

Shader animation runs continuously while the terminal is focused, even when the
effect has faded. Early returns reduce shader work, not the redraw rate. Choose
**Off** to avoid that cost; animation is not forced on unfocused terminals.

## Checks

From `.config/nix`:

```sh
nix shell nixpkgs#glslang --command bash ../ghostty/shaders/check.sh
```

This compiles both shaders with GLSL 330/430 and legacy/current cursor uniforms.
When Ghostty is installed, it also validates the preset include and confirms that
it clears the old shader stack. It does not replace visual testing on Linux/macOS.
