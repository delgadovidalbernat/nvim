local function is_wsl()
  local output = vim.fn.systemlist 'uname -r'
  return output[1] and output[1]:lower():find 'microsoft' ~= nil
end

if is_wsl() then
  local win32yank_path = '/usr/local/bin/win32yank.exe' -- Ajusta esta ruta
  local win32yank_exists = vim.fn.filereadable(win32yank_path) == 1

  if win32yank_exists then
    vim.g.clipboard = {
      name = 'win32yank-wsl',
      copy = {
        ['+'] = win32yank_path .. ' -i --crlf',
        ['*'] = win32yank_path .. ' -i --crlf',
      },
      paste = {
        ['+'] = win32yank_path .. ' -o --lf',
        ['*'] = win32yank_path .. ' -o --lf',
      },
      cache_enabled = 0,
    }
    vim.opt.clipboard = 'unnamedplus'
  else
    print('win32yank.exe not found ' .. win32yank_path)
  end
else
  vim.opt.clipboard = 'unnamedplus'
end
