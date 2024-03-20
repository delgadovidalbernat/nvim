return {
  {
    requires = {
      'nvim-telescope/telescope.nvim',
      'nvim-lua/popup.nvim',
      'nvim-lua/plenary.nvim',
    },
    'nvim-telescope/telescope-media-files.nvim',
    config = function()
      require('telescope').setup {
        extensions = {
          media_files = {
            filetypes = { 'png', 'webp', 'jpg', 'jpeg', 'pdf' },
            find_cmd = 'rg' -- find command (defaults to `fd`)
          }
        },
        pcall(require('telescope').load_extension, 'media_files')
      }
    end,
  },
}
