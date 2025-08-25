local lspconfig = require("lspconfig")
local util = require("lspconfig.util")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

local function get_pipenv_python()
  local handle = io.popen("pipenv --venv")
  if handle then
    local result = handle:read("*a")
    handle:close()
    local venv = result:gsub("\n", "")
    return venv .. "/bin/python"
  end
end

local ok_lsp, lspconfig = pcall(require, "lspconfig")
if not ok_lsp then return end

local util = require("lspconfig.util")

local function pipenv_venv()
  local out = vim.fn.system("PIPENV_IGNORE_VIRTUALENVS=1 pipenv --venv 2>/dev/null"):gsub("%s+$", "")
  if vim.v.shell_error ~= 0 or out == "" then return nil end
  return out
end

local function absolute_extra_paths(root, rels)
  local out = {}
  for _, p in ipairs(rels or {}) do
    local ap = util.path.is_absolute(p) and p or util.path.join(root, p)
    table.insert(out, ap)
  end
  return out
end

-- capabilities
local capabilities = vim.lsp.protocol.make_client_capabilities()
local ok_cmp, cmp = pcall(require, "cmp_nvim_lsp")
if ok_cmp then capabilities = cmp.default_capabilities(capabilities) end

lspconfig.pyright.setup({
  capabilities = capabilities,
  root_dir = util.root_pattern("Pipfile", ".git"),
  on_new_config = function(cfg, root)
    root = root or vim.loop.cwd()

    local venv = pipenv_venv()
    local src_abs = util.path.join(root, "src")
    local dot_abs = root  -- "."

    -- ★ extraPaths を絶対化
    local extra = absolute_extra_paths(root, { "src", "." })

    cfg.settings = vim.tbl_deep_extend("force", cfg.settings or {}, {
      python = {
        analysis = {
          extraPaths = extra,
          diagnosticMode = "workspace",  -- ★ openFilesOnly をやめる
          autoSearchPaths = true,
          useLibraryCodeForTypes = true,
        },
      },
    })

    -- ★ ここがポイント: サーバ環境にも PYTHONPATH を通す
    local py_path_env = table.concat({
      -- src が実在するなら先頭に追加
      (vim.fn.isdirectory(src_abs) == 1) and src_abs or nil,
      dot_abs,  -- ルート（"."）
    }, ":")

    cfg.cmd_env = vim.tbl_extend("force", cfg.cmd_env or {}, {
      PYTHONPATH = py_path_env .. (vim.env.PYTHONPATH and (":" .. vim.env.PYTHONPATH) or ""),
    })

    if venv then
      cfg.settings.python.venvPath = util.path.dirname(venv)
      cfg.settings.python.venv     = util.path.basename(venv)
      cfg.cmd_env.VIRTUAL_ENV = venv
      cfg.cmd_env.PATH = venv .. "/bin:" .. vim.env.PATH
    end
  end,
})

lspconfig.ts_ls.setup({ capabilities = capabilities })
lspconfig.volar.setup({
  capabilities = capabilities,
  filetypes = { "typescript", "javascript", "vue" },
})
lspconfig.dartls.setup({ capabilities = capabilities })


