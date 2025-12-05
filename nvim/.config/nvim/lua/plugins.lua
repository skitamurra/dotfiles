-- ~/.config/nvim/lua/plugins.lua
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local plugins = {
  ---------------------------------------------------------------------------
  -- Syntax / Treesitter
  ---------------------------------------------------------------------------
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter-context",
    },
    config = function()
      require("config.nvim-treesitter")
    end,
  },

  ---------------------------------------------------------------------------
  -- Telescope
  ---------------------------------------------------------------------------
  {
    "nvim-telescope/telescope.nvim",
    event = { "BufReadPost", "BufNewFile" },
    cmd = "Telescope",
    dependencies = { "nvim-lua/plenary.nvim" },
  },

  ---------------------------------------------------------------------------
  -- Basic motion / text objects
  ---------------------------------------------------------------------------
  {
    "rhysd/clever-f.vim",
    event = { "BufReadPost", "BufNewFile" },
  },
  {
    "tpope/vim-surround",
    event = { "BufReadPost", "BufNewFile" },
  },

  ---------------------------------------------------------------------------
  -- LSP / Mason
  ---------------------------------------------------------------------------
  {
    "neovim/nvim-lspconfig",
    config = function()
      require("config.lsp.lsp")
    end,
  },
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    event = "VeryLazy",
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
    event = "VeryLazy",
    opts = {
      ensure_installed = {
        "prettier",
        "eslint_d",
      },
      run_on_start = true,
    },
  },
  {
    "linux-cultist/venv-selector.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
      { "nvim-telescope/telescope.nvim", branch = "0.1.x", dependencies = { "nvim-lua/plenary.nvim" } }, -- optional: you can also use fzf-lua, snacks, mini-pick instead.
    },
    ft = "python", -- Load when opening Python files
    keys = {
      { ",v", "<cmd>VenvSelect<cr>" }, -- Open picker on keymap
    },
    opts = { -- this can be an empty lua table - just showing below for clarity.
        search = {}, -- if you add your own searches, they go here.
        options = {} -- if you add plugin options, they go here.
    },
  },

  ---------------------------------------------------------------------------
  -- Autopairs
  ---------------------------------------------------------------------------
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("config.nvim-autopairs")
    end,
  },

  ---------------------------------------------------------------------------
  -- Completion / Snippets / Icons
  ---------------------------------------------------------------------------
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    config = function()
      require("config.cmp")
    end,
  },
  {
    "hrsh7th/cmp-nvim-lsp",
    event = "InsertEnter",
  },
  {
    "hrsh7th/cmp-buffer",
    event = "InsertEnter",
  },
  {
    "hrsh7th/cmp-path",
    event = "InsertEnter",
  },
  {
    "hrsh7th/cmp-cmdline",
    event = "CmdlineEnter",
  },
  {
    "saadparwaiz1/cmp_luasnip",
    event = "InsertEnter",
  },
  {
    "L3MON4D3/LuaSnip",
    event = "InsertEnter",
  },
  {
    "onsails/lspkind.nvim",
    event = "InsertEnter",
  },

  ---------------------------------------------------------------------------
  -- Colorscheme
  ---------------------------------------------------------------------------
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "moon",
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

  ---------------------------------------------------------------------------
  -- Git
  ---------------------------------------------------------------------------
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

  ---------------------------------------------------------------------------
  -- UI helpers
  ---------------------------------------------------------------------------
  {
    "norcalli/nvim-colorizer.lua",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("colorizer").setup({
        "*",
        css = { rgb_fn = true },
        html = { names = true },
      }, { mode = "background" })
    end,
  },
  {
    "rmagatti/auto-session",
    lazy = false,
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
    event = "VeryLazy",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
      require("bufferline").setup({
        options = {
          mode = "buffers",
          numbers = "none",
          separator_style = { "/", "/" },
          show_buffer_close_icons = false,
          offsets = {
            { filetype = "NvimTree" },
          },
        },
      })
    end,
  },
  {
    "RRethy/vim-illuminate",
    event = { "BufReadPost", "BufNewFile" },
  },
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    cmd = { "ToggleTerm" },
    opts = function()
      return {
        direction = "float",
        float_opts = { border = "curved" },
        start_in_insert = true,
      }
    end,
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "md" },
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
    event = "VeryLazy",
    config = function()
      require("tint").setup({
        tint = -80,
      })
    end,
  },
  {
    "dstein64/vim-startuptime",
    cmd = "StartupTime",
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      require("which-key").setup({
        preset = "modern",
        win = {
          no_overlap = true,
          border = "single",
          padding = { 0, 1 },
          title = false,
        },
        layout = {
          width = { min = 18, max = 30 },
          spacing = 2,
        },
      })
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    event = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("config.lualine")
    end,
  },

  ---------------------------------------------------------------------------
  -- LSP UI / Namu
  ---------------------------------------------------------------------------
  {
    "nvimdev/lspsaga.nvim",
    event = "LspAttach",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("lspsaga").setup({
        lightbulb = {
          enable = false
        }
      })
    end,
  },
  {
    "bassamsdata/namu.nvim",
    cmd = { "Namu", "NamuSymbols" },
    opts = {
      global = {},
      namu_symbols = {
        options = {},
      },
    },
  },

  ---------------------------------------------------------------------------
  -- Diff / Hop / Git UI
  ---------------------------------------------------------------------------
  {
    "sindrets/diffview.nvim",
    cmd = {
      "DiffviewOpen",
      "DiffviewClose",
      "DiffviewToggleFiles",
      "DiffviewFocusFiles",
    },
  },
  {
    "phaazon/hop.nvim",
    branch = "v2",
    cmd = { "HopWord" },
    config = function()
      require("hop").setup({
        multi_windows = true,
      })
    end,
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
    dependencies = { "nvim-lua/plenary.nvim" },
  },

  ---------------------------------------------------------------------------
  -- Dev helpers
  ---------------------------------------------------------------------------
  {
    "folke/neodev.nvim",
    event = "VeryLazy",
  },
  {
    "nvim-flutter/flutter-tools.nvim",
    lazy = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "stevearc/dressing.nvim",
    },
    config = true,
  },
  {
    "A7Lavinraj/fyler.nvim",
    dependencies = { "nvim-mini/mini.icons" },
    branch = "stable",
    lazy = false,
    opts = function()
      return require("config.fyler")
    end,
  },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {},
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
  },
  {
    "max397574/better-escape.nvim",
    event = { "BufReadPre", "BufWritePre", "BufNewFile" },
    opts = {
      timeout = 130,
      default_mappings = false,
      mappings = {
        i = { j = { j = "<ESC>" } },
        t = { j = { k = "<C-\\><C-n>" } },
      },
    },
  },
  {
    "karb94/neoscroll.nvim",
    event = { "BufWinEnter", "WinScrolled" },
    config = function()
      require("neoscroll").setup()
    end,
  },
  {
    "shellRaining/hlchunk.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("hlchunk").setup({
        indent = {
          enable = true,
        },
      })
    end,
  },
}

require("lazy").setup(plugins)
