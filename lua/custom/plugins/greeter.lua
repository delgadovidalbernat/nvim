return {
  {
    'goolord/alpha-nvim',
    config = function()
      require 'alpha'.setup(require 'custom.config.greeter-config'.config)
    end
  }
}
