-- lua/config/lsp/definition.lua
local M = {}

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
    local row = math.floor((ui.height - height) / 2)
    local col = math.floor((ui.width - width) / 2)

    local orig_win = vim.api.nvim_get_current_win()

    local win = vim.api.nvim_open_win(bufnr, true, {
      relative = "editor",
      width = width,
      height = height,
      row = row,
      col = col,
      style = "minimal",
      border = "rounded",
    })

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

    vim.keymap.set("n", "<C-n>", function()
      if #locs > 1 then
        idx = idx % #locs + 1
        jump_preview()
      end
    end, { buffer = bufnr })

    vim.keymap.set("n", "<C-p>", function()
      if #locs > 1 then
        idx = (idx - 2) % #locs + 1
        jump_preview()
      end
    end, { buffer = bufnr })

    local function close_float()
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
    end

    vim.keymap.set("n", "q", close_float, { buffer = bufnr })
    vim.keymap.set("n", "<Esc>", close_float, { buffer = bufnr })

    vim.keymap.set("n", "<CR>", function()
      local loc = locs[idx]
      local r = loc.range
      local fname = vim.uri_to_fname(loc.uri)

      close_float()

      if vim.api.nvim_win_is_valid(orig_win) then
        vim.api.nvim_set_current_win(orig_win)
      end

      vim.cmd("edit " .. vim.fn.fnameescape(fname))
      vim.api.nvim_win_set_cursor(0, { r.start.line + 1, r.start.character })
      vim.cmd("normal! zz")
    end, { buffer = bufnr })
  end)
end

return M
