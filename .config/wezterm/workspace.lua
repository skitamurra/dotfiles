local wezterm = require("wezterm")
local act = wezterm.action
local ws_order = require("workspace_order")

local module = {}

-- Store the workspace we came from before switching to scratch
local previous_workspace = nil

-- Toggle scratch workspace
local function toggle_scratch_workspace()
  return wezterm.action_callback(function(window, pane)
    local current = wezterm.mux.get_active_workspace()

    if current == "scratch" then
      -- If in scratch, go back to previous workspace or default
      local target = previous_workspace or "default"
      window:perform_action(act.SwitchToWorkspace({ name = target }), pane)
    else
      -- Store current workspace and switch to scratch
      previous_workspace = current
      window:perform_action(act.SwitchToWorkspace({ name = "scratch" }), pane)
    end
  end)
end

-- 作成順でワークスペース一覧を取得（scratch除外）
local function get_ordered_workspaces()
  return ws_order.get_ordered_workspaces()
end

-- Switch to next workspace, skipping scratch
local function switch_to_next_workspace_skip_scratch()
  return wezterm.action_callback(function(window, pane)
    local filtered = get_ordered_workspaces()
    local current = wezterm.mux.get_active_workspace()

    local current_index = 1
    for i, ws in ipairs(filtered) do
      if ws == current then
        current_index = i
        break
      end
    end

    local next_index = current_index + 1
    if next_index > #filtered then
      next_index = 1
    end

    if #filtered > 0 then
      window:perform_action(act.SwitchToWorkspace({ name = filtered[next_index] }), pane)
    end
  end)
end

-- Switch to previous workspace, skipping scratch
local function switch_to_prev_workspace_skip_scratch()
  return wezterm.action_callback(function(window, pane)
    local filtered = get_ordered_workspaces()
    local current = wezterm.mux.get_active_workspace()

    local current_index = 1
    for i, ws in ipairs(filtered) do
      if ws == current then
        current_index = i
        break
      end
    end

    local prev_index = current_index - 1
    if prev_index < 1 then
      prev_index = #filtered
    end

    if #filtered > 0 then
      window:perform_action(act.SwitchToWorkspace({ name = filtered[prev_index] }), pane)
    end
  end)
end

local keys = {
  -- Toggle scratch workspace with CTRL+ALT+s
  { key = "s", mods = "CTRL|ALT", action = toggle_scratch_workspace() },
  -- Skip scratch workspace when switching workspaces
  { key = "n", mods = "CTRL|ALT", action = switch_to_next_workspace_skip_scratch() },
  { key = "p", mods = "CTRL|ALT", action = switch_to_prev_workspace_skip_scratch() },

  {
    mods = "LEADER",
    key = "w",
    action = wezterm.action_callback(function(win, pane)
      -- 現在のPaneでworkspace_modeを有効化
      win:perform_action(act.ActivateKeyTable({ name = "workspace_mode", one_shot = false }), pane)
      -- workspace のリストを作成 (scratchを除外)
      local workspaces = {}
      local index = 1
      for _, name in ipairs(wezterm.mux.get_workspace_names()) do
        if name ~= "scratch" then
          table.insert(workspaces, {
            id = name,
            label = string.format("%d. %s", index, name),
          })
          index = index + 1
        end
      end
      local current = wezterm.mux.get_active_workspace()
      -- 選択メニューを起動
      win:perform_action(
        act.InputSelector({
          action = wezterm.action_callback(function(_, _, id, label)
            if not id and not label then
              return
            end
            win:perform_action(act.SwitchToWorkspace({ name = id }), pane) -- workspace を移動
            win:perform_action(act.PopKeyTable, pane)
          end),
          title = "Select workspace",
          choices = workspaces,
          fuzzy = true,
          fuzzy_description = string.format("Select workspace: %s -> ", current), -- requires nightly build
        }),
        pane
      )
    end),
  },
}

local key_tables = {
  workspace_mode = {
    {
      -- Create new workspace
      mods = "SHIFT",
      key = "c",
      action = act.PromptInputLine({
        description = "(wezterm) Create new workspace:",
        action = wezterm.action_callback(function(window, _, line)
          local tab = window:mux_window():active_tab()
          local pane = tab and tab:active_pane()

          if not pane then
            wezterm.log_error("No active pane")
            return
          end

          -- canceled or empty
          if not line or line == "" then
            window:perform_action(act.PopKeyTable, pane)
            return
          end

          ws_order.track(line)

          window:perform_action(
            act.SwitchToWorkspace({
              name = line,
            }),
            pane
          )
          window:perform_action(act.PopKeyTable, pane)
        end),
      }),
    },
    -- {
    --   key = "d",
    --   mods = "SHIFT",
    --   action = wezterm.action_callback(kill_workspace()),
    -- },
    { key = "Escape", action = act.Multiple({ "PopKeyTable", act.SendKey({ key = "Escape" }) }) },
  },
}

function module.apply_to_config(config)
  for _, key in ipairs(keys) do
    table.insert(config.keys, key)
  end
  config.key_tables = config.key_tables or {}
  for name, table_def in pairs(key_tables) do
    config.key_tables[name] = table_def
  end
end

-- Export functions for use in keymaps.lua
module.switch_to_next_workspace_skip_scratch = switch_to_next_workspace_skip_scratch
module.switch_to_prev_workspace_skip_scratch = switch_to_prev_workspace_skip_scratch

return module
