vim.g.mapleader = " "
vim.o.timeoutlen = 130
vim.opt.cmdheight = 0
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.showmode = false
vim.opt.shell = "/usr/bin/zsh"
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
vim.opt.exrc = true
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

vim.api.nvim_create_autocmd('QuitPre', {
  callback = function()
    local current_win = vim.api.nvim_get_current_win()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if win ~= current_win then
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].buftype == '' then
          return
        end
      end
    end
    vim.cmd.only({ bang = true })
  end,
  desc = 'Close all special buffers and quit Neovim',
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    vim.api.nvim_create_autocmd("BufWritePre", {
      pattern = { "*.rs" },
      callback = function()
        vim.lsp.buf.format({
          buffer = ev.buf,
          filter = function(f_client)
            return f_client.name ~= "null-ls"
          end,
          async = false,
        })
      end,
    })
  end,
})

require("plugins")
require("keymaps")
require("config.util")
require("lsp")
