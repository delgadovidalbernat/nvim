local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add {
  gh 'MattesGroeger/vim-bookmarks',
  gh 'tom-anders/telescope-vim-bookmarks.nvim',
}

require('telescope').load_extension 'vim_bookmarks'
vim.g.bookmark_save_per_working_dir = 1
vim.g.bookmark_auto_save = 1
vim.api.nvim_set_keymap('n', 'ma', ':Telescope vim_bookmarks<CR>', { noremap = true, silent = true })
