local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"

return {
  cmd = { mason_bin .. "/rust-analyzer" },
  filetypes = { "rust" },
  root_markers = { "Cargo.toml", ".git"},
  settings = {
    ["rust-analyzer"] = {
      check = { command = "clippy" },
      diagnostics = { enable = true },
    }
  },
}
