local wezterm = require("wezterm")
local mux = wezterm.mux
local module = {}

-- =============================================================================
-- 定数
-- =============================================================================

-- Claude state marks
local CLAUDE_MARKS = {
  waiting = { mark = "● ", color = "#ff6b6b" },
  done    = { mark = "✓ ", color = "#57A143" },
  idle    = { mark = "⋯ ", color = "#928c36" },
}

-- Icons
local ICONS = {
  docker = wezterm.nerdfonts.md_docker,
  neovim = wezterm.nerdfonts.linux_neovim,
  nb = wezterm.nerdfonts.md_notebook,
  ssh = wezterm.nerdfonts.md_lan,
  fallback = wezterm.nerdfonts.dev_terminal,
  zoom = wezterm.nerdfonts.md_magnify,
}

-- Icon colors
local ICON_COLORS = {
  docker = "#4169e1",
  neovim = "#57A143",
  nb = "#9370DB",
  ssh = "#ff6b6b",
}

-- Tab colors
local TAB_COLORS = {
  foreground_inactive = "#a0a9cb",
  background_inactive = "none",
  foreground_active = "#313244",
  background_active = "#928c36",
  background_ssh_active = "#ff6b6b",
  foreground_ssh_active = "#ffffff",
}

local WORKSPACE_COLORS = {
  foreground_inactive = "#a0a9cb",
  background_inactive = "none",
  foreground_active = "#141414",
  background_active = "#928c36",
  space_between = "#1a1a1a",
}

-- Tab decorations
local DECORATIONS = {
  left_circle = wezterm.nerdfonts.ple_left_half_circle_thick,
  right_circle = wezterm.nerdfonts.ple_right_half_circle_thick,
}

-- =============================================================================
-- ヘルパー関数
-- =============================================================================

local function basename(path)
  return string.gsub(path or "", "(.*[/\\])(.*)", "%2")
end

local function is_nb_process(process_name, cmdline, cwd)
  return process_name == "nb"
    or (cmdline and (cmdline:find("/nb") or cmdline:find("nb ")))
    or (cwd and cwd:find("%.nb"))
end

local function is_ssh_process(process_name, cmdline, user_vars)
  if user_vars.ssh_host and user_vars.ssh_host ~= "" then
    return true, user_vars.ssh_host
  end
  if process_name:find("ssh") or (cmdline and cmdline:find("ssh")) then
    local host = cmdline and cmdline:match("ssh%s+([%w_%-%.]+)")
    return true, host
  end
  return false, nil
end

local function is_claude_process(process_name, pane_title)
  return process_name == "claude" or (pane_title and (pane_title:find("^✳") or pane_title:lower():find("claude")))
end

local function extract_project_name(cwd)
  if not cwd then
    return "-"
  end

  local home = os.getenv("HOME")
  if home and cwd:find("^" .. home) then
    cwd = cwd:gsub("^" .. home, "~")
  end

  -- nbディレクトリ
  if cwd:find("%.nb") then
    return "nb"
  end

  -- GitHubプロジェクト名
  local _, project = cwd:match(".*/github.com/([^/]+)/([^/]+)")
  if project then
    return project
  end

  -- 最後のディレクトリ名
  cwd = cwd:gsub("/$", "")
  return cwd:match("([^/]+)$") or cwd
end

local function get_icon_and_color(process_name, pane_title, cmdline, cwd, is_ssh, is_active)
  if is_ssh then
    local color = is_active and "#ffffff" or ICON_COLORS.ssh
    return ICONS.ssh, color
  end

  if pane_title == "nvim" or process_name == "nvim" then
    return ICONS.neovim, ICON_COLORS.neovim
  end

  if is_nb_process(process_name, cmdline, cwd) then
    return ICONS.nb, ICON_COLORS.nb
  end

  if process_name == "docker" or (pane_title and pane_title:find("docker")) then
    return ICONS.docker, ICON_COLORS.docker
  end

  return ICONS.fallback, TAB_COLORS.foreground_inactive
end

local function get_tab_colors(is_active, is_ssh)
  if is_active and is_ssh then
    return TAB_COLORS.background_ssh_active, TAB_COLORS.foreground_ssh_active
  elseif is_active then
    return TAB_COLORS.background_active, TAB_COLORS.foreground_active
  end
  return TAB_COLORS.background_inactive, TAB_COLORS.foreground_inactive
end

local function has_zoomed_pane(panes)
  for _, pane_info in ipairs(panes) do
    if pane_info.is_zoomed then
      return true
    end
  end
  return false
end

-- =============================================================================
-- メイン処理
-- =============================================================================

function module.apply_to_config(config)
  local title_cache = {}
  local ssh_host_cache = {}

  -- タイトルキャッシュの更新
  wezterm.on("update-status", function(window, pane)
    local pane_id = pane:pane_id()
    local user_vars = pane.user_vars or {}

    -- SSH中以外はタイトルキャッシュを更新
    if not (user_vars.ssh_host and user_vars.ssh_host ~= "") then
      local cwd_url = pane:get_current_working_dir()
      local cwd = cwd_url and cwd_url.file_path
      title_cache[pane_id] = extract_project_name(cwd)

      local workspace = window:active_workspace()
      local overrides = window:get_config_overrides() or {}

      -- カラー設定を保持
      overrides.colors = config.colors

      -- 全ワークスペースを収集
      local workspace_tabs = {}
      local all_workspaces = {}
      for _, w in ipairs(mux.get_workspace_names()) do
        if w ~= "default" and w ~= "scratch" then
          table.insert(all_workspaces, w)
        end
      end
      table.insert(all_workspaces, 1, "default")

      -- ワークスペースタブの作成
      for _, ws_key in ipairs(all_workspaces) do
        local ws_name = ws_key

        -- アクティブなワークスペースはハイライト表示
        if ws_key == workspace then
          table.insert(workspace_tabs, { Background = { Color = WORKSPACE_COLORS.background_active } })
          table.insert(workspace_tabs, { Foreground = { Color = WORKSPACE_COLORS.foreground_active } })
          table.insert(workspace_tabs, { Text = " " .. ws_name .. " " })
        else
          -- 非アクティブなワークスペースは暗い色で表示
          table.insert(workspace_tabs, { Background = { Color = WORKSPACE_COLORS.background_inactive } })
          table.insert(workspace_tabs, { Foreground = { Color = WORKSPACE_COLORS.foreground_inactive } })
          table.insert(workspace_tabs, { Text = " " .. ws_name .. " " })
        end

        -- ワークスペース間のスペース
        table.insert(workspace_tabs, { Background = { Color = WORKSPACE_COLORS.space_between } })
        table.insert(workspace_tabs, { Text = "" })
      end

      -- 左側のステータスバーにワークスペースタブを表示
      window:set_left_status(wezterm.format(workspace_tabs))

      -- 右側のステータスバーにヘルプテキストを表示
      -- window:set_right_status(wezterm.format({
      -- 	{ Background = { Color = "#1a1a1a" } },
      -- 	{ Foreground = { Color = "#606060" } },
      -- 	{ Text = " Switch workspace: Cmd+S " },
      -- }))

      window:set_config_overrides(overrides)
    end
  end)

  -- タブタイトルのフォーマット
  wezterm.on("format-tab-title", function(tab, _, _, _, _, max_width)
    local pane = tab.active_pane
    local pane_id = pane.pane_id
    local pane_title = pane.title or ""
    local user_vars = pane.user_vars or {}
    -- WSL workaround: foreground_process_name returns wslhost.exe
    -- Use WEZTERM_PROG user-var (set by zsh wezterm shell integration) instead
    local raw_process = basename(pane.foreground_process_name)
    local process_name = raw_process
    if raw_process == "wslhost.exe" then
      process_name = user_vars.WEZTERM_PROG
    end
    local cmdline = pane.foreground_process_name or ""
    local cached_cwd = title_cache[pane_id] or ""

    -- SSH判定
    local is_ssh, ssh_host = is_ssh_process(process_name, cmdline, user_vars)
    is_ssh = false
    if is_ssh and ssh_host then
      ssh_host_cache[pane_id] = ssh_host
    elseif not is_ssh then
      ssh_host_cache[pane_id] = nil
    end

    -- タブの色
    local background, foreground = get_tab_colors(tab.is_active, is_ssh)
    local edge_background = "transparent"
    local edge_foreground = background

    -- タイトルテキスト
    local title_text
    if is_ssh then
      title_text = ssh_host_cache[pane_id] or "ssh"
    elseif is_nb_process(process_name, cmdline, cached_cwd) then
      title_text = "nb"
    else
      title_text = title_cache[pane_id] or "-"
    end

    -- Claude Code のタイトル追加
    local claude_suffix = ""
    if is_claude_process(process_name, pane_title) and pane_title ~= "" then
      claude_suffix = " " .. pane_title
    end

    -- Claude 状態マーク (hooks から SetUserVar で書き込まれる)
    local claude_state_mark = ""
    local claude_state_color = foreground
    if is_claude_process(process_name, pane_title) then
      local state_info = CLAUDE_MARKS[user_vars.CLAUDE_STATE or ""]
      if state_info then
        claude_state_mark = state_info.mark
        claude_state_color = state_info.color
      end
    end

    -- アイコン
    local icon, icon_color = get_icon_and_color(process_name, pane_title, cmdline, cached_cwd, is_ssh, tab.is_active)

    -- ズームインジケーター
    local zoom_indicator = has_zoomed_pane(tab.panes) and (ICONS.zoom .. " ") or ""

    -- 半円（アクティブタブのみ）
    local left_circle = tab.is_active and DECORATIONS.left_circle or ""
    local right_circle = tab.is_active and DECORATIONS.right_circle or ""

    -- タイトルの整形
    local title = " " .. wezterm.truncate_right(title_text, max_width)
    local claude_title = wezterm.truncate_right(claude_suffix, max_width) .. " "

    return {
      { Background = { Color = edge_background } },
      { Text = " " },
      { Foreground = { Color = edge_foreground } },
      { Text = left_circle },
      { Background = { Color = background } },
      { Foreground = { Color = icon_color } },
      { Text = icon },
      { Background = { Color = background } },
      { Foreground = { Color = foreground } },
      { Text = zoom_indicator },
      { Attribute = { Intensity = "Bold" } },
      { Text = title },
      { Attribute = { Intensity = "Normal" } },
      { Text = claude_title },
      { Foreground = { Color = claude_state_color } },
      { Text = claude_state_mark },
      { Background = { Color = edge_background } },
      { Foreground = { Color = edge_foreground } },
      { Text = right_circle },
    }
  end)
end

return module
