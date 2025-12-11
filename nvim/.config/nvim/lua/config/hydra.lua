local Hydra = require("hydra")

Hydra({
  name = "Buffer",
  hint = [[ Buffer Mode
 _h_: prev   _l_: next   _w_: close   _q_: quit ]],
  mode = "n",
  body = "<leader>l",
  heads = {
    { "h", function() vim.cmd("BufferLineCyclePrev") end, { desc = "prev" } },
    { "l", function() vim.cmd("BufferLineCycleNext") end, { desc = "next" } },
    { "w", function() vim.cmd("bdelete") end, { desc = "close" } },
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
  heads = {
    { "v", function() vim.cmd("vsplit") end, { desc = "Vertical split" } },
    { "s", function() vim.cmd("split") end, { desc = "Horizontal split" } },
    { "h", function() vim.cmd("wincmd h") end, { desc = "Move left" } },
    { "j", function() vim.cmd("wincmd j") end, { desc = "Move down" } },
    { "k", function() vim.cmd("wincmd k") end, { desc = "Move up" } },
    { "l", function() vim.cmd("wincmd l") end, { desc = "Move right" } },
    { "w", function() vim.cmd("wincmd q") end, { desc = "Close window" } },
    { "o", function() vim.cmd("only") end, { desc = "Close others" } },
    { "q", nil, { exit = true } },
  },
})
