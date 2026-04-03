return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    -- Use auto theme (inherits monokai-pro), fall back to ayu_dark
    local theme = 'auto'
    local ok, _ = pcall(require, 'lualine.themes.monokai-pro')
    if not ok then
      theme = 'ayu_dark'
    end

    require('lualine').setup {
      options = {
        theme = theme,
        section_separators = { left = '', right = '' },
        component_separators = { left = '', right = '' },
        globalstatus = true,
        disabled_filetypes = {
          statusline = {},
          winbar = {},
        },
      },
      sections = {
        lualine_a = { { 'mode', separator = { left = '' }, right_padding = 2 } },
        lualine_b = {
          { 'branch', icon = '' },
          {
            'diff',
            symbols = { added = ' ', modified = ' ', removed = ' ' },
          },
          'diagnostics',
        },
        lualine_c = {
          { 'filename', path = 1, symbols = { modified = ' ●', readonly = ' ', unnamed = '[No Name]' } },
        },
        lualine_x = {
          'encoding',
          { 'fileformat', symbols = { unix = '', dos = '', mac = '' } },
          'filetype',
        },
        lualine_y = { 'progress' },
        lualine_z = { { 'location', separator = { right = '' }, left_padding = 2 } },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { { 'filename', path = 1 } },
        lualine_x = { 'location' },
        lualine_y = {},
        lualine_z = {},
      },
      extensions = { 'neo-tree', 'lazy' },
    }
  end,
}
