local keymap = vim.keymap
local lsp_def = require("config.lsp.definition")
local util = require("config.util")

keymap.set("n", "<leader><leader>", ":<C-u>cd %:h<CR>", { noremap = true, silent = true, desc = "CD to current file dir" })
keymap.set("n", "H", "^", { noremap = true, silent = true })
keymap.set("n", "L", "$", { noremap = true, silent = true })
-- keymap.set("n", "<C-j>", "5j", { noremap = true, silent = true })
-- keymap.set("n", "<C-k>", "5k", { noremap = true, silent = true })
keymap.set("n", "gd", lsp_def.centered_float_definition, { desc = "Go to definition" })
keymap.set('n', '<leader>F', vim.diagnostic.open_float, { desc = "Show diagnostics float" })
keymap.set("n", "<leader>w", "<C-w>", { silent = true, desc = "Window prefix" })
keymap.set("n", "<leader>v", "<C-w>v", { silent = true, desc = "Vertical split" })
keymap.set("n", "<leader>j", "<C-w>j", { silent = true, desc = "Move to window below" })
keymap.set("n", "<leader>k", "<C-w>k", { silent = true, desc = "Move to window above" })
keymap.set("n", "<leader>l", "<C-w>l", { silent = true, desc = "Move to window right" })
keymap.set("n", "<leader>q", "<C-w>q", { silent = true, desc = "Close window" })
keymap.set("n", "<leader>o", "<C-w>o", { silent = true, desc = "Close other windows" })

keymap.set("n", "<leader>g", function()
  vim.cmd("LazyGit")
end, { silent = true, desc = "LazyGit" })

keymap.set("n", "<leader>a", function()
  vim.cmd("HopWord")
end, { silent = true, desc = "Hop Word" })

keymap.set("n", "<leader>\\", function()
  vim.cmd("ToggleTerm")
end, { noremap = true, silent = true, desc = "ToggleTerm" })

keymap.set("t", "<leader>\\", function()
  vim.cmd("ToggleTerm")
end, { noremap = true, silent = true, desc = "ToggleTerm (terminal)" })

keymap.set("n", "<leader>s", function()
  vim.cmd("Namu symbols")
end, { noremap = true, silent = true, desc = "Jump to LSP symbol" })

keymap.set("n", "<leader>h", function()
  vim.cmd("BufferLineCyclePrev")
end, { noremap = true, silent = true })

keymap.set("n", "<leader>l", function()
  vim.cmd("BufferLineCycleNext")
end, { noremap = true, silent = true })

keymap.set("n", "<leader>w", function()
  vim.cmd("bdelete")
end, { noremap = true, silent = true })

keymap.set("n", "*", function()
  if vim.v.count > 0 then
    return
  end
  local view = vim.fn.winsaveview()
  vim.cmd([[silent keepj normal! *]])
  vim.fn.winrestview(view)
end, { silent = true })

keymap.set("n", "<leader>y", function()
  vim.fn.setreg("+", vim.fn.expand("%:p"))
  vim.notify("Copied: " .. vim.fn.expand("%:p"))
end, { desc = "Copy file path" })

keymap.set('n', '<C-p>', function()
  local builtin = require('telescope.builtin')
  local git_root = util.get_git_root()
  if git_root then
    local ok = pcall(builtin.git_files, { show_untracked = true })
    if not ok then
      builtin.find_files()
    end
  else
    builtin.find_files()
  end
end, { desc = 'Files (git-aware)' })

keymap.set('n', '<C-S-f>', function()
  local builtin = require('telescope.builtin')
  local git_root = util.get_git_root()
  if git_root then
    builtin.live_grep({ search_dirs = { git_root } })
  else
    builtin.live_grep()
  end
end, { desc = 'Live Grep (git-aware)' })

keymap.set("n", "<leader>f", function()
  local root = util.get_git_root()
  if not root or root == "" then
    root = vim.fn.getcwd()
  end
  require("fyler").open({ dir = root, kind = "float" })
end, { noremap = true, silent = true, desc = "Fyler" })
