local util = require("lspconfig.util")
local tslsp = vim.fn.exepath("typescript-language-server")

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

-- =========
-- Pyright
-- =========
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

-- ========= TypeScript / JavaScript =========
-- 利用可能なTSサーバ名を自動選択（ts_ls → vtsls → tsserver）
local function ts_root(fname)
  return util.root_pattern(
    "tsconfig.json","jsconfig.json",
    "package.json","pnpm-workspace.yaml",
    "yarn.lock","pnpm-lock.yaml"
  )(fname) or util.find_git_ancestor(fname) or vim.loop.cwd()
end

local ok_cfgs, cfgs = pcall(require, "lspconfig.configs")
local ts_name = (ok_cfgs and (
  (cfgs.ts_ls and "ts_ls")
  or (cfgs.vtsls and "vtsls")
  or (cfgs.tsserver and "tsserver")
)) or "tsserver"

local ts_root = util.root_pattern("tsconfig.json", "jsconfig.json", "package.json", ".git")

vim.lsp.config(ts_name, {
  capabilities = capabilities,
  filetypes = {
    "javascript","javascriptreact",
    "typescript","typescriptreact",
    "vue",  -- ← vue バッファでも TS クライアントを立ち上げる
  },
  root_dir = ts_root,
  -- ★ cmd を明示（nil を回避）
  cmd = (tslsp ~= "" and { tslsp, "--stdio" } or nil),
  on_init = function(client)
    if tslsp == "" then
      vim.notify(
        "typescript-language-server が見つかりません。Mason または PATH を確認して下さい。",
        vim.log.levels.ERROR
      )
      client.stop()
    end
  end,
})

-- ========= Vue (Volar / vue_ls) =========
vim.lsp.config("vue_ls", {
  capabilities = capabilities,
  -- Volar の root は TS と合わせる
  root_dir = ts_root,
  filetypes = { "vue", "javascript", "typescript" },
  -- 必要なら:
  -- init_options = { typescript = { tsdk = "<project>/node_modules/typescript/lib" } },
})

-- ========= Dart / Flutter =========
vim.lsp.config("dartls", {                 -- ★ dcm → dartls
  capabilities = capabilities,
})

-- 起動順でTS→Vueを先に（依存満たしやすくする）
vim.lsp.enable({ ts_name, "vue_ls", "pyright", "dartls" })

-- それでも .vue を先に開くと間に合わない環境向けの“保険”
vim.api.nvim_create_autocmd("BufReadPre", {
  pattern = "*.vue",
  callback = function(args)
    -- すでに ts クライアントがいれば何もしない
    for _, c in ipairs(vim.lsp.get_active_clients({ bufnr = args.buf })) do
      if c.name == ts_name then return end
    end
    -- 同一rootでTSクライアントを起動
    local root = ts_root(args.file)
    if root then vim.lsp.enable(ts_name, { root_dir = root }) end
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
