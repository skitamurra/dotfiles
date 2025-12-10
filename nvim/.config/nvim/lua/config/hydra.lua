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
