return {
  cmd = vim.lsp.rpc.connect("127.0.0.1", 27631),
  filetypes = { "rust" },
  root_markers = { "Cargo.lock", ".git" },
  init_options = {
    lspMux = {
      version = "1",
      method = "connect",
      server = "rust-analyzer",
    },
  },
  settings = {
    ["rust-analyzer"] = {
      cargo = { allTargets = false },
      checkOnSave = false,
      diagnostics = { enable = true },
      cachePriming = { enable = false },
    }
  },
}
