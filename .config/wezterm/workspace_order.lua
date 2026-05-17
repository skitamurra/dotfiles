local wezterm = require("wezterm")
local mux = wezterm.mux

local M = {}

local state_dir = (os.getenv("HOME") or os.getenv("USERPROFILE")) .. "/.local/state/wezterm"
local state_file = state_dir .. "/workspace_order.json"
local cached_order = nil

local function read_order()
  if cached_order then
    return cached_order
  end

  local f = io.open(state_file, "r")
  if not f then
    cached_order = {}
    return {}
  end
  local content = f:read("*a")
  f:close()
  local ok, data = pcall(wezterm.json_parse, content)
  if ok and type(data) == "table" then
    cached_order = data
    return data
  end
  cached_order = {}
  return {}
end

local function write_order_sync(order)
  os.execute('mkdir -p "' .. state_dir .. '"')
  local f = io.open(state_file, "w")
  if not f then
    wezterm.log_error("Failed to write workspace order: " .. state_file)
    return
  end
  f:write(wezterm.json_encode(order))
  f:close()
end

local function write_order_async(order)
  local ok = pcall(function()
    wezterm.background_child_process({
      "sh",
      "-c",
      'mkdir -p "$1" && tmp="$3.tmp.$$" && printf "%s" "$2" > "$tmp" && mv "$tmp" "$3"',
      "wezterm-workspace-order",
      state_dir,
      wezterm.json_encode(order),
      state_file,
    })
  end)

  if not ok then
    write_order_sync(order)
  end
end

function M.track(name)
  local order = read_order()
  for _, v in ipairs(order) do
    if v == name then
      return
    end
  end
  table.insert(order, name)
  cached_order = order
  write_order_async(order)
end

function M.reset(names)
  cached_order = names
  write_order_sync(names)
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
