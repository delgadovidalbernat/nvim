return {
  'nvim-neotest/neotest',
  dependencies = {
    'nvim-neotest/nvim-nio',
    'nvim-lua/plenary.nvim',
    'antoinemadec/FixCursorHold.nvim',
    'nvim-treesitter/nvim-treesitter',
    -- Use neotest-golang instead of neotest-go (more reliable)
    'fredrikaverpil/neotest-golang',
    'nvim-neotest/neotest-python',
    'rouge8/neotest-rust',
  },
  keys = {
    -- Run the nearest test
    {
      '<leader>tn',
      '<cmd>lua require("neotest").run.run()<cr>',
      desc = 'Test: Run nearest test',
    },
    -- Run current file tests
    {
      '<leader>tf',
      '<cmd>lua require("neotest").run.run(vim.fn.expand("%"))<cr>',
      desc = 'Test: Run file tests',
    },
    -- Run all tests
    {
      '<leader>ta',
      '<cmd>lua require("neotest").run.run(vim.fn.getcwd())<cr>',
      desc = 'Test: Run all tests',
    },
    -- Toggle test summary
    {
      '<leader>ts',
      '<cmd>lua require("neotest").summary.toggle()<cr>',
      desc = 'Test: Toggle summary',
    },
    -- Show test output
    {
      '<leader>to',
      '<cmd>lua require("neotest").output.open({ enter = true, auto_close = true })<cr>',
      desc = 'Test: Show output',
    },
    -- Stop tests
    {
      '<leader>tS',
      '<cmd>lua require("neotest").run.stop()<cr>',
      desc = 'Test: Stop',
    },
    -- Debug nearest test
    {
      '<leader>td',
      '<cmd>lua require("neotest").run.run({ strategy = "dap" })<cr>',
      desc = 'Test: Debug nearest',
    },
  },
  config = function()
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
      -- Configure adapters
      adapters = {
        require 'neotest-golang' {
          -- Optional: Set go test arguments
          go_test_args = { '-v', '-race', '-count=1' },
          -- Optional: Set DAP configuration (for debugging)
          dap_go_enabled = true,
        },
        require 'neotest-rust' {
          args = { '--no-capture' },
        },
      },
      -- Set icons (optional)
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
  end,
}
