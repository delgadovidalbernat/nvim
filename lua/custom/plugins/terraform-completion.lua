local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add {
  gh 'Shougo/deoplete.nvim',
  gh 'neomake/neomake',
  gh 'vim-syntastic/syntastic',
  gh 'hashivim/vim-terraform',
  gh 'juliosueiras/vim-terraform-completion',
}
