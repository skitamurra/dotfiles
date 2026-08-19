require("buffer_manager").setup({
  width = 0.4,
  height = 0.5,
  short_file_names = true,
  show_depth = false,
  show_cols = "number",
  win_extra_options = {
    cursorline = true,
    signcolumn = "no",
    wrap = false,
  },
})

local util = require("config.util")

local path_namespace = vim.api.nvim_create_namespace("BufferManagerPath")
vim.api.nvim_set_hl(0, "BufferManagerPath", { default = true, link = "Comment" })

local function render_buffer_manager_paths(buf)
  if not vim.api.nvim_buf_is_valid(buf) then
    return
  end

  vim.api.nvim_buf_clear_namespace(buf, path_namespace, 0, -1)
  local line_count = vim.api.nvim_buf_line_count(buf)
  for index, mark in ipairs(require("buffer_manager").marks) do
    if index > line_count then
      break
    end
    local parent = vim.fs.dirname(mark.buf_name)
    local git_root = util.get_git_root(mark.buf_name)
    local path = git_root and vim.fs.relpath(git_root, parent)
    if not path then
      path = vim.fs.basename(parent)
    elseif path == "" then
      path = "."
    end
    path = path .. "/"
    vim.api.nvim_buf_set_extmark(buf, path_namespace, index - 1, 0, {
      virt_text = { { path .. " ", "BufferManagerPath" } },
      virt_text_pos = "inline",
      hl_mode = "combine",
      invalidate = true,
    })
  end
end

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("BufferManagerPath", { clear = true }),
  pattern = "buffer_manager",
  callback = function(args)
    vim.schedule(function()
      render_buffer_manager_paths(args.buf)
    end)
  end,
})

local buffer_order = {}

local function sync_buffer_order(delete_removed)
  local next_order = {}
  local replacement
  for index, mark in ipairs(require("buffer_manager").marks) do
    next_order[mark.buf_id] = index
    replacement = replacement or mark.buf_id
  end

  if delete_removed then
    for buf in pairs(buffer_order) do
      if not next_order[buf] and vim.api.nvim_buf_is_valid(buf) then
        if replacement then
          for _, win in ipairs(vim.fn.win_findbuf(buf)) do
            vim.api.nvim_win_set_buf(win, replacement)
          end
        end
        local ok, err = pcall(vim.api.nvim_buf_delete, buf, {})
        if not ok then
          vim.notify("Failed to delete buffer: " .. err, vim.log.levels.ERROR)
        end
      end
    end
  end

  buffer_order = next_order
  vim.cmd.redrawtabline()
end

require("bufferline").setup({
  options = {
    mode = "buffers",
    numbers = "none",
    separator_style = { "/", "/" },
    show_buffer_close_icons = false,
    sort_by = function(a, b)
      local a_index = buffer_order[a.id]
      local b_index = buffer_order[b.id]
      if a_index and b_index then
        return a_index < b_index
      end
      if a_index then
        return true
      end
      if b_index then
        return false
      end
      return a.id < b.id
    end,
    custom_filter = function(buf)
      return vim.bo[buf].filetype ~= "help"
    end,
  },
})

local buffer_manager_ui = require("buffer_manager.ui")
local save_buffer_manager = buffer_manager_ui.on_menu_save
buffer_manager_ui.on_menu_save = function(...)
  local menu_buf = vim.api.nvim_get_current_buf()
  local result = save_buffer_manager(...)
  vim.schedule(function()
    render_buffer_manager_paths(menu_buf)
    sync_buffer_order(true)
  end)
  return result
end

sync_buffer_order()
vim.api.nvim_create_autocmd({ "BufAdd", "BufDelete", "BufLeave" }, {
  group = vim.api.nvim_create_augroup("BufferManagerBufferlineSync", { clear = true }),
  callback = function(args)
    if args.event == "BufLeave" and vim.bo[args.buf].filetype ~= "buffer_manager" then
      return
    end
    vim.schedule(sync_buffer_order)
  end,
})
