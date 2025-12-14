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

function M.feedkeys(keys, mode)
  vim.schedule(function()
    vim.api.nvim_feedkeys(
      vim.api.nvim_replace_termcodes(keys, true, false, true),
      mode or "n",
      false
    )
  end)
end

function M.esc()
  M.feedkeys("<Esc>")
end

return M
