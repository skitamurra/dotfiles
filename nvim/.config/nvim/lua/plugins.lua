-- ~/.config/nvim/lua/plugins.lua

-- lazy.nvimのパスを設定して存在確認
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- プラグイン一覧
require("lazy").setup({
  "nvim-lualine/lualine.nvim",
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("config.nvim-treesitter")
    end
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-context"
    },
    config = function()
      require("config.nvim-treesitter")
    end
  },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" }
  },
  "rhysd/clever-f.vim",
  "tpope/vim-surround",
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("config.nvim-tree")
    end
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      require("config.lsp")
    end
  },
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("config.nvim-autopairs")
    end
  },

  -- 自動補完系
  { "hrsh7th/nvim-cmp", config = function() require("config.cmp") end },
  { "hrsh7th/cmp-nvim-lsp" },
  { "hrsh7th/cmp-buffer" },
  { "hrsh7th/cmp-path" },
  { "hrsh7th/cmp-cmdline" },
  { "saadparwaiz1/cmp_luasnip" },

  -- スニペット
  { "L3MON4D3/LuaSnip" },

  -- アイコン表示
  { "onsails/lspkind.nvim" },

  {
    "navarasu/onedark.nvim",
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
      require('onedark').setup {
        style = 'darker'
      }
      -- Enable theme
    --require('onedark').load()
    end
  },
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "moon",       -- 他に "night", "day", "moon" がある
      transparent = true,    -- 背景透過
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
    },
    config = function(_, opts)
      require("tokyonight").setup(opts)
      vim.cmd.colorscheme("tokyonight")
    end,
  },
 --  {
 --    "sekke276/dark_flat.nvim",
 --    lazy = false,
 --    priority = 1000,
 --    config = function()
 --      require("dark_flat").setup({
 --        transparent = true, -- 透明背景にしたいなら true
 --        italics = false,      -- 斜体を無効にするなら false
 --        colors = {},         -- カラーの上書き { name = "#RRGGBB", ... }
 --        themes = function(colors)
 --          -- 任意: ハイライトの個別上書き（例）
 --          -- return { Comment = { fg = "#6a6a6a", italic = true } }
 --          return {}
 --        end,
 --      })
 --      vim.cmd.colorscheme("dark_flat")
 --    end,
 --  },
  {
      'MeanderingProgrammer/render-markdown.nvim',
      dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' }, -- if you use the mini.nvim suite
      -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
      -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
      ---@module 'render-markdown'
      ---@type render.md.UserConfig
      opts = {},
  },
})

