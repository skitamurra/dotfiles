-- lua/config/util.lua
local M = {}

local git_root_cache = {}

function M.get_git_root()
  local cwd = vim.fn.getcwd()
  if git_root_cache[cwd] ~= nil then
    return git_root_cache[cwd]
  end

  local root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
  if vim.v.shell_error ~= 0 or not root or root == "" then
    git_root_cache[cwd] = nil
    return nil
  end

  git_root_cache[cwd] = root
  return root
end

function M.open_diff(path)
  if not path or path == "" then
    vim.notify("no path from lazygit", vim.log.levels.ERROR)
    return
  end

  -- lazygit terminal window を保存
  local term_win = vim.api.nvim_get_current_win()

  local root = M.get_git_root()
  if not root then
    vim.notify("not in git repo", vim.log.levels.ERROR)
    return
  end

  -- git root + path を優先
  local rel_path = path
  local candidate = root .. "/" .. path
  local abs_path = nil

  if vim.fn.filereadable(candidate) == 1 then
    abs_path = candidate
  else
    local abs_from_cwd = vim.fn.fnamemodify(path, ":p")
    if vim.fn.filereadable(abs_from_cwd) == 1 then
      abs_path = abs_from_cwd
      if abs_path:sub(1, #root) == root then
        rel_path = abs_path:sub(#root + 2)
      end
    else
      vim.notify("file not found: " .. path, vim.log.levels.ERROR)
      return
    end
  end

  ---------------------------------------------------
  -- ★ untracked file 判定
  ---------------------------------------------------
  local status_cmd = string.format(
    "cd %s && git ls-files --error-unmatch %s 2>/dev/null",
    vim.fn.shellescape(root),
    vim.fn.shellescape(rel_path)
  )
  local tracked = vim.fn.system(status_cmd)
  local is_tracked = vim.v.shell_error == 0

  ---------------------------------------------------
  -- ★ diff コマンドの組み分け
  ---------------------------------------------------
  local diff_cmd

  if is_tracked then
    -- 既存ファイル（未/ステージ済み差分）
    diff_cmd = string.format(
      "cd %s && git diff HEAD -- %s",
      vim.fn.shellescape(root),
      vim.fn.shellescape(rel_path)
    )
  else
    -- 新規ファイル → /dev/null と比較する
    diff_cmd = string.format(
      "cd %s && git diff --no-index /dev/null %s",
      vim.fn.shellescape(root),
      vim.fn.shellescape(rel_path)
    )
  end

  -- diff 実行
  local output = vim.fn.systemlist(diff_cmd)

  if #output == 0 then
    vim.notify("no diff for " .. rel_path, vim.log.levels.INFO)
    return
  end

  ---------------------------------------------------
  -- float buffer 作成
  ---------------------------------------------------
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
  vim.api.nvim_buf_set_option(buf, "filetype", "diff")
  vim.api.nvim_buf_set_option(buf, "swapfile", false)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, output)

  ---------------------------------------------------
  -- float window
  ---------------------------------------------------
  local columns = vim.o.columns
  local lines   = vim.o.lines
  local width   = math.floor(columns * 0.8)
  local	height  = math.floor(lines * 0.8)
  local row     = math.floor((lines - height) / 2)
  local col     = math.floor((columns - width) / 2)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    style    = "minimal",
    border   = "rounded",
    row      = row,
    col      = col,
    width    = width,
    height   = height,
  })

  ---------------------------------------------------
  -- q で閉じる + lazygit の terminal に戻す
  ---------------------------------------------------
  vim.keymap.set("n", "q", function()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end

    if vim.api.nvim_win_is_valid(term_win) then
      vim.api.nvim_set_current_win(term_win)
      vim.cmd("startinsert")  -- ← lazygit を job-mode へ戻す
    end
  end, { buffer = buf, nowait = true })
end

return M
