local wezterm = require("wezterm")
local act = wezterm.action
local ws_order = require("workspace_order")

local module = {}

local function get_ordered_workspaces()
  return ws_order.get_ordered_workspaces()
end

local function switch_to_workspace(direction)
  local offset = direction == "prev" and -1 or 1

  return wezterm.action_callback(function(window, pane)
    local workspaces = get_ordered_workspaces()
    if #workspaces == 0 then
      return
    end

    local current_index = 1
    local current = wezterm.mux.get_active_workspace()
    for i, ws in ipairs(workspaces) do
      if ws == current then
        current_index = i
        break
      end
    end

    local next_index = ((current_index - 1 + offset) % #workspaces) + 1
    window:perform_action(act.SwitchToWorkspace({ name = workspaces[next_index] }), pane)
  end)
end

-- Show workspace selector (LEADER+w)
local function workspace_selector()
  return wezterm.action_callback(function(win, pane)
    -- 現在のPaneでworkspace_modeを有効化
    win:perform_action(act.ActivateKeyTable({ name = "workspace_mode", one_shot = false }), pane)
    local workspaces = {}
    local index = 1
    for _, name in ipairs(get_ordered_workspaces()) do
      table.insert(workspaces, {
        id = name,
        label = string.format("%d. %s", index, name),
      })
      index = index + 1
    end
    local current = wezterm.mux.get_active_workspace()
    win:perform_action(
      act.ToggleFloatingOverlay({
        action = act.InputSelector({
          description = string.format("Select workspace: %s -> ", current),
          action = wezterm.action_callback(function(_, _, id)
            if id then
              win:perform_action(act.SwitchToWorkspace({ name = id }), pane)
            end
            win:perform_action(act.PopKeyTable, pane)
          end),
          choices = workspaces,
          fuzzy = true,
        }),
      }),
      pane
    )
  end)
end

-- Create new workspace (used inside workspace_mode key_table)
local function create_workspace()
  return act.ToggleFloatingOverlay({
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
  })
end

module.switch_to_workspace = switch_to_workspace
module.workspace_selector = workspace_selector
module.create_workspace = create_workspace

return module
