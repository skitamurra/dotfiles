-- capabilities
local capabilities = vim.lsp.protocol.make_client_capabilities()
local ok_cmp, cmp = pcall(require, "cmp_nvim_lsp")
if ok_cmp then capabilities = cmp.default_capabilities(capabilities) end

-- ========= Pyright =========
local function dir_exists(path)
  return path and path ~= "" and vim.fn.isdirectory(path) == 1
end

local function detect_venv(root)
  local project = vim.fn.fnamemodify(root, ":t")
  local pattern = "~/.local/share/virtualenvs/" .. project .. "-*"
  local result = vim.fn.glob(pattern)
  if result ~= "" then
    local first = vim.split(result, "\n")[1]
    if dir_exists(first) then return first end
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
local pyright_config = {
  capabilities = capabilities,
}
if python_path then
  pyright_config.settings = {
    python = {
      pythonPath = python_path,
    },
  }
end

vim.lsp.config("pyright", pyright_config)

-- ========= lua =========
vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT",
      },
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
    },
  },
})

-- ========= vue =========
local vue_language_server_path = vim.fn.stdpath('data')
  .. "/mason/packages/vue-language-server/node_modules/@vue/language-server"

local tsserver_filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" }

local vue_plugin = {
  name = "@vue/typescript-plugin",
  location = vue_language_server_path,
  languages = { "vue" },
  configNamespace = "typescript",
  enableForWorkspaceTypeScriptVersions = true,
}

local vtsls_config = {
  filetypes = tsserver_filetypes,
  settings = {
    vtsls = {
      tsserver = {
        globalPlugins = {
          vue_plugin,
        },
      },
    },
  },
}

vim.lsp.config("vtsls", vtsls_config)
