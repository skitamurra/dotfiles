local util = require("lspconfig.util")

-- capabilities
local capabilities = vim.lsp.protocol.make_client_capabilities()
local ok_cmp, cmp = pcall(require, "cmp_nvim_lsp")
if ok_cmp then capabilities = cmp.default_capabilities(capabilities) end

-- Pipenv の venv パス取得（グローバル venv を無視して Pipenv 優先）
local function pipenv_venv()
  local out = vim.fn.system("PIPENV_IGNORE_VIRTUALENVS=1 pipenv --venv 2>/dev/null"):gsub("%s+$", "")
  if vim.v.shell_error ~= 0 or out == "" then return nil end
  return out
end

-- 相対パスをルート起点で絶対化
local function absolute_extra_paths(root, rels)
  local out = {}
  for _, p in ipairs(rels or {}) do
    local ap = util.path.is_absolute(p) and p or util.path.join(root, p)
    table.insert(out, ap)
  end
  return out
end

-- ========= Pyright =========
vim.lsp.config("pyright", {
  capabilities = capabilities,
  root_dir = util.root_pattern("Pipfile", ".git"),
  on_new_config = function(cfg, root)
    root = root or vim.loop.cwd()

    local venv = pipenv_venv()
    local src_abs = util.path.join(root, "src")
    local dot_abs = root -- "."

    local extra = absolute_extra_paths(root, { "src", "." })

    cfg.settings = vim.tbl_deep_extend("force", cfg.settings or {}, {
      python = {
        analysis = {
          extraPaths = extra,
          diagnosticMode = "workspace",
          autoSearchPaths = true,
          useLibraryCodeForTypes = true,
        },
      },
    })

    local py_path_env = table.concat({
      (vim.fn.isdirectory(src_abs) == 1) and src_abs or nil,
      dot_abs,
    }, ":")

    cfg.cmd_env = vim.tbl_extend("force", cfg.cmd_env or {}, {
      PYTHONPATH = py_path_env .. (vim.env.PYTHONPATH and (":" .. vim.env.PYTHONPATH) or ""),
    })

    if venv then
      cfg.settings.python = cfg.settings.python or {}
      cfg.settings.python.venvPath = util.path.dirname(venv)
      cfg.settings.python.venv     = util.path.basename(venv)
      cfg.cmd_env.VIRTUAL_ENV = venv
      cfg.cmd_env.PATH = venv .. "/bin:" .. vim.env.PATH
    end
  end,
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
  -- configNamespace = "typescript",
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
    typescript = {},
  },
}

vim.lsp.config("vtsls", vtsls_config)
