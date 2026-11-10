return {
  -- Catppuccin Macchiato; edit colors.lua to change the palette.
  font = "SF Pro Text",
  icon_font = "JetBrainsMono Nerd Font",
  mono_font = "JetBrainsMono Nerd Font",

  bar = {
    height = 38,
    pill_height = 30,
    margin = 10,
    y_offset = 0,
    display = "main", -- "all" to repeat on every display
  },

  clock = {
    format = "%a %d %b  ·  %H:%M",
  },
  weather = {
    -- Empty = wttr.in's IP-based location. A city or "latitude,longitude"
    -- makes this deterministic, e.g. "Berlin" or "52.52,13.41".
    location = "",
    unit = "c", -- "c" or "f"
    interval = 900,
    stale_after = 3600,
  },
  bluetooth = {
    interval = 15, -- polling fallback; hovering also refreshes immediately
  },
  workspace = {
    -- workbook's Nix LaunchAgent sets omniwm; other sessions keep AeroSpace.
    backend = os.getenv("NOCTALIA_WM") or "aerospace",
    -- Polling also keeps separately named previews in sync.
    interval = 5,
  },
  spotify = {
    max_chars = 32,
    interval = 15,
  },
}
