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
local effects = {
  'middleout --center-movement-speed 0.8 --full-movement-speed 0.2',
  'slide --merge --movement-speed 0.8',
  'beams --beam-delay 1 --beam-row-speed-range 80-100 --beam-column-speed-range 45-60',
}

Snacks.setup({
  dashboard = {
    width = 60,
    row = nil,
    col = nil,
    pane_gap = 4,
    autokeys = "1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ",
    preset = {
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
        cmd = 'echo -e ' .. vim.fn.shellescape(vim.trim(logo)) .. ' | tte --anchor-canvas s ' .. effects[math.random(#effects)] .. ' --final-gradient-direction diagonal; sleep infinity',
        ttl = 0,
        height = 8,
      },
      { section = "keys", gap = 0, padding = 1 },
      { section = "startup" },
    },
  },
  terminal = {
    win = {
      style = "float",
      border = "rounded",
    },
  },
  indent = { enabled = true },
  notifier = { enabled = true },
  image = { enabled = true},
})
