local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add {
  gh 'MunifTanjim/nui.nvim',
  gh 'folke/noice.nvim',
}

require('noice').setup {
  -- add any options here
}
