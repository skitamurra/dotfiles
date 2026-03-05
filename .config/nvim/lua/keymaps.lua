local lsp_def = require("config.definition")
local util = require("config.util")
local Snacks = require("snacks")
local undo_glow = require("undo-glow")

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
Map("n", "u", undo_glow.undo)
Map("n", "U", undo_glow.redo)
Map("n", "M", "%")
Map("n", "p", function()
  undo_glow.paste_below()
  vim.cmd.normal({ args = { '`]' }, bang = true })
end)
Map("n", "P", function()
  undo_glow.paste_above()
  vim.cmd.normal({ args = { '`]' }, bang = true })
end)
Map("n", "M", "%")
Map({"n", "v"}, ";", function() vim.api.nvim_feedkeys(":", "n", false) end)
Map({"n", "v"}, ":", function() vim.api.nvim_feedkeys(";", "n", false) end)
Map("n", "K", function() vim.lsp.buf.hover() end, {desc = "Hover documentation"})
Map("v", "y", "mzy`z")
Map("v", "p", "P")
Map("v", "<", "<gv")
Map("v", ">", ">gv")
Map("v", "q", "<ESC>")
Map({"i", "n"}, "<C-CR>", function() require("in-and-out").in_and_out() end)

Map("n", "i", function()
  return vim.fn.empty(vim.fn.getline(".")) == 1 and '"_cc' or "i"
end, { expr = true })

Map("n", "A", function()
  return vim.fn.empty(vim.fn.getline(".")) == 1 and '"_cc' or "A"
end, { expr = true })

Map({"n", "v"}, "*", function()
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
Map("n", "<leader>b", function() Snacks.picker.buffers() util.esc() end, { desc = "Buffers list" })
Map('n', '<leader>d', vim.diagnostic.open_float, { desc = "Show diagnostics" })
Map("n", "<leader>g", function() vim.cmd("LazyGit") end, { desc = "LazyGit" })
-- Map("n", "<leader>gg", function() Snacks.lazygit.open() end, { desc = "LazyGit" })
Map("n", "<leader>a", function() require("flash").jump() end, { desc = "Flash" } )
Map({ "n", "t" }, "<leader>\\", function() Snacks.terminal.toggle() end, { desc = "ToggleTerm" })
-- Map("n", "<leader>s", function() Snacks.picker.lsp_symbols() util.esc() end, { desc = "LSP symbol list" })
Map({"n", "v"}, "<leader>t", "<cmd>Pantran<CR>", { desc = "Show Translate Window" })
Map("n", "<leader>l", "", { desc = "Buffer mode"})
Map("n", "<leader>w", "", { desc = "Window mode"})
Map("n", "<leader>q", function() Snacks.picker.pickers() end, { desc = "Pickers" })
Map("n", "<leader>;", ":noh<CR>", { desc = "noh" })
Map({ "n", "t", "i", "x" }, "<C-.>", function() require("sidekick.cli").toggle({ name = "claude", focus = true }) end, { desc = "Sidekick Toggle" })
Map({ "x", "n" }, "<leader>st", function() require("sidekick.cli").send({ msg = "{this}", name = "claude" }) end, { desc = "Send This" })
Map("n", "<leader>sf", function() require("sidekick.cli").send({ msg = "{file}", name = "claude" }) end, { desc = "Send File" })
Map("x", "<leader>sv", function() require("sidekick.cli").send({ msg = "{selection}", name = "claude" }) end, { desc = "Send Visual Selection" })
Map({ "n", "x" }, "<leader>sp", function() require("sidekick.cli").prompt({ name = "claude"}) end, { desc = "Sidekick Select Prompt" })
Map({ "n", "x" }, "<leader>ss", function() require("sidekick.cli").focus({ name = "claude"}) end, { desc = "Focus sidekick" })
Map({ "n", "x" }, "<leader>sd", function() require("sidekick.cli").close() end, { desc = "Detach CLI Session" })

Map("n", "<leader>y", function()
  vim.fn.setreg("+", vim.fn.expand("%:p"))
  vim.notify("Copied: " .. vim.fn.expand("%:p"))
end, { desc = "Copy file path" })

Map("n", "<leader>p", function()
  local opts = { layout = "select"}
  if util.get_git_root() then
    Snacks.picker.git_files(opts, { submodules = false, ignored = true })
    return
  end
  Snacks.picker.files(opts)
end, { desc = "File grep" })

Map({ 'n', 'v' }, '<leader>fg', function()
  local text = (Snacks.picker.util.visual() or {}).text or ''
  util.open_grep({ on_show = function() vim.api.nvim_put({ text }, 'c', true, true) end })
  util.esc()
end, { desc = 'Fuzzy find' })

local grep_persistent_opts = { layout = { preset = "right", layout = { width = 0.3 } }, jump = { close = false }, auto_close = false, format = "filename" }

Map({ 'n', 'v' }, '<leader>fG', function()
  local text = (Snacks.picker.util.visual() or {}).text or ''
  util.open_grep(vim.tbl_extend('force', grep_persistent_opts, {
    on_show = function() vim.api.nvim_put({ text }, 'c', true, true) end,
  }))
  util.esc()
end, { desc = 'Grep (persistent picker)' })

Map("n", "<leader>ff", function()
  local root = util.get_git_root()
  if not root or root == "" then
    root = vim.fn.getcwd()
  end
  require("fyler").open({ dir = root, kind = "float" })
end, { desc = "Fyler" })
