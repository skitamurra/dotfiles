local Snacks = require("snacks")
local util = require("config.util")

local function get_recent_files()
  local files = {}
  for _, f in ipairs(vim.v.oldfiles or {}) do
    if vim.fn.filereadable(f) == 1 then
      table.insert(files, f)
    end
  end
  return files
end

local function get_git_root(path)
  local dir = vim.fn.fnamemodify(path, ":p:h")
  local root = vim.fn.systemlist({
    "git",
    "-C", dir,
    "rev-parse",
    "--show-toplevel",
  })[1]

  if vim.v.shell_error ~= 0 then
    return nil
  end

  return root
end

local function collect_projects(files)
  local seen = {}
  local projects = {}

  for _, f in ipairs(files) do
    local root = get_git_root(f)
    if root and not seen[root] then
      seen[root] = true

      table.insert(projects, {
        root = root,
        name = vim.fn.fnamemodify(root, ":t"),
      })
    end
  end

  return projects
end

local function sort_projects(projects)
  table.sort(projects, function(a, b)
    return a.name:lower() < b.name:lower()
  end)
end

local function show_projects(projects)
  vim.ui.select(projects, {
    prompt = "Projects",
    format_item = function(item)
      return item.name
    end,
  }, function(choice)
    -- add action
  end)
end

local function show_recent_projects()
  local files = get_recent_files()
  local projects = collect_projects(files)

  if #projects == 0 then
    vim.notify("No projects found", vim.log.levels.INFO)
    return
  end

  sort_projects(projects)
  show_projects(projects)
end

Snacks.setup({
  dashboard = {
    enabled =true,
    width = 60,
    row = nil,
    col = nil,
    pane_gap = 4,
    autokeys = "1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ", -- autokey sequence
    preset = {
      ---@type snacks.dashboard.Item[]
      keys = {
        { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
        { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
        { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
        { icon = " ", key = "p", desc = "Projects", action = function() show_recent_projects() util.esc() end },
        { icon = " ", key = "s", desc = "Restore Session", action = function() require("persistence").select() util.esc() end },
        { icon = " ", key = "S", desc = "Last Session", action = function() require("persistence").load({ last = true }) end },
        { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy", enabled = package.loaded.lazy ~= nil },
        { icon = " ", key = "c", desc = "Config", action = function() Snacks.picker.files({cwd = vim.fn.stdpath('config')}) end },
        { icon = " ", key = "q", desc = "Quit", action = ":qa" },
      },
      header = [[
░░░    ░░ ░░░░░░░  ░░░░░░  ░░    ░░ ░░ ░░░    ░░░ 
▒▒▒▒   ▒▒ ▒▒      ▒▒    ▒▒ ▒▒    ▒▒ ▒▒ ▒▒▒▒  ▒▒▒▒ 
▒▒ ▒▒  ▒▒ ▒▒▒▒▒   ▒▒    ▒▒ ▒▒    ▒▒ ▒▒ ▒▒ ▒▒▒▒ ▒▒ 
▓▓  ▓▓ ▓▓ ▓▓      ▓▓    ▓▓  ▓▓  ▓▓  ▓▓ ▓▓  ▓▓  ▓▓ 
██   ████ ███████  ██████    ████   ██ ██      ██ 
      ]],
    },
    -- formats = {
    --   icon = function(item)
    --     if item.file and item.icon == "file" or item.icon == "directory" then
    --       return Snacks.dashboard.icon(item.file, item.icon)
    --     end
    --     return { item.icon, width = 2, hl = "icon" }
    --   end,
    --   footer = { "%s", align = "center" },
    --   header = { "%s", align = "center" },
    --   file = function(item, ctx)
    --     local fname = vim.fn.fnamemodify(item.file, ":~")
    --     fname = ctx.width and #fname > ctx.width and vim.fn.pathshorten(fname) or fname
    --     if #fname > ctx.width then
    --       local dir = vim.fn.fnamemodify(fname, ":h")
    --       local file = vim.fn.fnamemodify(fname, ":t")
    --       if dir and file then
    --         file = file:sub(-(ctx.width - #dir - 2))
    --         fname = dir .. "/…" .. file
    --       end
    --     end
    --     local dir, file = fname:match("^(.*)/(.+)$")
    --     return dir and { { dir .. "/", hl = "dir" }, { file, hl = "file" } } or { { fname, hl = "file" } }
    --   end,
    -- },
    sections = {
      { section = "header" },
      -- {
      --   pane = 2,
      --   section = "terminal",
      --   cmd = "colorscript -e square",
      --   height = 5,
      --   padding = 1,
      -- },
      { section = "keys", gap = 0, padding = 1 },
      -- { pane = 1, icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
      -- { section = "projects", icon = " ", title = "Projects", indent = 2, padding = 1 },
      -- {
      --   section = "terminal",
      --   cmd = "pokemon-colorscripts -r --no-title; sleep .1",
      --   random = 10,
      --   pane = 2,
      --   indent = 4,
      --   height = 30,
      -- },
      { section = "startup" },
    },
  },
  terminal = {
    enabled = true,
    win = {
      style = "float",
      -- width = 0.8,
      -- height = 0.78,
      border = "rounded",
    },
  },
  -- explorer = { enabled = true },
  indent = { enabled = true },
  -- input = { enabled = true },
  picker = {
    sources = {
      gh_issue = {
        -- your gh_issue picker configuration comes here
        -- or leave it empty to use the default settings
      },
      gh_pr = {
        -- your gh_pr picker configuration comes here
        -- or leave it empty to use the default settings
      }
    }
  },
  notifier = { enabled = true },
  -- quickfile = { enabled = true },
  -- scope = { enabled = true },
  -- scroll = { enabled = true },
  -- statuscolumn = { enabled = true },
  -- words = { enabled = true },
  image = { enabled = true},
})
