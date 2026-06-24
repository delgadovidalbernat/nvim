local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add {
  gh 'github/copilot.vim',
}

vim.keymap.set('i', '<C-j>', 'copilot#Accept("\\<CR>")', {
  expr = true,
  replace_keycodes = false,
})
vim.g.copilot_no_tab_map = true
