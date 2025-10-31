-- ✅ WSL上の config ディレクトリを require パスに追加
local wezterm = require 'wezterm'

-- この config ファイルの絶対パスと、そのディレクトリ（UNCに正規化）
local cfg_file = wezterm.config_file
local cfg_dir  = cfg_file:gsub('[^/\\]+$', ''):gsub('\\', '/')

-- Lua-only searcher を先頭に挿入（WSL ~/.config/wezterm と ~/.config/wezterm/lua を探索）
local function wsl_searcher(modname)
  local rel = modname:gsub('%.', '/')
  local candidates = {
    cfg_dir .. rel .. '.lua',
    cfg_dir .. rel .. '/init.lua',
    cfg_dir .. 'lua/' .. rel .. '.lua',
    cfg_dir .. 'lua/' .. rel .. '/init.lua',
  }
  for _, path in ipairs(candidates) do
    local f = io.open(path, 'r')
    if f then f:close()
      local chunk, err = loadfile(path)
      if chunk then return chunk end
      return "\n\tload error: " .. tostring(err)
    end
  end
  return "\n\tno wsl candidate for: " .. modname
end
table.insert(package.searchers, 1, wsl_searcher)

local session_manager = require('wezterm-session-manager.session-manager')

-- この config ファイルの絶対パスと、そのディレクトリ
local cfg_file = wezterm.config_file
local cfg_dir  = cfg_file:gsub('[^/\\]+$', ''):gsub('\\', '/')  -- 末尾のファイル名を削除、/ に正規化

-- config直下 と config/lua/ を検索パスに先頭追加
package.path = table.concat({
  cfg_dir .. '?.lua',
  cfg_dir .. '?/init.lua',
  cfg_dir .. 'lua/?.lua',
  cfg_dir .. 'lua/?/init.lua',
  package.path,
}, ';')

-- （任意）ホットリロード用に監視対象へ追加
local function watch(p)
  wezterm.add_to_config_reload_watch_list((cfg_dir .. p):gsub('\\','/'))
end

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices.

-- For example, changing the initial geometry for new windows:
config.initial_cols = 120
config.initial_rows = 28

-- or, changing the font size and color scheme.
config.color_scheme = 'AdventureTime'

config.default_prog = { 'wsl' }
config.default_domain = "WSL:Ubuntu-24.04"
-- 
-- config.wsl_domains = {
--   {
--    name = "WSL:Ubuntu-24.04",
--    distribution = "Ubuntu-24.04",
--    default_cwd = "~",
--    default_prog = { "bash", "-lc", "zellij attach --create main" },
--  },
-- }

config.automatically_reload_config = true
config.font_size = 12.0
config.use_ime = true
config.window_background_image = wezterm.home_dir .. ''
config.window_background_opacity = 0.8
config.default_cursor_style = 'BlinkingBar'
config.window_close_confirmation = 'NeverPrompt'
config.color_scheme = 'Tokyo Night Moon'

----------------------------------------------------
-- Tab
----------------------------------------------------
local function split(str, ts)
  if type(str) ~= "string" or str == "" then return {} end
  ts = ts or "/"
  local esc = ts:gsub("(%W)", "%%%1")
  local pat = "([^" .. esc .. "]+)"
  local t = {}
  for s in string.gmatch(str, pat) do
    t[#t + 1] = s
  end
  return t
end

-- 各タブの「ディレクトリ名」を記憶しておくテーブル
local title_cache = {}

wezterm.on('update-status', function(window, pane)
  local pane_id = pane:pane_id()
  local process_info = pane:get_current_working_dir()
  if process_info then
    local cwd = tostring(process_info)
    cwd = cwd:gsub("^file://[^/]*", "")

    if cwd:find('home/skitamura', 1, true) then
      cwd = cwd:gsub('home/skitamura', '')
    end

    if cwd:find('/develop', 1, true) then
      cwd = cwd:gsub('/develop', '')
    end

    if cwd == '' then
      title_cache[pane_id] = "-"
      return
    end

    local dirs = split(cwd, '/')
    local root_dir = dirs[1] or '-'
    title_cache[pane_id] = root_dir
  else
    title_cache[pane_id] = "not info"
  end
end)
-- タイトルバーを非表示
config.window_decorations = "RESIZE"
-- タブバーの表示
config.show_tabs_in_tab_bar = true
-- タブが一つの時は非表示
-- config.hide_tab_bar_if_only_one_tab = true
-- falseにするとタブバーの透過が効かなくなる
-- config.use_fancy_tab_bar = false

-- タブバーの透過
config.window_frame = {
  inactive_titlebar_bg = "none",
  active_titlebar_bg = "none",
}

-- タブバーを背景色に合わせる
config.window_background_gradient = {
  colors = { "#000000" },
}

-- タブの追加ボタンを非表示
config.show_new_tab_button_in_tab_bar = false
-- nightlyのみ使用可能
-- タブの閉じるボタンを非表示
-- config.show_close_tab_button_in_tabs = false

-- タブ同士の境界線を非表示
config.colors = {
  tab_bar = {
    inactive_tab_edge = "none",
  },
}

-- タブの形をカスタマイズ
-- タブの左側の装飾
local SOLID_LEFT_ARROW = wezterm.nerdfonts.ple_lower_right_triangle
-- タブの右側の装飾
local SOLID_RIGHT_ARROW = wezterm.nerdfonts.ple_upper_left_triangle

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
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

  local cwd
  if title_cache[pane_id] then
    cwd = title_cache[pane_id]
  else
    cwd = pane_id
  end

  local title = "  " .. "  " .. cwd .. "  " .. "  "
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

wezterm.on("save_session", function(window) session_manager.save_state(window) end)
wezterm.on("load_session", function(window) session_manager.load_state(window) end)
wezterm.on("restore_session", function(window) session_manager.restore_state(window) end)

----------------------------------------------------
-- keybinds
----------------------------------------------------
config.disable_default_key_bindings = true
config.keys = require("keybinds").keys
config.key_tables = require("keybinds").key_tables
config.leader = { key = " ", mods = "SHIFT", timeout_milliseconds = 2000 }

-- Finally, return the configuration to wezterm:
return config
