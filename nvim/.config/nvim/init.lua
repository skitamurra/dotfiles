vim.g.mapleader = " "
local keymap = vim.keymap
local lsp_def = require("config.lsp.definition")
local util = require("config.util")

keymap.set("n", "<leader><leader>", ":<C-u>cd %:h<CR>", { noremap = true, silent = true })
keymap.set("n", "H", "^", { noremap = true, silent = true })
keymap.set("n", "L", "$", { noremap = true, silent = true })
keymap.set("n", "J", "5j", { noremap = true, silent = true })
keymap.set("n", "K", "5k", { noremap = true, silent = true })
keymap.set("n", "gd", lsp_def.centered_float_definition)
keymap.set("i", "jj", "<esc>", { silent = true })
keymap.set("n", "<leader>f", "<cmd>NvimTreeFindFile<CR>", { noremap = true, silent = true })
keymap.set('n', '<leader>F', vim.diagnostic.open_float)
keymap.set("n", "<leader>w", "<C-w>", { silent = true })
keymap.set("n", "<leader>v", "<C-w>v", { silent = true })
keymap.set("n", "<leader>j", "<C-w>j", { silent = true })
keymap.set("n", "<leader>k", "<C-w>k", { silent = true })
keymap.set("n", "<leader>l", "<C-w>l", { silent = true })
keymap.set("n", "<leader>q", "<C-w>q", { silent = true })
keymap.set("n", "<leader>o", "<C-w>o", { silent = true })
keymap.set('n', '<leader>\\', "<Cmd>ToggleTerm<CR>", { noremap = true, silent = true, desc = "ToggleTerm"})
keymap.set('t', '<leader>\\', "<Cmd>ToggleTerm<CR>", { noremap = true, silent = true, desc = "ToggleTerm (terminal)"})

keymap.set("n", "<leader>t", function()
  local api = require("nvim-tree.api")
  local bufname = vim.api.nvim_buf_get_name(0)
  local path = vim.fn.fnamemodify(bufname, ":p:h")
  if vim.fn.isdirectory(path) == 1 then
    vim.cmd("lcd " .. vim.fn.fnameescape(path))
  end
  api.tree.toggle()
end, { noremap = true, silent = true, desc = "Toggle nvim-tree with buffer dir" })

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

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.showmode = false
vim.opt.shell = "/bin/bash"
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.smarttab = true
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.mouse = 'a'
vim.g.clever_f_smart_case = 1
vim.opt.clipboard = 'unnamedplus'
vim.g.clipboard = {
  name = "win32yank-wsl",
  copy = {
    ["+"] = "win32yank.exe -i --crlf",
    ["*"] = "win32yank.exe -i --crlf",
  },
  paste = {
    ["+"] = "win32yank.exe -o --lf",
    ["*"] = "win32yank.exe -o --lf",
  },
  cache_enabled = 0,
}
vim.opt.sessionoptions = {
  "buffers",      -- 開いていたバッファ
  "curdir",       -- カレントディレクトリ
  "tabpages",     -- タブページ
  "winsize",      -- ウィンドウサイズ
  "help",         -- ヘルプバッファ
  "globals",      -- グローバル変数 (g:var 保存対象)
  "folds",        -- 折り畳み状態
  "localoptions", -- buffer/window ローカルオプション
}
vim.diagnostic.config {
  severity_sort = true,
  float = {
    border = 'single',
    title = 'Diagnostics',
    header = {},
    suffix = {},
    format = function(diag)
      if diag.code then
        return string.format('[%s](%s): %s', diag.source, diag.code, diag.message)
      else
        return string.format('[%s]: %s', diag.source, diag.message)
      end
    end,
  },
}

require("plugins")
require("config.cmp")
