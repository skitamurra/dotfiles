local lsp_def = require("config.lsp.definition")
local util = require("config.util")

function Map(mode, lhs, rhs, opts)
  vim.keymap.set(mode, lhs, rhs,
    vim.tbl_extend("force", {
      noremap = true,
      silent  = true,
      desc    = "",
    }, opts or {})
  )
end

Map("n", "Y", "y$")
Map("n", "X", "_d")
Map("n", "X", "_D")
Map("n", "U", "<C-r>")
Map("n", "M", "%")
Map("v", "y", "mzy`z")
Map("v", "p", "P")
Map("v", "<", "<gv")
Map("v", ">", ">gv")
Map("v", "q", "<ESC>")
Map("n", "M", "%")
-- Map("n", "/", "/\v")
Map("n", "p", "]p`]")

Map("n", "i", function()
  return vim.fn.empty(vim.fn.getline(".")) == 1 and '"_cc' or "i"
end, { expr = true })

Map("n", "A", function()
  return vim.fn.empty(vim.fn.getline(".")) == 1 and '"_cc' or "A"
end, { expr = true })

Map("n", "*", function()
  if vim.v.count > 0 then
    return
  end
  local view = vim.fn.winsaveview()
  vim.cmd([[silent keepj normal! *]])
  vim.fn.winrestview(view)
end)

Map("n", "<leader><leader>", ":<C-u>cd %:h<CR>", { desc = "CD to current file dir" })
Map("n", "gd", lsp_def.centered_float_definition, { desc = "Go to definition" })
Map('n', '<leader>d', vim.diagnostic.open_float, { desc = "Show diagnostics" })
Map("n", "<leader>w", "<C-w>", { silent = true, desc = "Window prefix" })
-- Map("n", "<leader>v", "<C-w>v", { silent = true, desc = "Vertical split" })
-- Map("n", "<leader>j", "<C-w>j", { silent = true, desc = "Move to window below" })
-- Map("n", "<leader>k", "<C-w>k", { silent = true, desc = "Move to window above" })
-- Map("n", "<leader>l", "<C-w>l", { silent = true, desc = "Move to window right" })
-- Map("n", "<leader>q", "<C-w>q", { silent = true, desc = "Close window" })
-- Map("n", "<leader>o", "<C-w>o", { silent = true, desc = "Close other windows" })
Map("n", "<leader>g", function() vim.cmd("LazyGit") end, { desc = "LazyGit" })
Map("n", "<leader>a", function() vim.cmd("HopWord") end, { desc = "HopWord" })
Map({ "n", "t" }, "<leader>\\", function() vim.cmd("ToggleTerm") end, { desc = "ToggleTerm" })
Map("n", "<leader>s", function() vim.cmd("Namu symbols") end, { desc = "Jump to LSP symbol" })
Map({"n", "v"}, "<leader>t", "<cmd>Pantran<CR>", { desc = "Show Translate Window" })
Map("n", "<leader>b", "", { desc = "Buffer mode"})

Map("n", "<leader>y", function()
  vim.fn.setreg("+", vim.fn.expand("%:p"))
  vim.notify("Copied: " .. vim.fn.expand("%:p"))
end, { desc = "Copy file path" })

Map("n", "<leader>p", function()
  local builtin = require("telescope.builtin")
  if pcall(builtin.git_files, { show_untracked = true }) then
    return
  end
  builtin.find_files()
end, { desc = "File grep" })

Map('n', '<leader>F', function()
  local builtin = require('telescope.builtin')
  local git_root = util.get_git_root()
  if git_root then
    builtin.live_grep({ search_dirs = { git_root } })
  else
    builtin.live_grep()
  end
end, { desc = 'Fuzzy find' })

Map("n", "<leader>f", function()
  local root = util.get_git_root()
  if not root or root == "" then
    root = vim.fn.getcwd()
  end
  require("fyler").open({ dir = root, kind = "float" })
end, { desc = "Fyler" })
