return {
  'kndndrj/nvim-dbee',
  dependencies = {
    'MunifTanjim/nui.nvim',
  },
  build = function()
    -- Forzar el uso de Go para instalar el binario
    require('dbee').install 'go'
  end,
  config = function()
    require('dbee').setup(--[[optional config]])
  end,
}
