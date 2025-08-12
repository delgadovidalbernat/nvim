return {
  'ravitemer/mcphub.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
  build = 'bundled_build.lua', -- Bundles `mcp-hub` binary along with the neovim plugin
  config = function()
    require('mcphub').setup {
      use_bundled_binary = true, -- Use local `mcp-hub` binary
      global_env = { 'GITLAB_API_URL', 'GITLAB_PERSONAL_ACCESS_TOKEN' },
    }
  end,
}
