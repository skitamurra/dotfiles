local wezterm = require("wezterm")
local mux = wezterm.mux
local module = {}

local function resolve_cwd(cwd)
  if not cwd then
    return wezterm.home_dir
  end
  return (cwd:gsub("^~", wezterm.home_dir))
end

local function spawn_splits(pane, splits, tab_cwd)
  for _, split_def in ipairs(splits or {}) do
    local args = {
      direction = split_def.direction or "Right",
      size = split_def.size or 0.5,
      cwd = resolve_cwd(split_def.cwd or tab_cwd),
    }
    if split_def.command then
      args.args = split_def.command
    end
    pane:split(args)
  end
end

local function apply_setup(setup)
  for _, ws_def in ipairs(setup) do
    local tabs = ws_def.tabs or {}
    if #tabs == 0 then
      goto continue
    end

    local first_tab = tabs[1]
    local spawn_args = {
      workspace = ws_def.workspace,
      cwd = resolve_cwd(first_tab.cwd),
    }
    if first_tab.command then
      spawn_args.args = first_tab.command
    end

    local _, first_pane, window = mux.spawn_window(spawn_args)
    spawn_splits(first_pane, first_tab.splits, first_tab.cwd)

    for i = 2, #tabs do
      local tab_def = tabs[i]
      local tab_args = {
        cwd = resolve_cwd(tab_def.cwd),
        workspace = ws_def.workspace,
      }
      if tab_def.command then
        tab_args.args = tab_def.command
      end
      local _, pane = window:spawn_tab(tab_args)
      spawn_splits(pane, tab_def.splits, tab_def.cwd)
    end

    window:active_tab():activate()

    ::continue::
  end
end

function module.apply_to_config(_)
  wezterm.on("gui-startup", function()
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
    --          splits = {
    --            { direction = "Bottom", size = 0.3 },
    --          },
    --        },
    --      },
    --    },
    --  }
    local ok, setup = pcall(require, "startup_local")
    if not ok or type(setup) ~= "table" then
      return
    end
    apply_setup(setup)
  end)
end

return module
