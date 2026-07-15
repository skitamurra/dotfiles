-- lua/config/fyler.lua
local ok, fyler = pcall(require, "fyler")
if not ok then
  return
end

local function preview_file(explorer)
  local node = require("fyler.finder").parse_cursor_line(explorer)
  if not node or not node.full_path then
    return
  end

  local stat = vim.uv.fs_stat(node.full_path)
  if not stat or stat.type ~= "file" then
    return
  end

  local ok_read, lines = pcall(vim.fn.readfile, node.full_path)
  if not ok_read or not lines then
    vim.print("failed to read file: " .. node.full_path)
    return
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  local width = math.floor(vim.o.columns * 0.6)
  local height = math.floor(vim.o.lines * 0.7)

  local opts = {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = "rounded",
  }

  local preview_win = vim.api.nvim_open_win(buf, true, opts)

  local function close_preview()
    if vim.api.nvim_win_is_valid(preview_win) then
      vim.api.nvim_win_close(preview_win, true)
    end
  end

  vim.keymap.set("n", "q", close_preview, { buffer = buf, silent = true })
end

fyler.setup({
  kind = 'floating',
  integrations = {
    icon = 'nvim_web_devicons',
    window_picker = function()
      return require('snacks').picker.util.pick_win()
    end,
  },
  ui = {
    hidden_items = {
      switches = {},
    },
    indent_guides = true,
  },
  mappings = {
    n = {
      ["<C-p>"] = {
        action = preview_file,
      },
    },
  },
})
