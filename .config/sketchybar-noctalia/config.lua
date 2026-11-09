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
  aerospace = {
    -- The existing aerospace_workspace_change hook works as-is. Polling
    -- also keeps a separately named preview in sync without changing it.
    interval = 5,
  },
  spotify = {
    max_chars = 32,
    interval = 15,
  },
}
