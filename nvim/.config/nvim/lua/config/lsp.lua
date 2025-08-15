local lspconfig = require("lspconfig")
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

local capabilities = require("cmp_nvim_lsp").default_capabilities()

require("lspconfig").pyright.setup({
  capabilities = capabilities,
  settings = {
    python = {
      pythonPath = get_pipenv_python()
    }
  }
})

lspconfig.ts_ls.setup({ capabilities = capabilities })
lspconfig.volar.setup({
  capabilities = capabilities,
  filetypes = { "typescript", "javascript", "vue" },
})
lspconfig.dartls.setup({ capabilities = capabilities })


