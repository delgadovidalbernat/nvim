local function gh(repo) return 'https://github.com/' .. repo end

vim.api.nvim_create_autocmd('PackChanged', {
  group = vim.api.nvim_create_augroup('custom-dbee-build', { clear = true }),
  callback = function(ev)
    if ev.data.spec.name == 'nvim-dbee' and (ev.data.kind == 'install' or ev.data.kind == 'update') then
      if not ev.data.active then pcall(vim.cmd.packadd, 'nvim-dbee') end
      local ok, dbee = pcall(require, 'dbee')
      if ok then dbee.install 'go' end
    end
  end,
})

vim.pack.add {
  gh 'MunifTanjim/nui.nvim',
  gh 'kndndrj/nvim-dbee',
}

require('dbee').setup(--[[optional config]])
