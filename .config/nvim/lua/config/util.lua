-- lua/config/util.lua
local M = {}
local Snacks = require("snacks")

local git_root_cache = {}

function M.get_git_root(path)
  local cwd = vim.fn.getcwd()
  if git_root_cache[cwd] ~= nil then
    return git_root_cache[cwd]
  end

  local root = require("snacks").git.get_root(path or nil)
  if vim.v.shell_error ~= 0 or not root or root == "" then
    git_root_cache[cwd] = nil
    return nil
  end

  git_root_cache[cwd] = root
  return root
end

function M.esc()
  vim.api.nvim_input("<Esc>")
end

function M.grep_file()
  local opts = { layout = "select"}
  if M.get_git_root() then
    Snacks.picker.git_files(opts, { submodules = false, ignored = false })
    return
  end
  Snacks.picker.files(opts)
end

-- Parse `-e pattern` from the search query and convert to exclude args.
-- rg uses `-g !pattern`, git grep uses `:!pattern` pathspec.
function M.grep_text(opts)
  local is_git = M.get_git_root() ~= nil
  local full_opts = vim.tbl_deep_extend('force', opts or {}, {
    filter = { transform = function(_, filter)
      local excludes = {}
      local clean = filter.search:gsub('%s*%-e%s+(%S+)', function(e)
        table.insert(excludes, e)
        return ''
      end)
      if #excludes > 0 then
        local args = {}
        for _, e in ipairs(excludes) do
          if is_git then
            args[#args + 1] = ':!' .. e
          else
            args[#args + 1] = '-g !' .. e
          end
        end
        filter.search = vim.trim(clean) .. ' -- ' .. table.concat(args, ' ')
      end
    end },
  })
  if is_git then
    Snacks.picker.git_grep(vim.tbl_extend('force', full_opts, { submodules = false, ignored = true }))
    return
  end
  Snacks.picker.grep(full_opts)
end

return M
