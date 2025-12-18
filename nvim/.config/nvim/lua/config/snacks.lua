local Snacks = require("snacks")
local util = require("config.util")
math.randomseed(os.time())

local logo = [[
░░░    ░░ ░░░░░░░  ░░░░░░  ░░    ░░ ░░ ░░░    ░░░
▒▒▒▒   ▒▒ ▒▒      ▒▒    ▒▒ ▒▒    ▒▒ ▒▒ ▒▒▒▒  ▒▒▒▒
▒▒ ▒▒  ▒▒ ▒▒▒▒▒   ▒▒    ▒▒ ▒▒    ▒▒ ▒▒ ▒▒ ▒▒▒▒ ▒▒
▓▓  ▓▓ ▓▓ ▓▓      ▓▓    ▓▓  ▓▓  ▓▓  ▓▓ ▓▓  ▓▓  ▓▓
██   ████ ███████  ██████    ████   ██ ██      ██
]]
local subcommands = {
  'middleout --center-movement-speed 0.8 --full-movement-speed 0.2',
  'slide --merge --movement-speed 0.8',
  'beams --beam-delay 5 --beam-row-speed-range 20-60 --beam-column-speed-range 8-12',
}

Snacks.setup({
  dashboard = {
    -- enabled =true,
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
        { icon = " ", key = "p", desc = "Projects", action = function() Snacks.picker.projects({ui_select = true}) util.esc() end },
        { icon = " ", key = "s", desc = "Restore Session", action = function() require("persistence").select() util.esc() end },
        { icon = " ", key = "S", desc = "Last Session", action = function() require("persistence").load({ last = true }) end },
        { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy", enabled = package.loaded.lazy ~= nil },
        { icon = " ", key = "c", desc = "Config", action = function() Snacks.picker.files({cwd = vim.fn.stdpath('config')}) end },
        { icon = " ", key = "q", desc = "Quit", action = ":qa" },
      },
    },
    formats = {
      icon = function(item)
        if item.file and item.icon == "file" or item.icon == "directory" then
          return Snacks.dashboard.icon(item.file, item.icon)
        end
        return { item.icon, width = 2, hl = "icon" }
      end,
      footer = { "%s", align = "left" },
      header = { "%s", align = "right" },
      file = function(item, ctx)
        local fname = vim.fn.fnamemodify(item.file, ":~")
        fname = ctx.width and #fname > ctx.width and vim.fn.pathshorten(fname) or fname
        if #fname > ctx.width then
          local dir = vim.fn.fnamemodify(fname, ":h")
          local file = vim.fn.fnamemodify(fname, ":t")
          if dir and file then
            file = file:sub(-(ctx.width - #dir - 2))
            fname = dir .. "/…" .. file
          end
        end
        local dir, file = fname:match("^(.*)/(.+)$")
        return dir and { { dir .. "/", hl = "dir" }, { file, hl = "file" } } or { { fname, hl = "file" } }
      end,
    },
    sections = {
      {
        section = "terminal",
        cmd = 'echo -e ' .. vim.fn.shellescape(vim.trim(logo)) .. ' | tte --anchor-canvas s ' .. subcommands[math.random(#subcommands)] .. ' --final-gradient-direction diagonal',
        align = "right"
      },
      -- { section = "header", action = cmd },
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
    -- enabled = true,
    win = {
      style = "float",
      border = "rounded",
    },
  },
  indent = { enabled = true },
  -- picker = {
    -- sources = {
    --   gh_issue = {
    --     -- your gh_issue picker configuration comes here
    --     -- or leave it empty to use the default settings
    --   },
    --   gh_pr = {
    --     -- your gh_pr picker configuration comes here
    --     -- or leave it empty to use the default settings
    --   }
    -- }
  -- },
  notifier = { enabled = true },
  -- quickfile = { enabled = true },
  -- scope = { enabled = true },
  -- scroll = { enabled = true },
  -- statuscolumn = { enabled = true },
  -- words = { enabled = true },
  image = { enabled = true},
})
