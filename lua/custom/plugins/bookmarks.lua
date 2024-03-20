return {
  {
    'tom-anders/telescope-vim-bookmarks.nvim',
    dependencies = 'MattesGroeger/vim-bookmarks',
    config = function()
      require('telescope').load_extension('vim_bookmarks')
      vim.g.bookmark_save_per_working_dir = 1
      vim.g.bookmark_auto_save = 1
      require('telescope').extensions.vim_bookmarks.all {
        vim.api.nvim_set_keymap('n', 'ma', ':Telescope vim_bookmarks<CR>', { noremap = true, silent = true })
      }
    end
  }
}
