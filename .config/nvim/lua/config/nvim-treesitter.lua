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
  max_lines = 3,
  trim_scope = "outer",
  mode = "cursor",
  separator = nil,
  zindex = 20,
  on_attach = nil
})

local function clear_treesitter_context_bg()
  local line_nr = vim.api.nvim_get_hl(0, { name = "LineNr", link = false })

  vim.api.nvim_set_hl(0, "TreesitterContext", { bg = "NONE" })
  vim.api.nvim_set_hl(0, "TreesitterContextBottom", { bg = "NONE" })
  vim.api.nvim_set_hl(0, "TreesitterContextLineNumber", vim.tbl_extend("force", line_nr, { bg = "NONE" }))
  vim.api.nvim_set_hl(0, "TreesitterContextLineNumberBottom", vim.tbl_extend("force", line_nr, { bg = "NONE" }))
end

clear_treesitter_context_bg()
