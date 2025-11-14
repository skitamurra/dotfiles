vim.env.PATH = vim.env.PATH .. ':/home/skitamura/.nodenv/versions/20.12.2/bin'
local keymap = vim.keymap

vim.g.mapleader = " "

keymap.set("n", "<leader><leader>", ":<C-u>cd %:h<CR>", { noremap = true, silent = true })
keymap.set("n", "H", "^", { noremap = true, silent = true })
keymap.set("n", "L", "$", { noremap = true, silent = true })
keymap.set("n", "J", "5j", { noremap = true, silent = true })
keymap.set("n", "K", "5k", { noremap = true, silent = true })
local function centered_float_definition()
  local params = vim.lsp.util.make_position_params()

  vim.lsp.buf_request(0, 'textDocument/definition', params, function(err, result, ctx, _)
    if err or not result or vim.tbl_isempty(result) then
      vim.notify('No definition found', vim.log.levels.INFO)
      return
    end

    local loc = result[1]
    if loc.targetUri then
      loc = { uri = loc.targetUri, range = loc.targetRange }
    end

    local uri = loc.uri or loc.targetUri
    if not uri then
      vim.notify('Invalid LSP location', vim.log.levels.WARN)
      return
    end

    local bufnr = vim.uri_to_bufnr(uri)
    vim.fn.bufload(bufnr)

    local ui = vim.api.nvim_list_uis()[1]
    local width = math.floor(ui.width * 0.8)
    local height = math.floor(ui.height * 0.8)
    local row = math.floor((ui.height - height) / 2)
    local col = math.floor((ui.width - width) / 2)

    local orig_win = vim.api.nvim_get_current_win()

    local win = vim.api.nvim_open_win(bufnr, true, {
      relative = 'editor',
      width = width,
      height = height,
      row = row,
      col = col,
      style = 'minimal',
      border = 'rounded',
    })

    local client = ctx and vim.lsp.get_client_by_id(ctx.client_id)
    local enc = client and client.offset_encoding or 'utf-16'

    vim.api.nvim_set_current_win(win)
    vim.lsp.util.jump_to_location(loc, enc)

    vim.keymap.set('n', '<CR>', function()
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
      if vim.api.nvim_win_is_valid(orig_win) then
        vim.api.nvim_set_current_win(orig_win)
      end
      vim.lsp.util.jump_to_location(loc, enc)
    end, { buffer = bufnr, nowait = true, silent = true })

    local function close_float()
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
      if vim.api.nvim_buf_is_valid(bufnr) then
        vim.api.nvim_buf_delete(bufnr, { force = true })
      end
    end

    vim.keymap.set('n', 'q', close_float, { buffer = bufnr, nowait = true, silent = true })
    vim.keymap.set('n', '<Esc>', close_float, { buffer = bufnr, nowait = true, silent = true })
  end)
end
keymap.set('n', 'gd', centered_float_definition)

keymap.set("n", "<leader>t", function()
  local api = require("nvim-tree.api")
  local bufname = vim.api.nvim_buf_get_name(0)
  local path = vim.fn.fnamemodify(bufname, ":p:h")

  if vim.fn.isdirectory(path) == 1 then
    vim.cmd("lcd " .. vim.fn.fnameescape(path))
  end

  api.tree.toggle()
end, { noremap = true, silent = true, desc = "Toggle nvim-tree with buffer dir" })

keymap.set("n", "<leader>f", "<cmd>NvimTreeFindFile<CR>", { noremap = true, silent = true })
keymap.set('n', '<leader>F', vim.diagnostic.open_float)
keymap.set("n", "<leader>w", "<C-w>", { silent = true })
keymap.set("n", "<leader>v", "<C-w>v", { silent = true })
keymap.set("n", "<leader>j", "<C-w>j", { silent = true })
keymap.set("n", "<leader>k", "<C-w>k", { silent = true })
keymap.set("n", "<leader>l", "<C-w>l", { silent = true })
keymap.set("n", "<leader>q", "<C-w>q", { silent = true })
keymap.set("n", "<leader>o", "<C-w>o", { silent = true })
keymap.set("n", "<leader>y", function()
  vim.fn.setreg("+", vim.fn.expand("%:p"))
  vim.notify("Copied: " .. vim.fn.expand("%:p"))
end, { desc = "Copy file path" })

keymap.set('n', '<C-p>', function()
  local builtin = require('telescope.builtin')

  -- Git管理下か判定
  vim.fn.system('git rev-parse --is-inside-work-tree')
  local in_git = (vim.v.shell_error == 0)

  if in_git then
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

  -- Git管理下か判定
  vim.fn.system('git rev-parse --show-toplevel')
  local in_git = (vim.v.shell_error == 0)

  if in_git then
    local git_root = vim.fn.systemlist('git rev-parse --show-toplevel')[1]
    builtin.live_grep({ search_dirs = { git_root } })
  else
    builtin.live_grep()
  end
end, { desc = 'Live Grep (git-aware)' })

keymap.set("i", "jj", "<esc>", { silent = true })

vim.o.encoding = 'utf-8'

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

vim.wo.number = true
vim.wo.relativenumber = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
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
vim.opt.shell = "/bin/bash"
vim.env.BASH_ENV = vim.fn.expand("~/.bash_aliases")

vim.o.autoindent = true
vim.o.smartindent = true
vim.o.smarttab = true
vim.o.expandtab = true
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.softtabstop = 2
vim.cmd("filetype plugin indent on")

vim.o.mouse = 'a'

vim.o.clipboard = 'unnamedplus'

vim.g.clever_f_across_no_line = 0
vim.g.clever_f_smart_case = 1

vim.lsp.handlers["textDocument/semanticTokens/full"] = function(_, result, ctx, _)
  local client = vim.lsp.get_client_by_id(ctx.client_id)
  if not client or not result then return end
  local bufnr = ctx.bufnr
  local legend = client.server_capabilities.semanticTokensProvider.legend
  local token_types = legend.tokenTypes
  local token_mods = legend.tokenModifiers
  -- ここで色のマッピングや適用をカスタマイズできる
end

require("plugins")
require("config.cmp")
