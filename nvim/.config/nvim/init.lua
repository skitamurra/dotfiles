vim.env.PATH = vim.env.PATH .. ':/home/skitamura/.nodenv/versions/20.12.2/bin'
local keymap = vim.keymap

vim.g.mapleader = " "

keymap.set("n", "<leader><leader>", ":<C-u>cd %:h<CR>", { noremap = true, silent = true })
keymap.set("n", "H", "^", { noremap = true, silent = true })
keymap.set("n", "L", "$", { noremap = true, silent = true })
keymap.set("n", "J", "5j", { noremap = true, silent = true })
keymap.set("n", "K", "5k", { noremap = true, silent = true })
keymap.set("n", "<leader>t", function()
  local api = require("nvim-tree.api")
  local bufname = vim.api.nvim_buf_get_name(0)
  local path = vim.fn.fnamemodify(bufname, ":p:h")

  if vim.fn.isdirectory(path) == 1 then
    vim.cmd("lcd " .. vim.fn.fnameescape(path))
  end

  api.tree.toggle()
end, { noremap = true, silent = true, desc = "Toggle nvim-tree with buffer dir" })

vim.keymap.set("n", "<leader>cd", function()
  local api = require("nvim-tree.api")
  api.tree.find_file({ open = true })       -- 開いているファイルをツリー上で探す
  api.tree.change_root_to_node()            -- そのノード（ディレクトリ）を cwd にする
end, { desc = "Set CWD to parent of current file" })

vim.keymap.set("n", "<leader>f", "<cmd>NvimTreeFindFile<CR>", { noremap = true, silent = true })
vim.keymap.set('n', '<leader>h', vim.diagnostic.open_float)
vim.keymap.set("n", "<leader>w", "<C-w>", { silent = true })
vim.keymap.set("n", "<leader>v", "<C-w>v", { silent = true })
vim.keymap.set("n", "<leader>h", "<C-w>h", { silent = true })
vim.keymap.set("n", "<leader>j", "<C-w>j", { silent = true })
vim.keymap.set("n", "<leader>k", "<C-w>k", { silent = true })
vim.keymap.set("n", "<leader>l", "<C-w>l", { silent = true })
vim.keymap.set("n", "<leader>q", "<C-w>q", { silent = true })
vim.keymap.set("n", "<leader>o", "<C-w>o", { silent = true })

vim.keymap.set('n', '<C-p>', function()
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

vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    vim.bo.fileformat = "unix"
  end,
})

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
require("nvim-tree").setup({
  update_cwd = true,
  respect_buf_cwd = true,
  view = {
    width = 30,
    side = "left",
    number = false,
    relativenumber = false,
  },
  sync_root_with_cwd = true,
})
require("config.lsp")
require("config.cmp")

