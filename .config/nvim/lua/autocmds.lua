vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("vim-treesitter-start", {}),
  callback = function()
    pcall(require, "nvim-treesitter")
    pcall(vim.treesitter.start)
  end,
})

vim.api.nvim_create_autocmd("BufRead", {
  callback = function()
    local git_root = require("config.util").get_git_root()
    if git_root then
      vim.cmd("lcd " .. git_root)
    else
      vim.cmd("lcd %:h")
    end
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "help",
  callback = function()
    vim.cmd("wincmd L | :vert resize 80")
  end,
})

vim.api.nvim_create_autocmd('QuitPre', {
  callback = function()
    local current_win = vim.api.nvim_get_current_win()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if win ~= current_win then
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].buftype == '' then
          return
        end
      end
    end
    vim.cmd.only({ bang = true })
  end,
  desc = 'Close all special buffers and quit Neovim',
})

vim.api.nvim_create_autocmd('LspAttach', {
	callback = function()
		vim.lsp.document_color.enable(false)
	end,
})

vim.api.nvim_create_autocmd("LspDetach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client then return end
    vim.schedule(function ()
      for buf in pairs(client.attached_buffers) do
        if buf ~= args.buf and vim.api.nvim_buf_is_loaded(buf) then
          return
        end
      end
      client:stop()
    end)
  end,
})

vim.api.nvim_create_autocmd("TermClose", {
  callback = function()
    local tint = package.loaded.tint
    if not tint then
      return
    end
    vim.schedule(function()
      tint.untint(vim.api.nvim_get_current_win())
    end)
  end,
})
