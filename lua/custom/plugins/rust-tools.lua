
return {
  {
    -- Must install rust and rust-src
    'simrat39/rust-tools.nvim',
    dependencies = 'neovim/nvim-lspconfig',
    config = function ()
      require("rust-tools").setup({
        server = {
          capabilities = require("cmp_nvim_lsp").default_capabilities(),
          on_attach = function (_, bufnr)
            vim.keymap.set("n", "<C-a>", require("rust-tools").hover_actions.hover_actions, {buffer = bufnr})
            vim.keymap.set("n", "<Leader>a", require("rust-tools").code_action_group.code_action_group, {buffer = bufnr})
          end,
        },
        tools = {
          hover_actions = {
            auto_focus = true;
          },
        },
      })
    end
  }
}
