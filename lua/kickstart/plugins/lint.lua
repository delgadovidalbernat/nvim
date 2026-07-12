local function gh(repo) return 'https://github.com/' .. repo end

-- [[ Linting ]]
vim.pack.add { gh 'mfussenegger/nvim-lint' }

local lint = require 'lint'
lint.linters_by_ft = {
  markdown = { 'markdownlint' },
  -- clojure = { 'clj-kondo' }, -- Disabled: Clojure not in stack
  dockerfile = { 'hadolint' },
  -- inko = { 'inko' },         -- Disabled: Inko not in stack
  -- janet = { 'janet' },       -- Disabled: Janet not in stack
  json = { 'jsonlint' },
  gdscript = { 'gdlint' },
  rst = { 'vale' }, -- vale: prose linter for reStructuredText
  -- ruby = { 'ruby' },         -- Disabled: Ruby not in stack
  terraform = { 'tflint' },
  text = { 'vale' }, -- vale: prose linter for comments and plain text
}

-- To allow other plugins to add linters to require('lint').linters_by_ft,
-- instead set linters_by_ft like this:
-- lint.linters_by_ft = lint.linters_by_ft or {}
-- lint.linters_by_ft['markdown'] = { 'markdownlint' }

-- Create autocommand which carries out the actual linting
-- on the specified events.
local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
  group = lint_augroup,
  callback = function()
    -- Only run the linter in buffers that you can modify in order to
    -- avoid superfluous noise, notably within the handy LSP pop-ups that
    -- describe the hovered symbol using Markdown.
    if vim.bo.modifiable then lint.try_lint() end
  end,
})

-- vim: ts=2 sts=2 sw=2 et
