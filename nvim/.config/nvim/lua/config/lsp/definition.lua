-- lua/config/lsp/definition.lua
local M = {}

local float_state = {
  anchor_row = 1,
  anchor_col = 2,
  last_row = nil,
  last_col = nil,
  opened = 0,
  base_win = nil,
  windows = {},
}

local function reset_float_state()
  float_state.anchor_row = 1
  float_state.anchor_col = 2
  float_state.last_row = nil
  float_state.last_col = nil
  float_state.opened = 0
  float_state.base_win = nil
  float_state.windows = {}
end

local function push_float(win)
  table.insert(float_state.windows, win)
end

local function remove_float(win)
  local new = {}
  for _, w in ipairs(float_state.windows) do
    if w ~= win and vim.api.nvim_win_is_valid(w) then
      table.insert(new, w)
    end
  end
  float_state.windows = new
end

local function last_float()
  local ws = float_state.windows
  return ws[#ws]
end

local function focus_last_float_or_base()
  local last = last_float()
  if last and vim.api.nvim_win_is_valid(last) then
    vim.api.nvim_set_current_win(last)
    return
  end
  if float_state.base_win and vim.api.nvim_win_is_valid(float_state.base_win) then
    vim.api.nvim_set_current_win(float_state.base_win)
  end
end

local function close_current_float_and_focus_next()
  local cur = vim.api.nvim_get_current_win()
  if vim.api.nvim_win_is_valid(cur) then
    vim.api.nvim_win_close(cur, true)
  end
  remove_float(cur)
  focus_last_float_or_base()
end

local function close_all_floats()
  for _, w in ipairs(float_state.windows) do
    if vim.api.nvim_win_is_valid(w) then
      vim.api.nvim_win_close(w, true)
    end
  end
  float_state.windows = {}
end

function M.centered_float_definition()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  local client = clients[1]
  local enc = (client and client.offset_encoding) or "utf-16"

  local params = vim.lsp.util.make_position_params(0, enc)

  vim.lsp.buf_request(0, "textDocument/definition", params, function(err, result, _, _)
    if err or not result or vim.tbl_isempty(result) then
      vim.notify("No definition found", vim.log.levels.INFO)
      return
    end

    local function normalize_loc(loc)
      if loc.targetUri then
        return {
          uri = loc.targetUri,
          range = loc.targetSelectionRange or loc.targetRange or loc.range,
        }
      else
        return { uri = loc.uri, range = loc.range }
      end
    end

    local first = normalize_loc(result[1])
    if not first or not first.uri or not first.range then
      vim.notify("Invalid LSP location", vim.log.levels.WARN)
      return
    end

    local locs = {}
    for _, loc in ipairs(result) do
      local nloc = normalize_loc(loc)
      if nloc.uri == first.uri then
        table.insert(locs, nloc)
      end
    end
    if #locs == 0 then
      locs = { first }
    end

    local bufnr = vim.uri_to_bufnr(first.uri)
    vim.fn.bufload(bufnr)

    local ui = vim.api.nvim_list_uis()[1]
    local width = math.floor(ui.width * 0.8)
    local height = math.floor(ui.height * 0.8)

    local center_row = math.floor((ui.height - height) / 2)
    local center_col = math.floor((ui.width - width) / 2)

    local cur_cfg = vim.api.nvim_win_get_config(0)
    local in_float = cur_cfg.relative ~= ""

    local row, col
    local orig_win = vim.api.nvim_get_current_win()

    if not in_float then
      reset_float_state()
      float_state.base_win = orig_win

      row = center_row
      col = center_col
    else
      if not float_state.last_row or not float_state.last_col then
        float_state.anchor_row = 1
        float_state.anchor_col = 2
        float_state.last_row = float_state.anchor_row
        float_state.last_col = float_state.anchor_col
        float_state.opened = 0
      end

      local step_row = 2
      local step_col = 4

      if float_state.opened == 0 then
        row = float_state.anchor_row
        col = float_state.anchor_col
      else
        row = float_state.last_row + step_row
        col = float_state.last_col + step_col
      end

      if row + height > ui.height then
        row = math.max(0, ui.height - height)
      end
      if col + width > ui.width then
        col = math.max(0, ui.width - width)
      end

      float_state.last_row = row
      float_state.last_col = col
      float_state.opened = float_state.opened + 1

      if not float_state.base_win or not vim.api.nvim_win_is_valid(float_state.base_win) then
        float_state.base_win = orig_win
      end
    end

    local win = vim.api.nvim_open_win(bufnr, true, {
      relative = "editor",
      width = width,
      height = height,
      row = row,
      col = col,
      style = "minimal",
      border = "rounded",
    })

    push_float(win)

    local idx = 1

    local function jump_preview()
      if not (vim.api.nvim_win_is_valid(win) and vim.api.nvim_buf_is_valid(bufnr)) then
        return
      end
      local r = locs[idx].range
      vim.api.nvim_set_current_win(win)
      vim.api.nvim_win_set_cursor(win, { r.start.line + 1, r.start.character })
      vim.cmd("normal! zz")
    end

    jump_preview()

    vim.keymap.set("n", "q", close_current_float_and_focus_next, { buffer = bufnr, nowait = true })
    vim.keymap.set("n", "<Esc>", close_current_float_and_focus_next, { buffer = bufnr, nowait = true })

    vim.keymap.set("n", "<CR>", function()
      local loc = locs[idx]
      if not loc or not loc.uri or not loc.range then
        close_current_float_and_focus_next()
        return
      end

      local r = loc.range
      local fname = vim.uri_to_fname(loc.uri)

      close_all_floats()

      if float_state.base_win and vim.api.nvim_win_is_valid(float_state.base_win) then
        vim.api.nvim_set_current_win(float_state.base_win)
      end

      reset_float_state()

      vim.cmd("edit " .. vim.fn.fnameescape(fname))
      vim.api.nvim_win_set_cursor(0, { r.start.line + 1, r.start.character })
      vim.cmd("normal! zz")
    end, { buffer = bufnr, nowait = true })
  end)
end

return M
