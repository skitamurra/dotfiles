local wezterm = require("wezterm")
local mux = wezterm.mux
local ws_order = require("workspace_order")
local module = {}
local home_dir = wezterm.home_dir

local function send_setup(pane, cwd, command)
  if cwd then
    pane:send_text("cd " .. cwd .. "\n")
  end
  if command then
    local cmd_str = type(command) == "table" and table.concat(command, " ") or command
    pane:send_text(cmd_str .. "\n")
  end
end

local function spawn_splits(pane, splits, tab_cwd)
  for _, split_def in ipairs(splits or {}) do
    local new_pane = pane:split({
      direction = split_def.direction or "Right",
      size = split_def.size or 0.5,
      cwd = home_dir,
    })
    send_setup(new_pane, split_def.cwd or tab_cwd, split_def.command)
    if split_def.post_spawn then
      split_def.post_spawn(new_pane)
    end
    if split_def.splits then
      spawn_splits(new_pane, split_def.splits, split_def.cwd or tab_cwd)
    end
  end
end

local function apply_setup(setup)
  local initial_order = {}
  for _, ws_def in ipairs(setup) do
    if ws_def.workspace then
      table.insert(initial_order, ws_def.workspace)
    end
  end
  ws_order.reset(initial_order)

  for _, ws_def in ipairs(setup) do
    local tabs = ws_def.tabs or {}
    if #tabs == 0 then
      goto continue
    end

    local first_tab = tabs[1]
    local first_tab_obj, first_pane, window = mux.spawn_window({
      workspace = ws_def.workspace,
    })
    send_setup(first_pane, first_tab.cwd, first_tab.command)
    spawn_splits(first_pane, first_tab.splits, first_tab.cwd)
    first_pane:activate()

    for i = 2, #tabs do
      local tab_def = tabs[i]
      local _, pane = window:spawn_tab({ cwd = home_dir })
      send_setup(pane, tab_def.cwd, tab_def.command)
      spawn_splits(pane, tab_def.splits, tab_def.cwd)
      pane:activate()
    end

    first_tab_obj:activate()

    ::continue::
  end

  if #setup > 0 and setup[1].workspace then
    mux.set_active_workspace(setup[1].workspace)
  end
end

function module.apply_to_config(_)
  wezterm.on("gui-attached", function()
    local active_workspcace = mux.get_active_workspace()
    local ordered = ws_order.get_ordered_workspaces()
    if active_workspcace == "default" and #ordered > 0 then
      mux.set_active_workspace(ordered[1])
      active_workspcace = ordered[1]
    end

    for _, window in ipairs(mux.all_windows()) do
      if window:get_workspace() == active_workspcace then
        window:gui_window():maximize()
      end
    end
  end)

  wezterm.on("mux-startup", function()
    local ok, setup = pcall(require, "startup_local")
    --  ~/.config/wezterm/startup_local.lua
    --  return {
    --    {
    --      workspace = "home",
    --      tabs = {
    --        {
    --          command = "note",
    --          splits = {
    --            {
    --              direction = "Right",
    --              size = 0.5,
    --              command = "prt",
    --              post_spawn = function(pane)
    --                pane:send_text("echo " .. pane:pane_id() .. "\n")
    --              end,
    --              splits = {
    --                { direction = "Bottom" },
    --              },
    --            },
    --          },
    --        },
    --        { cwd = "~/ghq/github.com/sg004baa/dotfiles" },
    --      },
    --    },
    --    {
    --      workspace = "src",
    --      tabs = {
    --        {},  -- spawn default tab
    --    },
    --  }
    if not ok or type(setup) ~= "table" then
      return
    end
    apply_setup(setup)
  end)
end

return module
