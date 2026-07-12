vim.pack.add { 'https://github.com/Mathijs-Bakker/godotdev.nvim' }

require('godotdev').setup {
  editor_host = '127.0.0.1',
  editor_port = 6005,
  debug_port = 6006,
  formatter = 'gdscript-formatter',
  inline_hints = { enabled = true },
  treesitter = { auto_setup = false },
  run = {
    console = {
      enabled = true,
      renderer = 'buffer',
      buffer = { position = 'bottom', size = 0.3 },
    },
  },
  docs = {
    version = '4.7',
    source_ref = 'master',
    renderer = 'float',
    fallback_renderer = 'browser',
  },
}

require('dap').configurations.gdscript = {
  {
    type = 'godot',
    request = 'launch',
    name = 'Debug Godot project',
    project = '${workspaceFolder}',
    scene = 'main',
  },
}

vim.keymap.set('n', 'gK', '<Cmd>GodotDocs<CR>', { desc = 'Godot class documentation' })

if vim.fn.has 'win32' == 1 and not vim.g.godot_executable then
  vim.g.godot_executable = 'D:/Games/Godot/Engine/Godot_v4.7-stable_win64_console.exe'
end

local function project_root()
  local root = vim.fs.root(0, 'project.godot') or vim.fs.root(vim.uv.cwd(), 'project.godot')
  if not root then error 'No se ha encontrado project.godot' end
  return root
end

local function godot_executable()
  local candidates = { vim.g.godot_executable, vim.env.GODOT_BIN, 'godot4', 'godot' }
  for _, candidate in ipairs(candidates) do
    if candidate and candidate ~= '' and vim.fn.executable(candidate) == 1 then return candidate end
  end
  error 'No se encuentra Godot. Instálalo o configura vim.g.godot_executable/GODOT_BIN'
end

local function gut_runner(root, script)
  local runner = vim.fs.joinpath(root, 'addons', 'gut', script)
  if not vim.uv.fs_stat(runner) then error 'GUT 9 no está instalado en addons/gut para este proyecto' end
  return runner
end

local function current_test_arg()
  local root = project_root()
  local relative = vim.fs.relpath(root, vim.api.nvim_buf_get_name(0))
  if not relative then error 'El fichero actual no pertenece al proyecto Godot' end
  return '-gtest=res://' .. relative:gsub('\\', '/')
end

local function current_test_name()
  for line_number = vim.fn.line '.', 1, -1 do
    local name = vim.fn.getline(line_number):match '^%s*func%s+(test_[%w_]+)%s*%('
    if name then return name end
  end
  error 'No se ha encontrado un test GUT sobre el cursor'
end

local function run_gut(args)
  local root = project_root()
  local runner = gut_runner(root, 'gut_cmdln.gd')
  local command = {
    godot_executable(),
    '--headless',
    '-d',
    '-s',
    '--path',
    root,
    runner,
    '-gexit',
  }
  vim.list_extend(command, args or {})

  vim.cmd 'botright new'
  vim.bo.bufhidden = 'wipe'
  vim.fn.jobstart(command, { cwd = root, term = true })
  vim.cmd 'startinsert'
end

local function debug_gut(args)
  local root = project_root()
  gut_runner(root, 'gut_cmdln.gd')

  local runner = vim.fs.joinpath(root, 'test', 'support', 'gut_debug_runner.tscn')
  if not vim.uv.fs_stat(runner) then error 'Falta res://test/support/gut_debug_runner.tscn' end

  require('dap').run {
    type = 'godot',
    request = 'launch',
    name = 'Debug GUT tests',
    project = root,
    scene = 'res://test/support/gut_debug_runner.tscn',
    playArgs = args or {},
  }
end

vim.api.nvim_create_user_command('GutRun', function(opts) run_gut(opts.fargs) end, {
  nargs = '*',
  desc = 'Ejecutar tests de GUT 9',
})

vim.api.nvim_create_user_command('GutFile', function() run_gut { current_test_arg() } end, {
  desc = 'Ejecutar el fichero de test GUT actual',
})

vim.api.nvim_create_user_command('GutNearest', function()
  run_gut { current_test_arg(), '-gunit_test_name=' .. current_test_name() }
end, { desc = 'Ejecutar el test GUT más cercano' })

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'gdscript',
  callback = function(event)
    vim.keymap.set('n', '<leader>tn', '<Cmd>GutNearest<CR>', {
      buffer = event.buf,
      desc = '[T]est [N]earest (GUT)',
    })
    vim.keymap.set('n', '<leader>tf', '<Cmd>GutFile<CR>', {
      buffer = event.buf,
      desc = '[T]est [F]ile (GUT)',
    })
    vim.keymap.set('n', '<leader>td', function()
      debug_gut { current_test_arg(), '-gunit_test_name=' .. current_test_name() }
    end, {
      buffer = event.buf,
      desc = '[T]est: [D]ebug nearest (GUT)',
    })
  end,
})

-- vim: ts=2 sts=2 sw=2 et
