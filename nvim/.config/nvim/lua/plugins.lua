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

local opts = {
  defaults = { lazy = true },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
        "editorconfig",
        "man",
        "osc52",
        "spellfile",
      },
    },
  },
}

local plugins = {
  ---------------------------------------------------------------------------
  -- Syntax / Treesitter
  ---------------------------------------------------------------------------
  "nvim-treesitter/nvim-treesitter-context",
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("config.nvim-treesitter")
    end,
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
    event = { "BufReadPre", "BufNewFile" },
  },
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    build = ":MasonUpdate",
    opts = {
      ui = { border = "rounded" },
      PATH = "prepend",
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
    config = function()
      require("tokyonight").setup({
        style = "moon",
        transparent = true,
        terminal_colors = true,
        styles = {
          sidebars = "transparent",
          floats = "transparent",
        },
        dim_inactive = true,
        cache = true,
      })
      vim.cmd.colorscheme("tokyonight")
    end,
  },

  ---------------------------------------------------------------------------
  -- Git
  ---------------------------------------------------------------------------
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
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
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {
      options = { "buffers", "curdir", "tabpages", "winsize" },
    },
  },
  "nvim-tree/nvim-web-devicons",
  {
    "akinsho/bufferline.nvim",
    version = "*",
    event = "VeryLazy",
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
          custom_filter = function(buf)
            return vim.bo[buf].filetype ~= "help"
          end,
        },
      })
    end,
  },
  {
    "RRethy/vim-illuminate",
    event = { "BufReadPost", "BufNewFile" },
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
    event = { "BufReadPost", "BufNewFile" },
    opts = { tint = -55}
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
    event = "VeryLazy",
    config = function()
      require("config.lualine")
    end,
  },

  ---------------------------------------------------------------------------
  -- LSP UI / Namu
  ---------------------------------------------------------------------------
  -- {
  --   "nvimdev/lspsaga.nvim",
  --   event = "LspAttach",
  --   opts = {}
  -- },
  -- {
  --   "bassamsdata/namu.nvim",
  --   cmd = { "Namu", "NamuSymbols" },
  --   opts = {
  --     global = {},
  --     namu_symbols = {
  --       options = {},
  --     },
  --   },
  -- },

  ---------------------------------------------------------------------------
  -- Diff / Hop / Git UI
  ---------------------------------------------------------------------------
  {
    "sindrets/diffview.nvim",
    cmd = {
      "DiffviewOpen",
    },
  },
  {
    "folke/flash.nvim",
  },
  {
    "kdheepak/lazygit.nvim",
    cmd = {
      "LazyGit",
    },
  },

  ---------------------------------------------------------------------------
  -- Dev helpers
  ---------------------------------------------------------------------------
  {
    "folke/neodev.nvim",
    event = "VeryLazy",
  },
  "stevearc/dressing.nvim",
  {
    "nvim-flutter/flutter-tools.nvim",
    ft = { "dart" },
    config = true,
  },
  "nvim-mini/mini.icons",
  {
    "A7Lavinraj/fyler.nvim",
    branch = "stable",
    cmd = { "Fyler" },
    opts = function()
      return require("config.fyler")
    end,
  },
  "MunifTanjim/nui.nvim",
  "rcarriga/nvim-notify",
  {
    "folke/noice.nvim",
    event = "VeryLazy",
      opts = {
        presets = {
          lsp_doc_border = true,
        },
        views = {
        cmdline_popup = {
          position = {
            row = "50%",
            col = "50%",
          },
          size = {
            width = 60,
            height = "auto",
          },
        },
        popupmenu = {
          relative = "editor",
          position = {
            row = 27,
            col = "50%",
          },
          size = {
            width = 60,
            height = 10,
          },
          border = {
            style = "rounded",
            padding = { 0, 1 },
          },
          win_options = {
            winhighlight = { Normal = "Normal", FloatBorder = "DiagnosticInfo" },
          },
        },
      },
    },
  },
  {
    "max397574/better-escape.nvim",
    lazy = false,
    opts = {
      timeout = 150,
      default_mappings = false,
      mappings = {
        i = { j = { k = "<ESC>" } },
        t = { k = { l = "<C-\\><C-n>" } },
        c = { j = { k = "<ESC>" } },
      },
    },
  },
  {
    "nvimtools/hydra.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("config.hydra")
    end
  },
  {
    "folke/trouble.nvim",
    opts = {},
    cmd = "Trouble",
  },
  {
    "folke/snacks.nvim",
    lazy = false,
    config = function ()
      require("config.snacks")
    end,
  },
  {
    "potamides/pantran.nvim",
    cmd = "Pantran",
    config = function()
      require("config.pantran")
    end,
  },
  "vim-jp/vimdoc-ja",
  {
    "shortcuts/no-neck-pain.nvim",
    event = { "BufReadPre", "BufNewFile" },
  },
  {
    "ysmb-wtsg/in-and-out.nvim",
    event = { "BufReadPre", "BufNewFile" },
  },
  {
    'nacro90/numb.nvim',
    event = { "BufReadPre", "BufNewFile" },
    opts = {},
  },
  {
    'saecki/crates.nvim',
    event = { "BufRead Cargo.toml" },
    tag = 'stable',
    config = function()
        require('crates').setup()
    end,
  },
}

require("lazy").setup(plugins, opts)
