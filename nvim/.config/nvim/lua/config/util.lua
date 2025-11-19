-- lua/config/util.lua
local M = {}

function M.get_git_root()
  vim.fn.system("git rev-parse --show-toplevel")
  if vim.v.shell_error ~= 0 then
    return nil
  end
  return vim.fn.systemlist("git rev-parse --show-toplevel")[1]
end

return M
