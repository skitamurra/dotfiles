-- config/nvim-treesitter.lua

-- treesitterの構文ハイライトなどの基本設定
require("nvim-treesitter.configs").setup({
  ensure_installed = {
    "lua", "python", "typescript", "javascript",
    "vue", "tsx", "json", "html", "css", "dart"
  },
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  indent = {
    enable = true,
  },
})

-- sticky scroll（treesitter-context）設定
require("treesitter-context").setup({
  enable = true,
  max_lines = 3,         -- 最大表示行数（0なら制限なし）
  trim_scope = "outer", -- outer: 一番外側のスコープ
  mode = "cursor",       -- 'cursor' or 'topline'
  separator = nil,       -- 区切り線（文字列 or nil）
  zindex = 20,           -- 表示優先度
  on_attach = nil        -- 条件付き有効化（必要な場合に使う）
})

