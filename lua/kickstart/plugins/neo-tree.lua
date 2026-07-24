local function gh(repo) return 'https://github.com/' .. repo end

-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim
vim.pack.add {
  { src = gh 'nvim-neo-tree/neo-tree.nvim', version = vim.version.range '*' },
  gh 'nvim-lua/plenary.nvim',
  gh 'nvim-tree/nvim-web-devicons',
  gh 'MunifTanjim/nui.nvim',
}

vim.keymap.set('n', '\\', '<Cmd>Neotree toggle<CR>', { desc = 'NeoTree toggle', silent = true })
vim.keymap.set('n', '<Tab><Tab>', '<Cmd>Neotree toggle<CR>', { desc = 'NeoTree toggle', silent = true })

require('neo-tree').setup {
  filesystem = {
    filtered_items = {
      hide_dotfiles = true,
      hide_gitignored = true,
      visible = true,
      hide_by_name = {},
      never_show_by_pattern = { '*.uid' },
    },
    window = {
      mappings = {
        ['\\'] = 'close_window',
      },
    },
  },
}

-- vim: ts=2 sts=2 sw=2 et
