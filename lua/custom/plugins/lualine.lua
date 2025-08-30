local custom_theme = {
  normal = {
    a = { fg = '#ffffff', bg = '#5f87d7', gui = 'bold' },
    b = { fg = '#ffffff', bg = '#444444' },
    c = { fg = '#d0d0d0', bg = '#303030' },
  },
  insert = {
    a = { fg = '#ffffff', bg = '#5faf5f', gui = 'bold' },
    b = { fg = '#ffffff', bg = '#444444' },
    c = { fg = '#d0d0d0', bg = '#303030' },
  },
  visual = {
    a = { fg = '#ffffff', bg = '#af5fff', gui = 'bold' },
    b = { fg = '#ffffff', bg = '#444444' },
    c = { fg = '#d0d0d0', bg = '#303030' },
  },
  replace = {
    a = { fg = '#ffffff', bg = '#d75f5f', gui = 'bold' },
    b = { fg = '#ffffff', bg = '#444444' },
    c = { fg = '#d0d0d0', bg = '#303030' },
  },
  command = {
    a = { fg = '#ffffff', bg = '#ffaf00', gui = 'bold' },
    b = { fg = '#ffffff', bg = '#444444' },
    c = { fg = '#d0d0d0', bg = '#303030' },
  },
  inactive = {
    a = { fg = '#aaaaaa', bg = '#303030' },
    b = { fg = '#aaaaaa', bg = '#303030' },
    c = { fg = '#aaaaaa', bg = '#303030' },
  },
}

return {
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      options = {
        globalstatus = true,
        icons_enabled = true,
        theme = custom_theme,
        component_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' },
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'branch', 'diff' },
        lualine_c = {
          {
            'filename',
            path = 1, -- ruta relativa
            symbols = { modified = ' ', readonly = ' ' },
          },
        },
        lualine_x = {
          {
            function()
              local rec = vim.fn.reg_recording()
              if rec == '' then
                return ''
              end
              return 'Recording @' .. rec
            end,
            color = { fg = '#ff0000', gui = 'bold' },
          },
          { 'diagnostics', sources = { 'nvim_lsp' } },
          'encoding',
          'fileformat',
          'filetype',
        },
        lualine_y = { 'progress' },
        lualine_z = { 'location' },
      },
    },
  },
}
