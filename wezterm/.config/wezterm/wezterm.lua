local wezterm = require("wezterm")

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

-- ウィンドウ初期サイズ
config.initial_cols = 120
config.initial_rows = 28

-- フォント、カラー
config.font_size = 12.0
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

-- 背景関連
-- config.window_background_image = wezterm.home_dir .. "/path/to/your/image.png" -- 使うならちゃんと画像パスを書く
config.window_background_opacity = 0.8

----------------------------------------------------
-- Tab / タブバー表示
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

-- 各タブの「ディレクトリ名」を記憶しておくテーブル
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

    if cwd == "" then
      title_cache[pane_id] = "-"
      return
    end

    local dirs = split(cwd, "/")
    local root_dir = dirs[1] or "-"
    title_cache[pane_id] = root_dir
  else
    title_cache[pane_id] = "not info"
  end
end)

-- タイトルバーを非表示
config.window_decorations = "RESIZE"

-- タブバー表示関連
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
