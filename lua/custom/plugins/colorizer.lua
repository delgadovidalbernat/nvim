local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add {
  gh 'norcalli/nvim-colorizer.lua',
}

require('colorizer').setup()
