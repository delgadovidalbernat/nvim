return {
  'milanglacier/minuet-ai.nvim',
  dependencies = { 'nvim-lua/plenary.nvim' },
  event = 'InsertEnter',
  config = function()
    require('minuet').setup {
      virtualtext = {
        auto_trigger_ft = { 'go', 'lua', 'python', 'sh', 'yaml', 'sql' },
        keymap = {
          accept = '<C-j>',
          accept_line = '<M-a>',
          next = '<M-n>',
          prev = '<M-p>',
        },
      },
      provider = 'openai_fim_compatible',
      provider_options = {
        openai_fim_compatible = {
          api_key = function() return 'ollama' end,
          name = 'Ollama',
          end_point = (function()
            if not handle then return 'http://172.26.32.1:11434/v1/completions' end
            local ip = handle:read '*l'
            handle:close()
            if not ip or ip == '' then return 'http://172.26.32.1:11434/v1/completions' end
            return 'http://' .. ip .. ':11434/v1/completions'
          end)(),
          -- Better quality: qwen2.5-coder:7b if you have VRAM
          -- Fastest: qwen2.5-coder:1.5b-base (current, keep if VRAM is scarce)
          model = 'qwen2.5-coder:7b',
          optional = {
            max_tokens = 128, -- reduced: completions rarely need more
            stop = {
              '<|endoftext|>',
              '<|fim_prefix|>',
              '<|fim_middle|>',
              '<|fim_suffix|>',
              '<|fim_pad|>',
              '<|repo_name|>',
              '<|file_sep|>',
              '<|im_start|>',
              '<|im_end|>',
              '\n\n',
              '\n}',
            },
          },
        },
      },
      -- Smaller context = faster local inference
      context_window = 2500,
      -- Debounce: wait before firing (lower = more responsive feeling)
      debounce = 0,
      -- Throttle: min ms between requests (lower = less blocking)
      throttle = 500,
      n_completions = 1,
    }
  end,
}
