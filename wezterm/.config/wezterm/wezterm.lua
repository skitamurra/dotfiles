local wezterm = require("wezterm")
local mux = wezterm.mux
wezterm.on('gui-startup', function (cmd)
  -- tab1
  local tab1, pane1, window = mux.spawn_window(cmd or {})
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

----------------------------------------------------
-- require path 設定（WSL対応）
----------------------------------------------------
local cfg_file = wezterm.config_file
local cfg_dir  = cfg_file:gsub("[^/\\]+$", ""):gsub("\\", "/")

-- config直下 と config/lua/ を検索パスに先頭追加
package.path = table.concat({
  cfg_dir .. "?.lua",
  cfg_dir .. "?/init.lua",
  cfg_dir .. "lua/?.lua",
  cfg_dir .. "lua/?/init.lua",
  package.path,
}, ";")

-- Lua-only searcher を先頭に挿入（WSL ~/.config/wezterm と ~/.config/wezterm/lua を探索）
local function wsl_searcher(modname)
  local rel = modname:gsub("%.", "/")
  local candidates = {
    cfg_dir .. rel .. ".lua",
    cfg_dir .. rel .. "/init.lua",
    cfg_dir .. "lua/" .. rel .. ".lua",
    cfg_dir .. "lua/" .. rel .. "/init.lua",
  }
  for _, path in ipairs(candidates) do
    local f = io.open(path, "r")
    if f then
      f:close()
      local chunk, err = loadfile(path)
      if chunk then
        return chunk
      end
      return "\n\tload error: " .. tostring(err)
    end
  end
  return "\n\tno wsl candidate for: " .. modname
end
table.insert(package.searchers, 1, wsl_searcher)

----------------------------------------------------
-- config 本体
----------------------------------------------------
local config = wezterm.config_builder()

-- フォント、カラー
config.font = wezterm.font('HackGen Console', { weight = 'Regular'})
config.font_size = 13.0
config.color_scheme = "Tokyo Night Moon"
config.use_ime = true

-- WSL + デフォルト起動シェル
config.default_prog = { "wsl", "~" }

local function detect_wsl_domain()
  if not wezterm.running_under_wsl() then
    return nil
  end

  local domains = wezterm.default_wsl_domains()
  for _, d in ipairs(domains) do
    if d.name:match("^WSL:Ubuntu") then
      return d.name
    end
  end
  return nil
end

config.default_domain = detect_wsl_domain()

config.automatically_reload_config = true
config.default_cursor_style = "BlinkingBar"
config.window_close_confirmation = "NeverPrompt"
-- config.show_close_tab_button_in_tabs = false

-- config.window_background_image = wezterm.home_dir .. "/path/to/your/image.png"
config.window_background_opacity = 0.7

----------------------------------------------------
-- Tab
----------------------------------------------------
local function split(str, ts)
  if type(str) ~= "string" or str == "" then
    return {}
  end
  ts = ts or "/"
  local esc = ts:gsub("(%W)", "%%%1")
  local pat = "([^" .. esc .. "]+)"
  local t = {}
  for s in string.gmatch(str, pat) do
    t[#t + 1] = s
  end
  return t
end

local title_cache = {}
wezterm.on("update-status", function(_, pane)
  local pane_id = pane:pane_id()
  local process_info = pane:get_current_working_dir()
  if process_info then
    local cwd = tostring(process_info)
    cwd = cwd:gsub("^file://[^/]*", "")

    if cwd:find("home/skitamura", 1, true) then
      cwd = cwd:gsub("home/skitamura", "")
    end

    if cwd:find("/develop", 1, true) then
      cwd = cwd:gsub("/develop", "")
    end

    if cwd ~= "" then
      local dirs = split(cwd, "/")
      Result = dirs[1] or "-"
    end

    if Result == "-" then
      local title = pane:get_title() or ""
      if title ~= "" and title ~= "-" then
        local fname = title:match("([^ ]+)$")
        if fname and fname ~= "" then
          Result = fname
        end
      end
    end
  end
  title_cache[pane_id] = Result
end)

config.window_decorations = "RESIZE"
config.show_tabs_in_tab_bar = true
-- config.hide_tab_bar_if_only_one_tab = true

config.window_frame = {
  inactive_titlebar_bg = "none",
  active_titlebar_bg = "none",
}

config.window_background_gradient = {
  colors = { "#000000" },
}

config.show_new_tab_button_in_tab_bar = false

config.colors = {
  tab_bar = {
    inactive_tab_edge = "none",
  },
}

-- タブの装飾
local SOLID_LEFT_ARROW = wezterm.nerdfonts.ple_lower_right_triangle
local SOLID_RIGHT_ARROW = wezterm.nerdfonts.ple_upper_left_triangle

wezterm.on("format-tab-title", function(tab)
  local background = "#5c6d74"
  local foreground = "#FFFFFF"
  local edge_background = "none"
  if tab.is_active then
    background = "#ae8b2d"
    foreground = "#FFFFFF"
  end
  local edge_foreground = background

  local pane = tab.active_pane
  local pane_id = pane.pane_id

  local cwd = title_cache[pane_id] or pane_id
  local title = "    " .. cwd .. "    "

  return {
    { Background = { Color = edge_background } },
    { Foreground = { Color = edge_foreground } },
    { Text = SOLID_LEFT_ARROW },
    { Background = { Color = background } },
    { Foreground = { Color = foreground } },
    { Text = title },
    { Background = { Color = edge_background } },
    { Foreground = { Color = edge_foreground } },
    { Text = SOLID_RIGHT_ARROW },
  }
end)

----------------------------------------------------
-- keybinds
----------------------------------------------------
config.disable_default_key_bindings = true
config.keys = require("keybinds").keys
config.key_tables = require("keybinds").key_tables
config.leader = { key = " ", mods = "SHIFT", timeout_milliseconds = 2000 }

return config
