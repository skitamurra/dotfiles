local wezterm = require("wezterm")
local mux = wezterm.mux
local module = {}

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
    })
    send_setup(new_pane, split_def.cwd or tab_cwd, split_def.command)
    if split_def.splits then
      spawn_splits(new_pane, split_def.splits, split_def.cwd or tab_cwd)
    end
  end
end

local function apply_setup(setup)
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

    for i = 2, #tabs do
      local tab_def = tabs[i]
      local _, pane = window:spawn_tab({})
      send_setup(pane, tab_def.cwd, tab_def.command)
      spawn_splits(pane, tab_def.splits, tab_def.cwd)
    end

    first_tab_obj:activate()

    ::continue::
  end
end

function module.apply_to_config(_)
  wezterm.on("gui-startup", function()
    local ok, setup = pcall(require, "startup_local")
    --  ~/.config/wezterm/startup_local.lua
    --  return {
    --    {
    --      workspace = "default",
    --      tabs = {
    --        { cwd = "~" },
    --        { cwd = "~/ghq/github.com/sg004baa/dotfiles" },
    --      },
    --    },
    --    {
    --      workspace = "dev",
    --      tabs = {
    --        {
    --          cwd = "~/ghq/github.com/example/repo",
    --          {
    --            splits = {
    --              {
    --                direction = "right",
    --                size = 0.5,
    --                splits = {
    --                  { direction = "bottom", size = 0.5 },
    --                },
    --              },
    --              { direction = "Bottom", size = 0.5 },
    --            },
    --          },
    --        },
    --      },
    --    },
    --  }
    if not ok or type(setup) ~= "table" then
      return
    end
    apply_setup(setup)
  end)
end

return module
