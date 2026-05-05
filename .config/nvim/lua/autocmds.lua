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

vim.api.nvim_create_autocmd("BufWritePre", {
    group = vim.api.nvim_create_augroup("UserAutoFormat", { clear = true }),
    pattern = { "*.rs" },
    callback = function(ev)
      vim.lsp.buf.format({ buffer = ev.buf, async = false })
    end,
  })
