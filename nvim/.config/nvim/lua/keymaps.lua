local lsp_def = require("config.definition")
local util = require("config.util")
local Snacks = require("snacks")

function Map(mode, lhs, rhs, opts)
  vim.keymap.set(mode, lhs, rhs,
    vim.tbl_extend("force", {
      noremap = true,
      silent  = true,
      desc    = "",
    }, opts or {})
  )
end

Map("n", "Y", "y$")
Map("n", "X", "_d")
Map("n", "X", "_D")
Map("n", "U", "<C-r>")
Map("n", "M", "%")
Map("v", "y", "mzy`z")
Map("v", "p", "P")
Map("v", "<", "<gv")
Map("v", ">", ">gv")
Map("v", "q", "<ESC>")
Map("n", "M", "%")
Map("n", "p", "]p`]")
Map("n", ";", function() vim.api.nvim_feedkeys(":", "n", false) end)
Map("n", ":", function() vim.api.nvim_feedkeys(";", "n", false) end)
-- Map("n", "K", "<cmd>Lspsaga hover_doc<CR>")

Map("n", "i", function()
  return vim.fn.empty(vim.fn.getline(".")) == 1 and '"_cc' or "i"
end, { expr = true })

Map("n", "A", function()
  return vim.fn.empty(vim.fn.getline(".")) == 1 and '"_cc' or "A"
end, { expr = true })

Map("n", "*", function()
  if vim.v.count > 0 then
    return
  end
  local view = vim.fn.winsaveview()
  vim.cmd([[silent keepj normal! *]])
  vim.fn.winrestview(view)
end)

Map("n", "<leader><leader>", ":<C-u>lcd %:h<CR>", { desc = "CD to current file dir" })
Map("n", "gd", lsp_def.centered_float_definition, { desc = "Go to definition" })
Map("n", "gD", function() Snacks.picker.lsp_definitions({ include_current = true, auto_confirm = false }) util.esc() end, { desc = "Definitions list" })
Map('n', '<leader>d', vim.diagnostic.open_float, { desc = "Show diagnostics" })
Map("n", "<leader>g", function() vim.cmd("LazyGit") end, { desc = "LazyGit" })
-- Map("n", "<leader>gg", function() Snacks.lazygit.open() end, { desc = "LazyGit" })
Map("n", "<leader>a", function() require("flash").jump() end, { desc = "Flash" } )
Map({ "n", "t" }, "<leader>\\", function() Snacks.terminal.toggle() end, { desc = "ToggleTerm" })
Map("n", "<leader>s", function() vim.cmd("Namu symbols") end, { desc = "Jump to LSP symbol" })
Map({"n", "v"}, "<leader>t", "<cmd>Pantran<CR>", { desc = "Show Translate Window" })
Map("n", "<leader>l", "", { desc = "Buffer mode"})
Map("n", "<leader>qs", function() require("persistence").select() end, { desc = "Select a session to load" })
Map("n", "<leader>qd", function() require("persistence").stop() end, { desc = "Stop Persistence" })

Map("n", "<leader>y", function()
  vim.fn.setreg("+", vim.fn.expand("%:p"))
  vim.notify("Copied: " .. vim.fn.expand("%:p"))
end, { desc = "Copy file path" })

Map("n", "<leader>p", function()
  local opts = { layout = "select"}
  if util.get_git_root() then
    Snacks.picker.git_files(opts, { untracked = true })
    return
  end
  Snacks.picker.files(opts)
end, { desc = "File grep" })

Map('n', '<leader>F', function()
  if util.get_git_root() then
    Snacks.picker.git_grep()
    return
  end
  Snacks.picker.grep()
end, { desc = 'Fuzzy find' })

Map("n", "<leader>f", function()
  local root = util.get_git_root()
  if not root or root == "" then
    root = vim.fn.getcwd()
  end
  require("fyler").open({ dir = root, kind = "float" })
end, { desc = "Fyler" })
