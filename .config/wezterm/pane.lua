local wezterm = require 'wezterm'

wezterm.on("update-status", function(window)
  if window:active_key_table() == "pane_mode" then
    window:set_right_status(wezterm.format({
      { Background = { Color = "#CBB001" } },
      { Foreground = { Color = "#313244" } },
      { Attribute = { Intensity = "Bold" } },
      { Text = " PANE MODE " },
    }))
  else
    window:set_right_status("")
  end
end)

