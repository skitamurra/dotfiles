local wezterm = require("wezterm")
local config = wezterm.config_builder()
local cfg_file = wezterm.config_file
local cfg_dir  = cfg_file:gsub("[^/\\]+$", ""):gsub("\\", "/")
package.path = table.concat({
  cfg_dir .. "?.lua",
  package.path,
}, ";")

config.leader = { key = " ", mods = "SHIFT", timeout_milliseconds = 300 }
config.disable_default_key_bindings = true
config.keys = require("keybinds").keys
config.key_tables = require("keybinds").key_tables
config.automatically_reload_config = true
config.default_cursor_style = "BlinkingBar"
config.default_prog = { "wsl", "~", "zsh" }
config.color_scheme = "Tokyo Night Moon"
config.font = wezterm.font('HackGen Console', { weight = 'Regular'})
config.font_size = 13
config.window_frame = {
  active_titlebar_bg = "none",
  font = wezterm.font('HackGen Console', { weight = 'Bold'}),
  font_size = 10,
}
config.window_decorations = "RESIZE"
config.window_close_confirmation = "NeverPrompt"
config.unix_domains = { { name = "unix" } }
config.default_gui_startup_args = { "connect", "unix" }
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
  saturation = 0.4,
  brightness = 0.4,
}
config.colors = {
  tab_bar = {
    inactive_tab_edge = "none",
  },
}

require("workspace").apply_to_config(config)
require("tab").apply_to_config(config)
require("startup").apply_to_config(config)
return config
