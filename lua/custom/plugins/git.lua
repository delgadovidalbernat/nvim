local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add {
  gh 'tpope/vim-rhubarb',
  gh 'tpope/vim-fugitive',
}
