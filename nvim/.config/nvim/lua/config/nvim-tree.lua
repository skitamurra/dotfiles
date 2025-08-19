local nvim_tree = require("nvim-tree")

nvim_tree.setup({
  sync_root_with_cwd = true,

  update_focused_file = {
    enable = true,
    update_root = true,
  },

  git = {
    enable = true,
    ignore = false,
  },

  renderer = {
    icons = {
      show = { git = true },
      glyphs = {
        git = {
          unstaged  = "~",
          staged    = "→",
          unmerged  = "",
          renamed   = "➜",
          untracked = "+",
          deleted   = "×",
          ignored   = "…",
        },
      },
    },
  },

  view = {
    adaptive_size = true,
  },
})
