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

function M.get_git_base()
  local base = vim.fn.systemlist([[git show-branch | grep '*' | grep -v "$(git rev-parse --abbrev-ref HEAD)" | head -1 | awk -F'[]~^[]' '{print $2}']])[1]
  if vim.v.shell_error ~= 0 then
    return nil
  end
  return base
end

function M.esc()
  vim.api.nvim_input("<Esc>")
end

function M.grep_file()
  local opts = { layout = "select"}
  if M.get_git_root() then
    Snacks.picker.git_files(opts, { untracked = true, submodules = false })
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

function M.blame_line_picker(win, buf)
  local cur = vim.api.nvim_win_get_cursor(win)[1]
  local hash
  for ln = cur, 1, -1 do
    local text = vim.api.nvim_buf_get_lines(buf, ln - 1, ln, false)[1] or ""
    hash = text:match("^commit (%x+)")
    if hash then break end
  end

  vim.system({
    "gh", "pr", "list", "--search", hash, "--state", "closed",
    "--json", "title,url",
  }, { text = true }, function(result)
    vim.schedule(function()
      local items = vim.tbl_map(function(pr)
        return { text = pr.title, title = pr.title, url = pr.url }
      end, vim.json.decode(result.stdout))

      if #items == 0 then
        vim.notify("No PRs found for " .. hash:sub(1, 8), vim.log.levels.INFO)
        return
      end
      Snacks.picker.pick({
        source = "gh_pr_list",
        items = items,
        format = function(item)
          return { { item.title, "Title" } }
        end,
        confirm = function(picker, item)
          picker:close()
          vim.ui.open(item.url)
          vim.schedule(function()
            if vim.api.nvim_win_is_valid(win) then
              vim.api.nvim_set_current_win(win)
            end
          end)
        end,
      })
    end)
  end)
end

return M
