local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add {
  { src = gh 'mrcjkb/rustaceanvim', version = vim.version.range '^6' },
}
