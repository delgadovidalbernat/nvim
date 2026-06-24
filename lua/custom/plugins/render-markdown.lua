local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add {
  gh 'nvim-treesitter/nvim-treesitter',
  gh 'nvim-mini/mini.nvim',
  gh 'MeanderingProgrammer/render-markdown.nvim',
}

---@module 'render-markdown'
---@type render.md.UserConfig
require('render-markdown').setup {}
