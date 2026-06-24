local function gh(repo) return 'https://github.com/' .. repo end

vim.g.barbar_auto_setup = true

vim.pack.add {
  gh 'nvim-tree/nvim-web-devicons',
  { src = gh 'romgrk/barbar.nvim', version = vim.version.range '^1.0.0' },
}

require('barbar').setup {
  animation = true,
}

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
-- Magic buffer-picking mode
map('n', '<C-p>', '<Cmd>BufferPick<CR>', opts)
-- Sort automatically by...
map('n', '<Space>bb', '<Cmd>BufferOrderByBufferNumber<CR>', opts)
map('n', '<Space>bd', '<Cmd>BufferOrderByDirectory<CR>', opts)
map('n', '<Space>bl', '<Cmd>BufferOrderByLanguage<CR>', opts)
map('n', '<Space>bw', '<Cmd>BufferOrderByWindowNumber<CR>', opts)
