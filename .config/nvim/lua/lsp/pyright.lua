local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
local pyright_config = {
  cmd = { mason_bin .. "/pyright-langserver", "--stdio" },
  filetypes = { 'python' },
  root_markers = { "Pipfile", ".git" },
  settings = {
    python = { pythonPath = '.venv/bin/python' },
  },
}

return pyright_config
