local Hydra = require("hydra")
-- local cmd = require("hydra.keymap-util").cmd

Hydra({
  name = "Buffer",
  hint = [[ Buffer Mode
 _h_: prev   _l_: next   _w_: close   _q_: quit ]],
  mode = "n",
  body = "<leader>b",
  heads = {
    { "h", function() vim.cmd("BufferLineCyclePrev") end, { private = false } },
    { "l", function() vim.cmd("BufferLineCycleNext") end, { private = false } },
    { "w", function() vim.cmd("bdelete") end, { private = false } },
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
