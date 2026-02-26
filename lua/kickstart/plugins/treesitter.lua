return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    build = ':TSUpdate',

    config = function()
      -- 1. SETUP BÁSICO
      require('nvim-treesitter').setup {}

      -- 2. INSTALACIÓN DE PARSERS
      local parsers_to_install = {
        'go',
        'lua',
        'rust',
        'python',
        'vim',
        'vimdoc',
        'query',
        'markdown',
        'markdown_inline',
        'json',
        'bash',
        'yaml',
        'toml',
      }

      require('nvim-treesitter').install(parsers_to_install)

      -- 3. ACTIVAR EL Highlighting
      vim.api.nvim_create_autocmd('FileType', {
        callback = function()
          local ok = pcall(vim.treesitter.start)
          if not ok then
            return
          end
        end,
      })

      -- 4. ACTIVAR INDENTACIÓN
      vim.api.nvim_create_autocmd('FileType', {
        callback = function()
          if vim.b.ts_highlight then
            vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })

      -- 5. ACTIVAR FOLDING
      vim.api.nvim_create_autocmd('FileType', {
        callback = function()
          if vim.b.ts_highlight then
            vim.wo.foldmethod = 'expr'
            vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
            -- Empezar con todo desplegado
            vim.opt.foldlevel = 99
            vim.opt.foldlevelstart = 99
            -- Habilitar capacidad de plegado
            vim.opt.foldenable = true

            -- Mostrar columna de plegado
            vim.opt.foldcolumn = '0'
          end
        end,
      })
    end,
  },
}
