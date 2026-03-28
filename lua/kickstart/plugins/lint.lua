-- Linting

---@module 'lazy'
---@type LazySpec
return {
  'mfussenegger/nvim-lint',
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    local lint = require 'lint'
    lint.linters_by_ft = {
      markdown = { 'markdownlint' },
      -- clojure = { 'clj-kondo' }, -- Disabled: Clojure not in stack
      dockerfile = { 'hadolint' },
      -- inko = { 'inko' },         -- Disabled: Inko not in stack
      -- janet = { 'janet' },       -- Disabled: Janet not in stack
      json = { 'jsonlint' },
      rst = { 'vale' }, -- vale: prose linter for reStructuredText
      -- ruby = { 'ruby' },         -- Disabled: Ruby not in stack
      terraform = { 'tflint' },
      text = { 'vale' }, -- vale: prose linter for comments and plain text
    }

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
  end,
}
