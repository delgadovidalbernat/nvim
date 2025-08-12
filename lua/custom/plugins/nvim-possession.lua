return {
  'gennaro-tedesco/nvim-possession',
  dependencies = { 'ibhagwan/fzf-lua' },
  config = function()
    local sessions_path = vim.fn.stdpath 'data' .. '/sessions'
    if vim.fn.isdirectory(sessions_path) == 0 then
      vim.fn.mkdir(sessions_path, 'p')
    end

    require('nvim-possession').setup {
      sessions = {
        sessions_path = sessions_path,
        sessions_variable = 'possession_session',
        sessions_icon = '',
        sessions_prompt = 'Sessions > ',
      },

      autoload = false,
      autosave = true,
      autoswitch = {
        enable = false,
        exclude_ft = {},
      },

      save_hook = nil,
      post_hook = nil,

      fzf_hls = {
        normal = 'Normal',
        preview_normal = 'Normal',
        border = 'Todo',
        preview_border = 'Constant',
      },
      fzf_winopts = {
        width = 0.5,
        preview = { vertical = 'right:30%' },
      },

      sort = require('nvim-possession.sorting').alpha_sort,
    }
  end,
  keys = {
    {
      '<leader>sl',
      function()
        require('nvim-possession').list()
      end,
      desc = '📌list sessions',
    },
    {
      '<leader>sn',
      function()
        require('nvim-possession').new()
      end,
      desc = '📌create new session',
    },
    {
      '<leader>su',
      function()
        require('nvim-possession').update()
      end,
      desc = '📌update current session',
    },
    {
      '<leader>sd',
      function()
        require('nvim-possession').delete()
      end,
      desc = '📌delete selected session',
    },
  },
}
