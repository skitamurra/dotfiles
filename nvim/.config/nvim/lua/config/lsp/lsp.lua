local util = require("lspconfig.util")

-- capabilities
local capabilities = vim.lsp.protocol.make_client_capabilities()
local ok_cmp, cmp = pcall(require, "cmp_nvim_lsp")
if ok_cmp then capabilities = cmp.default_capabilities(capabilities) end

-- ========= Pyright =========
local function read_cmd(cmd)
  local handle = io.popen(cmd)
  if not handle then
    return nil
  end
  local result = handle:read("*a") or ""
  handle:close()
  result = result:gsub("%s+$", "")
  if result == "" then
    return nil
  end
  return result
end

local function dir_exists(path)
  return path and path ~= "" and vim.fn.isdirectory(path) == 1
end

local function file_exists(path)
  return path and path ~= "" and vim.fn.filereadable(path) == 1
end

local function detect_venv(root)
  local venv = os.getenv("VIRTUAL_ENV")
  if venv and venv ~= "" and dir_exists(venv) then
    return venv
  end

  if file_exists(root .. "/Pipfile") then
    local cmd = "cd " .. vim.fn.shellescape(root) .. " && pipenv --venv 2>/dev/null"
    local pipenv_venv = read_cmd(cmd)
    if dir_exists(pipenv_venv) then
      return pipenv_venv
    end
  end

  if file_exists(root .. "/poetry.lock") or file_exists(root .. "/pyproject.toml") then
    local cmd = "cd " .. vim.fn.shellescape(root) .. " && poetry env info -p 2>/dev/null"
    local poetry_venv = read_cmd(cmd)
    if dir_exists(poetry_venv) then
      return poetry_venv
    end
  end

  local dot_venv = root .. "/.venv"
  if dir_exists(dot_venv) then
    return dot_venv
  end

  return nil
end

local function detect_python(root)
  local venv = detect_venv(root)
  if venv then
    local venv_python = venv .. "/bin/python"
    if vim.fn.executable(venv_python) == 1 then
      return venv_python, venv
    end
  end

  -- local pyenv_python = read_cmd("cd " .. vim.fn.shellescape(root) .. " && pyenv which python 2>/dev/null")
  -- if pyenv_python and vim.fn.executable(pyenv_python) == 1 then
  --   return pyenv_python, nil
  -- end

  -- local system_python = read_cmd("which python 2>/dev/null")
  -- if system_python and vim.fn.executable(system_python) == 1 then
  --   return system_python, nil
  -- end

  -- return nil, nil
end

local python_path, venv = detect_python(vim.loop.cwd())
vim.lsp.config("pyright", {
  capabilities = capabilities,
  settings = {
    python = {
      pythonPath = python_path,
      venvPath = vim.fn.fnamemodify(venv, ":h"),
      venv = vim.fn.fnamemodify(venv, ":t"),
    }
  }
})

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
