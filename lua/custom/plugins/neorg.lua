return {
  {
    'nvim-neorg/neorg',
    config = function()
      require('neorg').setup {
        -- configuration here
        load = {
          ['core.defaults'] = {},
          ['core.dirman'] = {
            config = {
              workspaces = {
                work = '~/notes/work',
                home = '~/notes/home',
                uni = '~/notes/uni',
              },
              default_workspace = 'uni',
            },
          },
          ['core.concealer'] = {},
          ['core.completion'] = {
            config = {
              engine = 'nvim-cmp',
            },
          },
        },
      }

      vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWinEnter' }, {
        pattern = { '*.norg' },
        command = 'set conceallevel=3',
      })
    end,
  },
}
