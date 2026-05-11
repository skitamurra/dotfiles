local wezterm = require("wezterm")
local config = wezterm.config_builder()
local cfg_file = wezterm.config_file
local cfg_dir  = cfg_file:gsub("[^/\\]+$", ""):gsub("\\", "/")
package.path = table.concat({ cfg_dir .. "?.lua", package.path }, ";")

local default_domain = wezterm.default_wsl_domains()[1].name
config.default_domain = default_domain
config.default_mux_server_domain = default_domain
config.unix_domains = { { name = "unix" } }
config.default_gui_startup_args = { "connect", "unix" }
config.leader = { key = " ", mods = "SHIFT", timeout_milliseconds = 300 }
config.disable_default_key_bindings = true
config.keys = require("keybinds").keys
config.key_tables = require("keybinds").key_tables
config.automatically_reload_config = true
config.default_cursor_style = "BlinkingBar"
config.color_scheme = "Tokyo Night Moon"
local font = 'Moralerspace Argon HW'
config.font = wezterm.font(font, { weight = 'Regular'})
config.font_size = 13
config.command_palette_font = wezterm.font(font, { weight = "Regular" })
config.command_palette_font_size = 13
config.window_frame = {
  active_titlebar_bg = "none",
  font = wezterm.font(font, { weight = 'Bold'}),
  font_size = 10,
}
config.window_decorations = "RESIZE"
config.window_close_confirmation = "NeverPrompt"
config.window_background_gradient = { colors = { "#000000" } }
config.window_background_opacity = 0.5
config.win32_system_backdrop = 'Acrylic'
config.show_new_tab_button_in_tab_bar = false
config.show_close_tab_button_in_tabs = false
config.inactive_pane_hsb = { saturation = 0.4, brightness = 0.4 }
config.colors = {
  tab_bar = {
    inactive_tab_edge = "none",
  },
}
config.max_fps = 120

require("workspace").apply_to_config(config)
require("tab").apply_to_config(config)
require("startup").apply_to_config(config)
return config
