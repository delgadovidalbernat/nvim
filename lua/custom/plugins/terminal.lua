local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add {
  { src = gh 'akinsho/toggleterm.nvim', version = vim.version.range '*' },
}

require('toggleterm').setup {
  open_mapping = [[<c-t>]],
  start_in_insert = true,
  insert_mappings = true, -- whether or not the open mapping applies in insert mode
  terminal_mappings = true, -- whether or not the open mapping applies in the opened terminals
  persist_size = true,
  persist_mode = true, -- if set to true (default) the previous terminal mode will be remembered
  direction = 'float',
  close_on_exit = true, -- close the terminal window when the process exits
  shell = vim.o.shell, -- change the default shell
  auto_scroll = true, -- automatically scroll to the bottom on terminal output
  float_opts = {
    border = 'curved',
  },
  winbar = {
    enabled = false,
    name_formatter = function(term) --  term: Terminal
      return term.name
    end,
  },
}
