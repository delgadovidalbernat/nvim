-- return {
--   'zbirenbaum/copilot.lua',
--   cmd = 'Copilot',
--   event = 'InsertEnter',
--   config = function()
--     require('copilot').setup {
--       panel = {
--         enabled = true,
--         auto_refresh = false,
--         keymap = {
--           jump_prev = '[[',
--           jump_next = ']]',
--           accept = '<CR>',
--           refresh = 'gr',
--           open = '<M-CR>',
--         },
--         layout = {
--           position = 'bottom', -- | top | left | right
--           ratio = 0.4,
--         },
--       },
--       suggestion = {
--         enabled = true,
--         auto_trigger = true,
--         debounce = 75,
--         keymap = {
--           accept = '<M-Tab>',
--           accept_word = false,
--           accept_line = false,
--           next = '<M-2>',
--           prev = '<M-1>',
--           dismiss = '<C-]>',
--         },
--       },
--       filetypes = {
--         yaml = false,
--         markdown = false,
--         help = false,
--         gitcommit = false,
--         gitrebase = false,
--         hgcommit = false,
--         svn = false,
--         cvs = false,
--         ['.'] = false,
--       },
--       copilot_node_command = 'node', -- Node.js version must be > 16.x
--       server_opts_overrides = {},
--     }
--   end,
-- }
return {
  'github/copilot.vim',
  config = function()
    vim.keymap.set('i', '<C-j>', 'copilot#Accept("\\<CR>")', {
      expr = true,
      replace_keycodes = false,
    })
    vim.g.copilot_no_tab_map = true
  end,
}
