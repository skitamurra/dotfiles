-- config/nvim-treesitter.lua

require("nvim-treesitter.configs").setup({
  ensure_installed = {
    "lua", "python", "typescript", "javascript",
    "vue", "tsx", "json", "html", "css", "dart",
    "regex", "bash",
  },
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  indent = {
    enable = true,
  },
})

require("treesitter-context").setup({
  enable = true,
  max_lines = 2,
  trim_scope = "inner",
  mode = "cursor",
  separator = nil,
})
