vim.g.mapleader = " "
vim.o.timeoutlen = 130
vim.opt.cmdheight = 0
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
vim.opt.title = true
vim.opt.titlestring = "%t"
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
require("keymaps")
require("config.util")
