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
        "osc52",
        "spellfile",
      },
    },
  },
}

local plugins = {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = { "BufReadPre", "BufNewFile" },
    config = function ()
      require("treesitter-context").setup({
        enable = true,
        max_lines = 2,
        trim_scope = "inner",
        mode = "cursor",
        separator = nil,
      })
    end
  },
  "L3MON4D3/LuaSnip",
  {
    "saghen/blink.cmp",
    version = "*",
    build = "cargo build --release",
    event = { "InsertEnter", "CmdLineEnter" },
    opts = {
      keymap = {
        preset = "super-tab",
      },
      sources = {
        default = { "snippets", "lsp", "path", "buffer" },
      },
      snippets = { preset = "luasnip" },
      completion = {
        menu = { border = 'single' },
        documentation = { window = { border = 'single' } },
      },
      signature = { window = { border = 'single' } },
    },
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
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    config = function()
      require("config.lualine")
    end,
  },
  {
    "akinsho/bufferline.nvim",
    event = "BufReadPre",
    config = function()
      require("bufferline").setup({
        options = {
          mode = "buffers",
          numbers = "none",
          separator_style = { "/", "/" },
          show_buffer_close_icons = false,
          custom_filter = function(buf)
            return vim.bo[buf].filetype ~= "help"
          end,
        },
      })
    end,
  },
  {
    "A7Lavinraj/fyler.nvim",
    cmd = { "Fyler" },
    config = function()
      require("config.fyler")
    end,
  },
  "nvim-lua/plenary.nvim",
  {
    "kdheepak/lazygit.nvim",
    cmd = { "LazyGit" },
  },
  {
    "justinmk/guh.nvim",
    cmd = { "Guh"}
  },
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
        on_highlights = function(hl, c)
          hl.LineNr = { fg = c.dark5 }
          hl.LineNrAbove = { fg = c.dark5 }
          hl.LineNrBelow = { fg = c.dark5 }
        end,
      })
      vim.cmd.colorscheme("tokyonight")
    end,
  },
  "nvim-tree/nvim-web-devicons",
  {
    "folke/snacks.nvim",
    lazy = false,
    priority = 1000,
    config = function ()
      require("config.snacks")
    end,
  },
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {
      options = { "buffers", "curdir", "tabpages", "winsize" },
    },
  },
  "nvim-mini/mini.icons",
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
  "MunifTanjim/nui.nvim",
  "rcarriga/nvim-notify",
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    config = function()
      require("config.noice")
    end,
  },
  {
    "folke/lazydev.nvim",
    ft = { "lua" },
  },
  "folke/flash.nvim",
  {
    "folke/sidekick.nvim",
    opts = {
      cli = {
        tools = {
          omp = {
            cmd = { "omp" },
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
    "rhysd/clever-f.vim",
    event = { "BufReadPost", "BufNewFile" },
  },
  {
    "tpope/vim-surround",
    event = { "BufReadPost", "BufNewFile" },
  },
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("config.nvim-autopairs")
    end,
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
    "levouh/tint.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = { tint = -55}
  },
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
    "RRethy/vim-illuminate",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("illuminate").configure({
        providers = { "lsp", "regex" },
      })
    end,
  },
  {
    "y3owk1n/undo-glow.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      fallback_for_transparency = { bg = "#222436" },
      highlights = {
        undo = { hl_color = { bg = "#693232" } },
        redo = { hl_color = { bg = "#2F4640" } },
        yank = { hl_color = { bg = "#7A683A" } },
        paste = { hl_color = { bg = "#325B5B" } },
        search = { hl_color = { bg = "#5C475C" } },
        comment = { hl_color = { bg = "#7A5A3D" } },
        cursor = { hl_color = { bg = "#793D54" } },
      },
    },
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "md" },
    opts = {
      latex = { enabled = false },
      heading = {
        width = "block",
        left_pad = 0,
        right_pad = 4,
        icons = {},
      },
      code = {
        disable_background = true,
        highlight_border = false,
        language_border = '-',
      },
    },
  },
  {
    "potamides/pantran.nvim",
    cmd = "Pantran",
    config = function()
      require("config.pantran")
    end,
  },
  {
    'saecki/crates.nvim',
    event = { "BufRead Cargo.toml" },
    tag = 'stable',
    config = function()
        require('crates').setup()
    end,
  },
  {
    "nvim-flutter/flutter-tools.nvim",
    ft = { "dart" },
    config = true,
    opts = {
      root_patterns = { ".git", "pubspec.yaml" },
    }
  },
}

require("lazy").setup(plugins, opts)
