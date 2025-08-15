-- lua/config/nvim-autopairs.lua
local autopairs = require("nvim-autopairs")

autopairs.setup({
  check_ts = true, -- Treesitter連携で文法に沿った補完
  disable_filetype = { "TelescopePrompt", "vim" },
})

pcall(function()
  local cmp_autopairs = require("nvim-autopairs.completion.cmp")
  local cmp = require("cmp")
  cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
end)
