-- config/nvim-treesitter.lua

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

require("treesitter-context").setup({
  enable = true,
  max_lines = 3,
  trim_scope = "outer",
  mode = "cursor",
  separator = nil,
  zindex = 20,
  on_attach = nil
})

