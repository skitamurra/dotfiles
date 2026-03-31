local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
local pyright_config = {
  cmd = { mason_bin .. "/pyright-langserver", "--stdio" },
  filetypes = { 'python' },
}

local function detect_venv(root)
  local project = vim.fn.fnamemodify(root, ":t")
  local pattern = "~/.local/share/virtualenvs/" .. project .. "-*"
  local result = vim.fn.glob(pattern)
  if result ~= "" then
    local venv = vim.split(result, "\n")[1]
    if venv and venv ~= "" and vim.fn.isdirectory(venv) then
      return venv
    end
  end
  return nil
end

local function detect_python()
  local root = require("config.util").get_git_root()
  local venv = detect_venv(root)
  if venv then
    local python = venv .. "/bin/python"
    if vim.fn.executable(python) == 1 then
      return python
    end
  end
  return nil
end

local python_path = detect_python()
local global_stub_path = vim.fn.expand("~/.local/share/python-stubs")
pyright_config.settings = {
  python = {
    pythonPath = python_path,
    analysis = {
      extraPaths = {
        global_stub_path
      },
    },
  },
}

return pyright_config
