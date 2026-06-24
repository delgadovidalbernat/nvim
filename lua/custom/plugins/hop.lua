local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add {
  { src = gh 'smoka7/hop.nvim', version = 'v2.7.2' },
}

require('hop').setup { keys = 'etovxqpdygfblzhckisuran' }
local hop = require 'hop'
local directions = require('hop.hint').HintDirection
vim.keymap.set('', 'f', function()
  hop.hint_char1 { direction = directions.AFTER_CURSOR, current_line_only = true }
end, { remap = true })
vim.keymap.set('', 'F', function()
  hop.hint_char1 { direction = directions.BEFORE_CURSOR, current_line_only = true }
end, { remap = true })
vim.keymap.set('', 't', function()
  hop.hint_char1 { direction = directions.AFTER_CURSOR, current_line_only = true, hint_offset = -1 }
end, { remap = true })
vim.keymap.set('', 'T', function()
  hop.hint_char1 { direction = directions.BEFORE_CURSOR, current_line_only = true, hint_offset = 1 }
end, { remap = true })
