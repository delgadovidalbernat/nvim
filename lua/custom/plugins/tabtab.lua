return {
  {
    'romgrk/barbar.nvim',
    dependencies = 'nvim-tree/nvim-web-devicons',
    init = function()
      vim.g.barbar_auto_setup = true
    end,
    opts = {
      -- lazy.nvim will automatically call setup for you. put your options here, anything missing will use the default:
      animation = true,
      -- insert_at_start = true,
      -- …etc.
    },
    version = '^1.0.0', -- optional: only update when a new 1.x version is released
    config = function()
      local map = vim.api.nvim_set_keymap
      local opts = { noremap = true, silent = true }

      -- Move to previous/next
      map('n', '<Space>,', '<Cmd>BufferPrevious<CR>', opts)
      map('n', '<Space>.', '<Cmd>BufferNext<CR>', opts)
      -- Re-order to previous/next
      map('n', '<A-<>', '<Cmd>BufferMovePrevious<CR>', opts)
      map('n', '<A->>', '<Cmd>BufferMoveNext<CR>', opts)
      -- Goto buffer in position...
      map('n', '<Space>1', '<Cmd>BufferGoto 1<CR>', opts)
      map('n', '<Space>2', '<Cmd>BufferGoto 2<CR>', opts)
      map('n', '<Space>3', '<Cmd>BufferGoto 3<CR>', opts)
      map('n', '<Space>4', '<Cmd>BufferGoto 4<CR>', opts)
      map('n', '<Space>5', '<Cmd>BufferGoto 5<CR>', opts)
      map('n', '<Space>6', '<Cmd>BufferGoto 6<CR>', opts)
      map('n', '<Space>7', '<Cmd>BufferGoto 7<CR>', opts)
      map('n', '<Space>8', '<Cmd>BufferGoto 8<CR>', opts)
      map('n', '<Space>9', '<Cmd>BufferGoto 9<CR>', opts)
      map('n', '<Space>0', '<Cmd>BufferLast<CR>', opts)
      -- Pin/unpin buffer
      map('n', '<A-p>', '<Cmd>BufferPin<CR>', opts)
      -- Close buffer
      map('n', '<A-c>', '<Cmd>BufferClose<CR>', opts)
      -- Wipeout buffer
      --                 :BufferWipeout
      -- Close commands
      --                 :BufferCloseAllButCurrent
      --                 :BufferCloseAllButPinned
      --                 :BufferCloseAllButCurrentOrPinned
      --                 :BufferCloseBuffersLeft
      --                 :BufferCloseBuffersRight
      -- Magic buffer-picking mode
      map('n', '<C-p>', '<Cmd>BufferPick<CR>', opts)
      -- Sort automatically by...
      map('n', '<Space>bb', '<Cmd>BufferOrderByBufferNumber<CR>', opts)
      map('n', '<Space>bd', '<Cmd>BufferOrderByDirectory<CR>', opts)
      map('n', '<Space>bl', '<Cmd>BufferOrderByLanguage<CR>', opts)
      map('n', '<Space>bw', '<Cmd>BufferOrderByWindowNumber<CR>', opts)
    end,
  },
}
