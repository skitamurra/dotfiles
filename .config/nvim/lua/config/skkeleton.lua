vim.api.nvim_create_autocmd('User', {
  pattern = 'skkeleton-initialize-pre',
  callback = function()
    vim.fn['skkeleton#azik#add_table']('us')
    vim.fn['skkeleton#config']({
      kanaTable           = 'azik',
      sources             = { 'skk_server' },
      globalDictionaries  = {
        '~/.config/ibus-skk/abbr.dict',
      },
      userDictionary      = '~/.config/ibus-skk/user.dict.utf8',
      completionRankFile  = '~/.config/ibus-skk/rank.json',
      eggLikeNewline      = true,
    })
  end,
})

vim.keymap.set({ 'i', 'c' }, '<C-j>', '<Plug>(skkeleton-enable)',  { noremap = false })
vim.keymap.set({ 'i', 'c' }, 'L',     '<Plug>(skkeleton-disable)', { noremap = false })
