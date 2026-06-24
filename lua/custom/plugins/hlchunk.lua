local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add {
  gh 'shellRaining/hlchunk.nvim',
}

require('hlchunk').setup {
  chunk = {
    enable = true,
    priority = 15,
    style = {
      { fg = '#806d9c' },
      { fg = '#c21f30' },
    },
    use_treesitter = true,
    chars = {
      horizontal_line = '─',
      vertical_line = '│',
      left_top = '╭',
      left_bottom = '╰',
      right_arrow = '>',
    },
    textobject = '',
    max_file_size = 1024 * 1024,
    error_sign = true,
    duration = 100,
    delay = 100,
  },
  indent = {
    enable = true, -- si quieres también el marcado de indentación
  },
}
