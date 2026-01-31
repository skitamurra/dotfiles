return {
  cmd = vim.lsp.rpc.connect("127.0.0.1", 27631),
  init_options = {
    lspMux = {
      version = "1",
      method = "connect",
      server = "lua-language-server",
    },
  },
  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT",
      },
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("lua", true),
        checkThirdParty = false,
      },
      telemetry = {
        enable = false
      },
    },
  },
}
