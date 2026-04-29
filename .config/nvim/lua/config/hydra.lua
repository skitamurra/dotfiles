local Hydra = require("hydra")
local Snacks = require("snacks")

-- After wincmd, if we land on a picker input (insert mode), switch to
-- normal mode so that subsequent Hydra keys are not typed into the search field.
local function smart_wincmd(dir)
  return function()
    vim.cmd("wincmd " .. dir)
    for _, picker in ipairs(Snacks.picker.get()) do
      if picker:is_focused() then
        vim.cmd("stopinsert")
        return
      end
    end
  end
end

-- When Hydra exits, restore picker focus and preview if a picker is open.
-- Must use vim.schedule because on_exit fires during Hydra's exit flow.
local function restore_picker_on_exit()
  vim.schedule(function()
    local pickers = Snacks.picker.get()
    local picker = pickers[#pickers] -- latest picker (sorted by id ascending)
    if not picker or picker.closed then return end

    picker:focus("input", { show = true })
    if picker.layout:is_hidden("preview") then
      picker:toggle("preview", { enable = true })
      vim.schedule(function()
        if not picker.closed then picker:show_preview() end
      end)
    else
      picker:show_preview()
    end
  end)
end

Hydra({
  name = "Buffer",
  hint = [[ Buffer Mode
 _h_: prev   _l_: next   _w_: close   _q_: quit ]],
  mode = "n",
  body = "<leader>l",
  heads = {
    { "h", "<cmd>bprevious<CR>", { desc = "prev" } },
    { "l", "<cmd>bnext<CR>", { desc = "next" } },
    { "w", "<cmd>bdelete<CR>", { desc = "close" } },
    { "q", nil, { exit = true }, },
  },
})

Hydra({
	name = "Scroll",
  hint = [[]],
	mode = "n",
	body = "<leader>j",
	heads = {
		{ "j", "5j" },
		{ "k", "5k" },
		{ "h", "5h" },
		{ "l", "5l" },
    { "q", nil, { exit = true }, },
	},
})

Hydra({
  name = "Window",
  hint = [[ Window Mode
 _v_: vsplit   _s_: split   _h_: left   _j_: down   _k_: up   _l_: right   _w_: close   _o_: only   _q_: quit ]],
  mode = "n",
  body = "<leader>w",
  config = {
    on_exit = restore_picker_on_exit,
  },
  heads = {
    { "v", function() vim.cmd("vsplit") end, { desc = "Vertical split" } },
    { "s", function() vim.cmd("split") end, { desc = "Horizontal split" } },
    { "h", smart_wincmd("h"), { desc = "Move left" } },
    { "j", smart_wincmd("j"), { desc = "Move down" } },
    { "k", smart_wincmd("k"), { desc = "Move up" } },
    { "l", smart_wincmd("l"), { desc = "Move right" } },
    { "w", function() vim.cmd("wincmd q") end, { desc = "Close window" } },
    { "o", function() vim.cmd("only") end, { desc = "Close others" } },
    { "q", nil, { exit = true } },
  },
})
