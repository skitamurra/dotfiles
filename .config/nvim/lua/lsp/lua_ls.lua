return {
  cmd = vim.lsp.rpc.connect("127.0.0.1", 27631),
  filetypes = { 'lua' },
  root_dir = function(bufnr, on_dir)
    local fname = vim.api.nvim_buf_get_name(bufnr)
    local root = vim.fs.root(fname, { '.git' })
    on_dir(root or vim.fn.fnamemodify(fname, ':h'))
  end,
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
        library = {
          vim.api.nvim_get_runtime_file("lua", true),
          '${3rd}/luv/library',
        },
        checkThirdParty = false,
      },
      telemetry = {
        enable = false
      },
    },
  },
}
