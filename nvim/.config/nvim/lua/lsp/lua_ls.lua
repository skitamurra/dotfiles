local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"

 return {
   cmd = { mason_bin .. "/lua-language-server" },
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
       telemetry = {
         enable = false
       },
     },
   },
 }
