local Snacks = require("snacks")
local util = require("config.util")

local logo = [[
░░░    ░░ ░░░░░░░  ░░░░░░  ░░    ░░ ░░ ░░░    ░░░
▒▒▒▒   ▒▒ ▒▒      ▒▒    ▒▒ ▒▒    ▒▒ ▒▒ ▒▒▒▒  ▒▒▒▒
▒▒ ▒▒  ▒▒ ▒▒▒▒▒   ▒▒    ▒▒ ▒▒    ▒▒ ▒▒ ▒▒ ▒▒▒▒ ▒▒
▓▓  ▓▓ ▓▓ ▓▓      ▓▓    ▓▓  ▓▓  ▓▓  ▓▓ ▓▓  ▓▓  ▓▓
██   ████ ███████  ██████    ████   ██ ██      ██
]]

Snacks.setup({
  dashboard = {
    width = 60,
    row = nil,
    col = nil,
    pane_gap = 4,
    autokeys = "1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ",
    preset = {
      keys = {
        { icon = " ", key = "f", desc = "Find File", action = function () util.grep_file() end },
        { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
        { icon = " ", key = "g", desc = "Find Text", action = function() util.grep_text() end },
        { icon = " ", key = "p", desc = "Projects", action = function() Snacks.picker.projects({ui_select = true}) util.esc() end },
        { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy", enabled = package.loaded.lazy ~= nil },
        { icon = " ", key = "c", desc = "Config", action = function() Snacks.picker.files({hidden = true, follow = true, cwd = vim.fn.fnamemodify(vim.fn.stdpath('config'), ":h") }) end },
        { icon = " ", key = "q", desc = "Quit", action = ":qa" },
      },
    },
    sections = {
      {
        section = "terminal",
        cmd = 'echo -e ' .. vim.fn.shellescape(vim.trim(logo)) .. ' | tte --anchor-canvas s beams --beam-delay 1 --final-gradient-direction diagonal; sleep infinity',
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
  picker = { enabled = true},
  styles = {
    scratch = {
      width = 0.8,
      height = 0.8,
    },
  }  ,
})
