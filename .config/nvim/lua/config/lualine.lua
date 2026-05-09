-- lua/config/lualine
local lualine = require('lualine')
vim.api.nvim_set_hl(0, 'StatusLine', { bg = 'NONE' })
vim.api.nvim_set_hl(0, 'StatusLineNC', { bg = 'NONE' })

local colors = {
  yellow   = '#ECBE7B',
  cyan     = '#008080',
  green    = '#98be65',
  orange   = '#FF8800',
  violet   = '#a9a1e1',
  magenta  = '#c678dd',
  red      = '#ec5f67',
}

local conditions = {
  buffer_not_empty = function()
    return vim.fn.empty(vim.fn.expand('%:t')) ~= 1
  end,
  hide_in_width = function()
    return vim.fn.winwidth(0) > 80
  end,
  check_git_workspace = function()
    local filepath = vim.fn.expand('%:p:h')
    local gitdir = vim.fn.finddir('.git', filepath .. ';')
    return gitdir and #gitdir > 0 and #gitdir < #filepath
  end,
}

local config = {
  options = {
    component_separators = '',
    section_separators = '',
    theme = { normal = {} },
  },
  sections = {
    lualine_a = {{
      'branch',
      icon = '',
      color = { fg = colors.violet, gui = 'bold' },
      cond = conditions.buffer_not_empty,
    }},
    lualine_b = {{
      function()
        local fullpath = vim.fn.expand("%:p")
        local relpath = vim.fn.expand("%:.")
        local git_root = require("config.util").get_git_root()
        if vim.v.shell_error ~= 0 or not git_root or git_root == "" then
          return relpath
        end
        local src_root = git_root .. "/src/"
        if fullpath:sub(1, #src_root) == src_root then
          return fullpath:sub(#src_root + 1)
        end
        return relpath
      end,
      icon = ' ',
      color = { fg = colors.magenta, gui = 'bold' },
      cond = conditions.buffer_not_empty,
      path = 1,
    }},
    lualine_c = {},
    lualine_y = {},
    lualine_z = {},
    lualine_x = {},
  },
}

local function ins_left(component)
  table.insert(config.sections.lualine_c, component)
end

ins_left {
  'diagnostics',
  sources = { 'nvim_diagnostic' },
  symbols = { error = ' ', warn = ' ', info = ' ' },
  diagnostics_color = {
    error = { fg = colors.red },
    warn = { fg = colors.yellow },
    info = { fg = colors.cyan },
  },
}

ins_left {
  'diff',
  symbols = { added = ' ', modified = '󰝤 ', removed = ' ' },
  diff_color = {
    added = { fg = colors.green },
    modified = { fg = colors.orange },
    removed = { fg = colors.red },
  },
  cond = conditions.hide_in_width,
}

ins_left {
  'progress',
  icon = '󱨶 ',
  color = { fg = colors.cyan, gui = 'bold' },
  cond = conditions.buffer_not_empty,
}

ins_left {
  function()
    local msg = ''
    local buf_ft = vim.api.nvim_get_option_value('filetype', { buf = 0 })
    local clients = vim.lsp.get_clients()
    if next(clients) == nil then
      return msg
    end
    for _, client in ipairs(clients) do
      local filetypes = client.config.filetypes
      if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 and client.name ~= "null-ls" then
        return client.name:match("([^_]+)")
      end
    end
    return msg
  end,
  icon = ' ',
  color = { fg = colors.violet, gui = 'bold' },
}

lualine.setup(config)
