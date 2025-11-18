-- ~/.config/nvim/lua/plugins.lua

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

require("lazy").setup({
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
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("config.nvim-telescope")
    end
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
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    opts = {
      ui = { border = "rounded" },
      PATH = "prepend",
    },
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = { "pyright", "vtsls", "lua_ls" },
      automatic_installation = true,
    },
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = {
        "prettier",
        "eslint_d",
      },
      run_on_start = true,
    },
  },
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("config.nvim-autopairs")
    end
  },
  -- 自動補完系
  {
    "hrsh7th/nvim-cmp",
    config = function()
      require("config.cmp")
    end
  },
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
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "moon",       -- "night", "day", "moon"
      transparent = true,
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
  -- { 
  --   "EdenEast/nightfox.nvim",
  --   config = function()
  --     vim.cmd.colorscheme("nightfox")
  --   end,
  -- },
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("gitsigns").setup({
        current_line_blame = true,
        current_line_blame_opts = { delay = 250, virt_text_pos = "eol" },
      })
    end,
  },
  {
    "norcalli/nvim-colorizer.lua",
    config = function()
      require("colorizer").setup({
        "*";
        css = { rgb_fn = true };
        html = { names = true };
      }, { mode = "background" })
    end
  },
  {
    "rmagatti/auto-session",
    config = function()
      require("auto-session").setup({
        enable = true,
        auto_save = true,
        auto_restore = true,
        auto_create = true,
      })
    end,
  },
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
      -- local function to_hex(n) return n and string.format("#%06x", n) or nil end
      -- local function hl(name)
      --   local ok, h = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
      --   return ok and h or {}
      -- end
      -- local TabLineSel   = hl("TabLineSel")
      -- local bg_selected  = to_hex(TabLineSel.bg or StatusLine.bg or Normal.bg)

      require("bufferline").setup {
        options = {
          mode = "buffers",
          numbers = "none",
          separator_style = { "/", "/" },
          show_buffer_close_icons = false,
          offsets = {
            { filetype = "NvimTree" },
          },
        },
        --highlights = {
        -- buffer_selected = { bg = bg_selected,  bold = true, italic = false },
        --},
      }
      local keymap = vim.keymap.set
      local opts = { silent = true, noremap = true }
      keymap("n", "<leader>h", "<cmd>BufferLineCyclePrev<CR>", opts)
      keymap("n", "<leader>l", "<cmd>BufferLineCycleNext<CR>", opts)
      keymap("n", "<leader>w", "<cmd>bdelete<CR>", opts)
    end,
  },
  { 'echasnovski/mini.cursorword',
    version = '*',
    config = function()
      require("mini.cursorword").setup()
    end
  },
  {
    "nvimdev/indentmini.nvim",
    config = function()
      require("indentmini").setup({
        exclude = { "markdown" }
      })
    end
  },
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    opts = {
      direction = "float",
      float_opts = { border = "curved" },
      start_in_insert = true,
      open_mapping = [[<C-\>]],
    },
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
      heading = {
        width = "block",
        left_pad = 0,
        right_pad = 4,
        icons = {},
      },
      code = {
        width = "block",
      },
    },
  },
  {
    "levouh/tint.nvim",
    config = function()
      require("tint").setup({
        tint = -80
      })
    end
  },
  {
    "dstein64/vim-startuptime"
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer Local Keymaps (which-key)",
      },
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require("lualine").setup()
    end
  },
  { "simeji/winresizer" },
  {
    'nvimdev/lspsaga.nvim',
    config = function()
        require('lspsaga').setup({})
    end,
    dependencies = {
        'nvim-treesitter/nvim-treesitter', -- optional
        'nvim-tree/nvim-web-devicons',     -- optional
    },
    "bassamsdata/namu.nvim",
    opts = {
        global = { },
        namu_symbols = {
            options = {},
        },
    },
    vim.keymap.set("n", "<leader>ss", ":Namu symbols<cr>", {
        desc = "Jump to LSP symbol",
        silent = true,
    }),
    vim.keymap.set("n", "<leader>sw", ":Namu workspace<cr>", {
        desc = "LSP Symbols - Workspace",
        silent = true,
    })
  },
  {"sindrets/diffview.nvim"},
  {
    "phaazon/hop.nvim",
    branch = "v2",
    config = function()
      require("hop").setup {
        multi_windows = true,
      }
    end,
    vim.keymap.set("n", "<leader>a", "<cmd>HopWord<CR>", {
        silent = true,
    }),
  },
  {
    "kdheepak/lazygit.nvim",
    lazy = true,
    cmd = {
        "LazyGit",
        "LazyGitConfig",
        "LazyGitCurrentFile",
        "LazyGitFilter",
        "LazyGitFilterCurrentFile",
    },
    -- optional for floating window border decoration
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    -- setting the keybinding for LazyGit with 'keys' is recommended in
    -- order to load the plugin when the command is run for the first time
    keys = {
        { "<leader>g", "<cmd>LazyGit<cr>", desc = "LazyGit" }
    },
  },
  { "simeji/winresizer" },
})

