local function gh(repo) return 'https://github.com/' .. repo end

-- [[ Colorscheme ]]
vim.pack.add { gh 'folke/tokyonight.nvim' }

---@diagnostic disable-next-line: missing-fields
require('tokyonight').setup {
  styles = {
    comments = { italic = false }, -- Disable italics in comments
  },
}

vim.o.termguicolors = true
vim.cmd.hi 'Comment gui=none'

-- Keep Neovim's default colorscheme for now.
-- You can still try installed themes with `:Telescope colorscheme` or
-- `:colorscheme tokyonight-night`.
vim.cmd.colorscheme 'default'

-- vim: ts=2 sts=2 sw=2 et
