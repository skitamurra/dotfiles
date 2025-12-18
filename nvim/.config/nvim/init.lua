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
  "buffers",
  "curdir",
  "tabpages",
  "winsize",
  "help",
  "globals",
  "folds",
  "localoptions",
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

vim.api.nvim_create_autocmd("BufRead", {
  callback = function()
    local git_root = require("config.util").get_git_root()
    if git_root then
      vim.cmd("lcd " .. git_root)
    else
      vim.cmd("lcd %:h")
    end
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "help",
  callback = function()
    vim.cmd("wincmd L | :vert resize 80")
  end,
})

require("plugins")
require("keymaps")
require("config.util")
require("lsp")
