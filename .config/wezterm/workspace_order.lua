local wezterm = require("wezterm")
local mux = wezterm.mux

local M = {}

local state_dir = (os.getenv("HOME") or os.getenv("USERPROFILE")) .. "/.local/state/wezterm"
local state_file = state_dir .. "/workspace_order.json"

local function read_order()
  local f = io.open(state_file, "r")
  if not f then
    return {}
  end
  local content = f:read("*a")
  f:close()
  local ok, data = pcall(wezterm.json_parse, content)
  if ok and type(data) == "table" then
    return data
  end
  return {}
end

local function write_order(order)
  os.execute('mkdir -p "' .. state_dir .. '"')
  local f = io.open(state_file, "w")
  if not f then
    wezterm.log_error("Failed to write workspace order: " .. state_file)
    return
  end
  f:write(wezterm.json_encode(order))
  f:close()
end

function M.track(name)
  local order = read_order()
  for _, v in ipairs(order) do
    if v == name then
      return
    end
  end
  table.insert(order, name)
  write_order(order)
end

function M.reset(names)
  write_order(names)
end

function M.get_ordered_workspaces()
  local existing = {}
  for _, w in ipairs(mux.get_workspace_names()) do
    existing[w] = true
  end
  local filtered = {}
  local added = {}
  for _, w in ipairs(read_order()) do
    if w ~= "scratch" and w ~= "default" and existing[w] then
      table.insert(filtered, w)
      added[w] = true
    end
  end
  for _, w in ipairs(mux.get_workspace_names()) do
    if w ~= "scratch" and w ~= "default" and not added[w] then
      table.insert(filtered, w)
    end
  end
  return filtered
end

return M
