vim.api.nvim_create_autocmd('User', {
  pattern = 'skkeleton-initialize-pre',
  callback = function()
    vim.fn['skkeleton#azik#add_table']('us')
    vim.fn['skkeleton#config']({
      kanaTable = 'azik',
      sources = { 'skk_server', 'user_dictionary', 'global_dictionary' },
      serverHost = 'localhost',
      serverPort = '1178',
      globalDictionaries = {
        { vim.fn.expand("~/.skk/SKK-JISYO.L"),    "euc-jp" },
        { vim.fn.expand("~/.skk/SKK-JISYO.lisp"), "euc-jp" },
      },
      userDictionary = '~/.config/ibus-skk/user.dict.utf8',
      completionRankFile  = '~/.config/ibus-skk/rank.json',
      eggLikeNewline = true,
      keepState = false,
    })
  end,
})
