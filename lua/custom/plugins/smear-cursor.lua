local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add {
  gh 'sphamba/smear-cursor.nvim',
}

require('smear_cursor').setup {
  stiffness = 0.5,
  trailing_stiffness = 0.5,
  matrix_pixel_threshold = 0.5,
}
