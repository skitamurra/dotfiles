return {
  cmd = vim.lsp.rpc.connect("127.0.0.1", 27631),
  filetypes = { "rust" },
  root_markers = { "Cargo.toml", ".git"},
  settings = {
    ["rust-analyzer"] = {
      check = { command = "clippy" },
      diagnostics = { enable = true },
      lspMux = {
        version = "1",
        method = "connect",
        server = "rust-analyzer",
      }
    }
  },
}
