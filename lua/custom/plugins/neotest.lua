local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add {
  gh 'nvim-neotest/nvim-nio',
  gh 'nvim-lua/plenary.nvim',
  gh 'antoinemadec/FixCursorHold.nvim',
  gh 'nvim-treesitter/nvim-treesitter',
  gh 'fredrikaverpil/neotest-golang',
  gh 'nvim-neotest/neotest-python',
  gh 'rouge8/neotest-rust',
  gh 'nvim-neotest/neotest',
}

vim.keymap.set('n', '<leader>tn', '<cmd>lua require("neotest").run.run()<cr>', { desc = 'Test: Run nearest' })
vim.keymap.set('n', '<leader>tf', '<cmd>lua require("neotest").run.run(vim.fn.expand("%"))<cr>', { desc = 'Test: Run file tests' })
vim.keymap.set('n', '<leader>ta', '<cmd>lua require("neotest").run.run(vim.fn.getcwd())<cr>', { desc = 'Test: Run all tests' })
vim.keymap.set('n', '<leader>ts', '<cmd>lua require("neotest").summary.toggle()<cr>', { desc = 'Test: Toggle summary' })
vim.keymap.set('n', '<leader>to', '<cmd>lua require("neotest").output.open({ enter = true, auto_close = true })<cr>', { desc = 'Test: Show output' })
vim.keymap.set('n', '<leader>tS', '<cmd>lua require("neotest").run.stop()<cr>', { desc = 'Test: Stop' })
vim.keymap.set('n', '<leader>td', '<cmd>lua require("neotest").run.run({ strategy = "dap" })<cr>', { desc = 'Test: Debug nearest' })

local neotest_ns = vim.api.nvim_create_namespace 'neotest'
vim.diagnostic.config({
  virtual_text = {
    format = function(diagnostic)
      local message = diagnostic.message:gsub('\n', ' '):gsub('\t', ' '):gsub('%s+', ' '):gsub('^%s+', '')
      return message
    end,
  },
}, neotest_ns)

require('neotest').setup {
  adapters = {
    require 'neotest-golang' {
      go_test_args = { '-v', '-race', '-count=1' },
      dap_go_enabled = true,
      env = {
        CGO_ENABLED = '1',
      },
    },
    require 'neotest-rust' {
      args = { '--no-capture' },
    },
    require 'neotest-python' {
      runner = 'pytest',
    },
  },
  icons = {
    expanded = '▾',
    child_prefix = '├',
    child_indent = '│',
    final_child_prefix = '└',
    non_collapsible = '─',
    collapsed = '▸',
    passed = '✓',
    running = '🗘',
    failed = '✗',
    unknown = '?',
  },
}
