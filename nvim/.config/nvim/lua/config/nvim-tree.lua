local nvim_tree = require("nvim-tree")

nvim_tree.setup({
  update_cwd = true,
  update_focused_file = {
    enable = true,
    update_cwd = true,
  },
  git = {
    enable = true,
    ignore = false,
  },
  renderer = {
    icons = {
      show = {
        git = true,
      },
      glyphs = {
        git = {
          unstaged = "~",
          staged = "→",
          unmerged = "",
          renamed = "➜",
          untracked = "+",
          deleted = "×",
          ignored = "…",
        },
      },
    },
  },
})
