local wezterm = require("wezterm")
local config = wezterm.config_builder()

local cfg_file = wezterm.config_file
local cfg_dir  = cfg_file:gsub("[^/\\]+$", ""):gsub("\\", "/")
package.path = table.concat({
  cfg_dir .. "?.lua",
  package.path,
}, ";")

config.leader = { key = " ", mods = "SHIFT", timeout_milliseconds = 2000 }
config.disable_default_key_bindings = true
config.keys = require("keybinds").keys
config.key_tables = require("keybinds").key_tables

config.automatically_reload_config = true
config.use_ime = true
config.default_cursor_style = "BlinkingBar"
config.default_prog = { "wsl", "~", "zsh" }
config.unix_domains = {{ name = 'idle' }}

config.color_scheme = "Tokyo Night Moon"
config.font = wezterm.font('HackGen Console', { weight = 'Regular'})
config.font_size = 13.0

config.window_frame = { active_titlebar_bg = "none" }
config.window_decorations = "RESIZE"
config.window_close_confirmation = "NeverPrompt"
config.window_background_gradient = { colors = { "#000000" } }
config.background = {
  {
    source = { File = wezterm.config_dir .. "/backgrounds/background.jpg" },
    opacity = 0.2,
    width = "100%",
    height = "100%",
  }
}

config.show_new_tab_button_in_tab_bar = false
config.show_close_tab_button_in_tabs = false

config.inactive_pane_hsb = {
  saturation = 0.3,
  brightness = 0.3,
}

config.colors = {
  tab_bar = {
    inactive_tab_edge = "none",
  },
}

wezterm.on("format-tab-title", function(tab)
  local background = tab.is_active and "#ae8b2d" or "#5c6d74"

  return {
    { Background = { Color = "none" } },
    { Foreground = { Color = background } },
    { Text = wezterm.nerdfonts.ple_lower_right_triangle },
    { Background = { Color = background } },
    { Foreground = { Color = "#FFFFFF" } },
    { Text = "    " .. tab.active_pane.current_working_dir.file_path .. "    " },
    { Background = { Color = "none" } },
    { Foreground = { Color = background } },
    { Text = wezterm.nerdfonts.ple_upper_left_triangle },
  }
end)

wezterm.on('gui-startup', function (cmd)
  -- tab1
  local tab1, pane1, window = wezterm.mux.spawn_window(cmd or {})
  pane1:send_text("note\n")
  window:gui_window():maximize()

  -- tab2
  local _, root = window:spawn_tab({})
  local left_top = root
  local right_top = root:split({
    direction = "Right",
    size = 0.5,
  })
  left_top:send_text("cd docker\n")
  right_top:send_text("cd auth\n")
  left_top:split({
    direction = "Bottom",
    size = 0.5,
  })
  right_top:split({
    direction = "Bottom",
    size = 0.5,
  })

  -- tab3
  window:spawn_tab({})

  tab1:activate()
end)

return config
