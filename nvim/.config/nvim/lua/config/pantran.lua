require("pantran").setup({
  default_engine = "google",
  engines = {
    google = {
      fallback = {
        default_source = "en",
        default_target = "ja",
      },
      -- NOTE: must set `DEEPL_AUTH_KEY` env-var
      -- deepl = {
      --   default_source = "",
      --   default_target = "",
      -- },
    },
  },
  ui = {
    width_percentage = 0.7,
    height_percentage = 0.7,
  },
  window = {
    title_border = { " ", " " }, -- for google
    window_config = { border = "rounded" },
  },
  controls = {
    mappings = { -- Help Popup order cannot be changed
      edit = {
        -- normal mode mappings
        n = {
          -- ["j"] = "gj",
          -- ["k"] = "gk",
          ["S"] = require("pantran.ui.actions").switch_languages,
          ["e"] = require("pantran.ui.actions").select_engine,
          ["s"] = require("pantran.ui.actions").select_source,
          ["t"] = require("pantran.ui.actions").select_target,
          ["<C-y>"] = require("pantran.ui.actions").yank_close_translation,
          ["g?"] = require("pantran.ui.actions").help,
          --disable default mappings
          ["<C-Q>"] = false,
          ["gA"] = false,
          ["gS"] = false,
          ["gR"] = false,
          ["ga"] = false,
          ["ge"] = false,
          ["gr"] = false,
          ["gs"] = false,
          ["gt"] = false,
          ["gY"] = false,
          ["gy"] = false,
        },
        -- insert mode mappings
        i = {
          ["<C-y>"] = require("pantran.ui.actions").yank_close_translation,
          ["<C-t>"] = require("pantran.ui.actions").select_target,
          ["<C-s>"] = require("pantran.ui.actions").select_source,
          ["<C-e>"] = require("pantran.ui.actions").select_engine,
          ["<C-S>"] = require("pantran.ui.actions").switch_languages,
        },
      },
      -- Keybindings here are used in the selection window.
      select = {},
    },
  },
})
