local lsp_def = require("config.definition")
local util = require("config.util")
local Snacks = require("snacks")
local undo_glow = require("undo-glow")
local root = util.get_git_root()
local git_base = util.get_git_base()

function Map(mode, lhs, rhs, opts)
  vim.keymap.set(mode, lhs, rhs,
    vim.tbl_extend("force", {
      noremap = true,
      silent  = true,
      desc    = "",
    }, opts or {})
  )
end

Map("n", "_", "\"_")
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
Map({"n", "v", "c"}, ";", function() vim.api.nvim_feedkeys(":", "n", false) end)
Map({"n", "v", "c"}, ":", function() vim.api.nvim_feedkeys(";", "n", false) end)
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
Map("n", "gi", lsp_def.centered_float_implementation, { desc = "Go to implementation" })
Map("n", "gh", function() require("treesitter-context").go_to_context(vim.v.count1) end, { desc = "Go to context head" })
Map("n", "gs", function() Snacks.picker.lsp_symbols() end, { desc = "Lsp symbols" })
Map("n", "<leader>b", function() require("buffer_manager.ui").toggle_quick_menu() end, { desc = "Buffers list" })
Map('n', '<leader>d', vim.diagnostic.open_float, { desc = "Show diagnostics" })
Map("n", "<leader>g", "", { desc = "Git" })
Map("n", "<leader>gl", "<cmd>LazyGit<CR>", { desc = "LazyGit" })
Map("n", "<leader>gb", function() Snacks.git.blame_line() end, { desc = "Blame line" })
Map("n", "<leader>gd", function() Snacks.terminal.open({ "hunk", "diff" }, { cwd = root }) end, { desc = "against branch" })
Map("n", "<leader>gm", function() Snacks.terminal.open({ "hunk", "diff", git_base and git_base .. "...HEAD" or nil }, { cwd = root }) end, { desc = "against base" })
Map("n", "<leader>a", function() require("flash").jump() end, { desc = "Flash" } )
Map({ "n", "t" }, "<leader>\\", function() Snacks.terminal.toggle() end, { desc = "ToggleTerm" })
Map({"n", "v"}, "<leader>t", "<cmd>Pantran<CR>", { desc = "Show Translate Window" })
Map("n", "<leader>l", "", { desc = "Buffer mode"})
Map("n", "<leader>w", "", { desc = "Window mode"})
Map("n", "<leader>q", function() Snacks.picker.pickers() end, { desc = "Pickers" })
Map("n", "<leader>;", ":noh<CR>", { desc = "noh" })
Map({ "n", "t", "i", "x" }, "<C-.>", function() require("sidekick.cli").toggle() end, { desc = "Sidekick Toggle" })
Map({ "n", "x" }, "<leader>ss", function() require("sidekick.cli").focus() end, { desc = "Sidekick Focus" })
Map({ "n", "x" }, "<leader>sf", function() require("sidekick.cli").send({ msg = "{file}" }) end, { desc = "Send File" })
Map({ "n", "x" }, "<leader>st", function() require("sidekick.cli").send({ msg = "{this}" }) end, { desc = "Send This" })
Map({ "n", "x" }, "<leader>sp", function() require("sidekick.cli").prompt() end, { desc = "Sidekick Select Prompt" })
Map({ "n", "x" }, "<leader>sd", function() require("sidekick.cli").close() end, { desc = "Detach CLI Session" })
Map({ "n", "t" }, "<C-h>", "<cmd>BufferLineCyclePrev<CR>", { desc = "Move to left buffer" })
Map({ "n", "t" }, "<C-l>", "<cmd>BufferLineCycleNext<CR>", { desc = "Move to right buffer" })

Map("n", "<leader>y", function()
  vim.fn.setreg("+", vim.fn.expand("%:p"))
  vim.notify("Copied: " .. vim.fn.expand("%:p"))
end, { desc = "Copy file path" })

Map("n", "<leader>p", function() util.grep_file() end, { desc = "File grep" })

Map({ 'n', 'v' }, '<leader>fg', function()
  local text = (Snacks.picker.util.visual() or {}).text or ''
  util.grep_text({ on_show = function() vim.api.nvim_put({ text }, 'c', true, true) end })
end, { desc = 'Fuzzy find' })

Map({ 'n', 'v' }, '<leader>fG', function()
  local text = (Snacks.picker.util.visual() or {}).text or ''
  local grep_persistent_opts = { layout = { preset = "right", layout = { width = 0.3 } }, jump = { close = false }, auto_close = false, format = "filename" }
  util.grep_text(vim.tbl_extend('force', grep_persistent_opts, {
    on_show = function() vim.api.nvim_put({ text }, 'c', true, true) end,
  }))
end, { desc = 'Grep (persistent picker)' })

Map("n", "<leader>ff", function()
  if not root or root == "" then
    root = vim.fn.getcwd()
  end
  require("fyler").open({ root_path = root, kind = "floating" })
end, { desc = "Fyler" })
