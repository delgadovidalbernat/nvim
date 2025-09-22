return {
  {
    'olimorris/codecompanion.nvim',
    cmd = { 'CodeCompanion', 'CodeCompanionChat', 'CodeCompanionActions' },
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
      'j-hui/fidget.nvim', -- Display status (spinner functionality)
      'ravitemer/mcphub.nvim',
      -- Optional but recommended plugins
      {
        'MeanderingProgrammer/render-markdown.nvim',
        ft = { 'markdown', 'codecompanion' },
      },
      {
        'echasnovski/mini.diff',
        config = function()
          local diff = require 'mini.diff'
          diff.setup {
            -- Disabled by default, enable when needed
            source = diff.gen_source.none(),
          }
        end,
      },
      -- Optional: For image pasting support
      {
        'HakonHarnes/img-clip.nvim',
        opts = {
          filetypes = {
            codecompanion = {
              prompt_for_file_name = false,
              template = '[Image]($FILE_PATH)',
              use_absolute_path = true,
            },
          },
        },
      },
      -- Code indexing and search for large projects
      {
        'Davidyz/VectorCode',
        version = '*',
        build = 'pipx upgrade vectorcode',
        dependencies = { 'nvim-lua/plenary.nvim' },
      },
      -- Testing framework
      {
        'echasnovski/mini.test',
        config = true,
      },
    },
    opts = {
      extensions = {
        mcphub = {
          callback = 'mcphub.extensions.codecompanion',
          opts = {
            -- MCP Tools
            make_tools = true, -- Make individual tools (@server__tool) and server groups (@server) from MCP servers
            show_server_tools_in_chat = true, -- Show individual tools in chat completion (when make_tools=true)
            add_mcp_prefix_to_tool_names = false, -- Add mcp__ prefix (e.g `@mcp__github`, `@mcp__neovim__list_issues`)
            show_result_in_chat = true, -- Show tool results directly in chat buffer
            format_tool = nil, -- function(tool_name:string, tool: CodeCompanion.Agent.Tool) : string Function to format tool names to show in the chat buffer
            -- MCP Resources
            make_vars = true, -- Convert MCP resources to #variables for prompts
            -- MCP Prompts
            make_slash_commands = true, -- Add MCP prompts as /slash commands
          },
        },
        vectorcode = {
          vectorcode = {
            opts = {
              tool_group = {
                enabled = true,
                extras = { 'file_search' },
                collapse = false,
              },
              tool_opts = {
                ['*'] = {
                  use_lsp = true,
                  requires_approval = false,
                },
                query = {
                  max_num = { chunk = -1, document = 10 },
                  default_num = { chunk = 50, document = 5 },
                  include_stderr = false,
                  use_lsp = true,
                  no_duplicate = true,
                  chunk_mode = false,
                  summarise = {
                    enabled = false,
                    adapter = nil,
                    query_augmented = true,
                  },
                },
                vectorise = {
                  requires_approval = true,
                },
                ls = {
                  requires_approval = false,
                },
              },
            },
          },
        },
      },
      adapters = {
        tavily = function()
          return require('codecompanion.adapters').extend('tavily', {
            env = {
              api_key = 'cmd:echo $TAVILY_API_KEY',
            },
          })
        end,

        openrouter = function()
          return require('codecompanion.adapters').extend('openai_compatible', {
            env = {
              url = 'https://openrouter.ai/api',
              api_key = 'cmd:echo $OPENROUTER_API_KEY',
              chat_url = '/v1/chat/completions',
            },
            schema = {
              model = {
                default = 'z-ai/glm-4.5',
              },
              temperature = {
                default = 0.7,
              },
              max_tokens = {
                default = 4096,
              },
            },
          })
        end,

        -- Active OpenAI configuration
        openai = function()
          return require('codecompanion.adapters').extend('openai', {
            env = {
              api_key = 'cmd:echo $OPENAI_API_KEY',
            },
            schema = {
              model = {
                default = 'gpt-5',
              },
            },
          })
        end,

        -- Uncomment to use Anthropic Claude
        -- anthropic = function()
        --   return require("codecompanion.adapters").extend("anthropic", {
        --     env = {
        --       api_key = "cmd:echo $ANTHROPIC_API_KEY",
        --     },
        --     schema = {
        --       model = {
        --         default = "claude-3-5-sonnet-20241022", -- or claude-3-opus-20240229
        --       },
        --       extended_thinking = {
        --         default = true,
        --       },
        --     },
        --   })
        -- end,

        ollama = function()
          return require('codecompanion.adapters').extend('ollama', {
            schema = {
              model = {
                default = 'qwen3-coder:latest',
              },
              -- num_ctx = {
              --   default = 16384, -- Context window size
              -- },
              temperature = {
                default = 0,
              },
            },
          })
        end,

        ollamaXL = function()
          return require('codecompanion.adapters').extend('ollama', {
            schema = {
              model = {
                default = 'qwen3-coder8XL:latest',
              },
            },
          })
        end,

        -- Uncomment to use local models with LM Studio or similar
        -- openai_compatible = function()
        --   return require("codecompanion.adapters").extend("openai", {
        --     url = "http://localhost:1234/v1", -- Your local server URL
        --     env = {
        --       api_key = "not-needed", -- Most local servers don't need API keys
        --     },
        --     schema = {
        --       model = {
        --         default = "your-local-model-name", -- e.g., "deepseek-coder-6.7b-instruct"
        --       },
        --     },
        --   })
        -- end,
      },
      strategies = {
        chat = {
          adapter = {
            name = 'openai', -- Change to "anthropic" or "ollama" when using alternatives
            model = 'gpt-5', -- Change to "claude-3-5-sonnet-20241022" or "codellama:latest"
          },
          roles = {
            user = 'Berni', -- Using your preferred name
          },
          tools = {
            file_search = {
              enabled = true,
            },
            grep_search = {
              enabled = true,
            },
            read_file = {
              enabled = true,
            },
            create_file = {
              enabled = true,
            },
            insert_edit_into_file = {
              enabled = true,
            },
            get_changed_files = {
              enabled = true,
            },

            -- Tool groups para workflows complejos
            groups = {
              -- Análisis completo del proyecto
              ['full_analysis'] = {
                description = 'Complete project analysis with structure and code review',
                tools = {
                  'file_search',
                  'grep_search',
                  'read_file',
                  'get_changed_files',
                },
              },

              -- NUEVA: Semantic analysis workflow
              ['semantic_analysis'] = {
                description = 'Advanced semantic code analysis',
                tools = {
                  'vectorcode_query',
                  'grep_search', -- Comparar con búsqueda tradicional
                  'read_file', -- Leer archivos encontrados
                  'vectorcode_files_ls', -- Ver qué está indexado
                },
              },

              -- NUEVO: Git analysis workflow
              ['git_analysis'] = {
                description = 'Git repository analysis and change tracking',
                tools = {
                  'grep_search', -- Search in diffs and commit messages
                  'read_file', -- Read changed files
                  'get_changed_files', -- Get git status
                },
              },

              -- NUEVO: Semantic search workflow
              ['semantic_search'] = {
                description = 'VectorCode semantic search and analysis',
                tools = {
                  'grep_search', -- Traditional search for comparison
                  'read_file', -- Read found files
                  'file_search', -- Find related files
                },
              },

              -- NUEVO: Code review workflow with git
              ['code_review_git'] = {
                description = 'Code review workflow using git context',
                tools = {
                  'get_changed_files', -- Get what changed
                  'read_file', -- Read the changes
                  'grep_search', -- Find related code patterns
                },
              },

              -- NUEVO: Commit analysis
              ['commit_analysis'] = {
                description = 'Analyze commits and suggest improvements',
                tools = {
                  'get_changed_files',
                  'read_file',
                  'grep_search',
                },
              },

              -- NUEVO: Refactoring with git history
              ['refactor_with_history'] = {
                description = 'Refactoring considering git history and impact',
                tools = {
                  'grep_search', -- Find all usages
                  'get_changed_files', -- See what else changed recently
                  'read_file', -- Read implementation
                },
              },

              -- Workflow de desarrollo
              ['dev_workflow'] = {
                description = 'Development and refactoring workflow',
                tools = {
                  'read_file',
                  'create_file',
                  'insert_edit_into_file',
                  'grep_search',
                },
              },

              -- Análisis de seguridad
              ['security_audit'] = {
                description = 'Security-focused code analysis',
                tools = {
                  'grep_search', -- Buscar patrones inseguros
                  'file_search', -- Encontrar archivos críticos
                  'read_file', -- Leer código específico
                },
              },

              -- Refactoring asistido
              ['refactor_assist'] = {
                description = 'Code refactoring and improvement workflow',
                tools = {
                  'grep_search', -- Encontrar todos los usos
                  'read_file', -- Leer implementación actual
                  'insert_edit_into_file', -- Aplicar cambios
                  'get_changed_files', -- Ver qué se modificó
                },
              },

              -- Debugging workflow
              ['debug_workflow'] = {
                description = 'Debugging and error investigation',
                tools = {
                  'grep_search', -- Buscar logs/errores
                  'read_file', -- Leer archivos problemáticos
                  'get_changed_files', -- Ver cambios recientes
                },
              },

              -- Testing workflow
              ['test_workflow'] = {
                description = 'Test creation and analysis',
                tools = {
                  'file_search', -- Encontrar archivos de test
                  'read_file', -- Leer código a testear
                  'create_file', -- Crear nuevos tests
                  'grep_search', -- Buscar patrones de testing
                },
              },

              -- Documentation workflow
              ['docs_workflow'] = {
                description = 'Documentation analysis and creation',
                tools = {
                  'file_search', -- Encontrar docs existentes
                  'read_file', -- Leer código para documentar
                  'create_file', -- Crear nueva documentación
                  'grep_search', -- Buscar comentarios/TODO
                },
              },

              -- Performance analysis
              ['performance_audit'] = {
                description = 'Performance analysis and optimization',
                tools = {
                  'grep_search', -- Buscar hotspots potenciales
                  'read_file', -- Analizar código crítico
                  'file_search', -- Encontrar archivos relacionados
                },
              },
            },
          },
          variables = {
            -- Variables personalizadas para tu workflow
            project_context = {
              description = 'Current project structure and key files',
              callback = function()
                -- Automáticamente incluye estructura del proyecto
                local context = {}
                table.insert(context, '## Project Structure')

                local patterns = {
                  '*.go',
                  '*.rs',
                  '*.js',
                  '*.ts',
                  '*.py',
                  '*.java',
                  '*.cpp',
                  '*.c',
                  '*.h',
                  '*.md',
                  '*.yaml',
                  '*.yml',
                  '*.json',
                  '*.toml',
                  '*.lock',
                  'Dockerfile',
                  'docker-compose.*',
                  'Makefile',
                  '*.mk',
                }

                local find_cmd = 'find . -maxdepth 3 \\( '
                  .. table.concat(
                    vim.tbl_map(function(p)
                      return "-name '" .. p .. "'"
                    end, patterns),
                    ' -o '
                  )
                  .. ' \\) | head -25'
                table.insert(context, vim.fn.system(find_cmd))

                table.insert(context, '\n## VectorCode')
                local has_bin = vim.fn.executable 'vectorcode' == 1
                local index_path = vim.fn.getcwd() .. '/.vectorcode'
                local has_index = vim.fn.isdirectory(index_path) == 1

                if not has_bin then
                  table.insert(context, 'VectorCode not installed. Install with: pipx install vectorcode')
                elseif not has_index then
                  table.insert(context, 'VectorCode installed but no index found.')
                  table.insert(context, 'Create an index with: vectorcode index')
                else
                  table.insert(context, 'VectorCode installed and index detected at: ' .. index_path)
                  -- Show a quick sample of indexed files (non-fatal if command differs)
                  local files = vim.fn.system 'vectorcode files ls 2>/dev/null | head -20'
                  if files and files:gsub('%s+', '') ~= '' then
                    table.insert(context, '\nIndexed files (sample):')
                    table.insert(context, files)
                  end
                  table.insert(context, '\nTip: Use @{vectorcode_query} for semantic search.')
                end

                return table.concat(context, '\n')
              end,
            },
            vector_search = {
              description = 'Semantic search using VectorCode index',
              callback = function()
                -- Check if VectorCode is available
                local has_vectorcode = vim.fn.executable 'vectorcode' == 1
                if not has_vectorcode then
                  return '## VectorCode not available\nInstall with: pipx install vectorcode'
                end

                -- Check if index exists
                local index_path = vim.fn.getcwd() .. '/.vectorcode'
                local has_index = vim.fn.isdirectory(index_path) == 1

                if not has_index then
                  return '## VectorCode index not found\nRun: vectorcode index to create semantic index'
                end

                return '## VectorCode index available\nUse @{vectorcode_query} for semantic search'
              end,
            },

            -- NUEVO: Git context
            git_context = {
              description = 'Git repository context and recent changes',
              callback = function()
                local context = {}

                -- Check if we're in a git repo
                local in_git = vim.fn.system('git rev-parse --is-inside-work-tree 2>/dev/null'):gsub('%s+', '') == 'true'
                if not in_git then
                  return '## Not in a Git repository'
                end

                table.insert(context, '## Git Repository Context')

                -- Current branch
                local branch = vim.fn.system('git branch --show-current 2>/dev/null'):gsub('%s+', '')
                table.insert(context, '**Current branch**: ' .. branch)

                -- Recent commits (last 5)
                table.insert(context, '\n**Recent commits**:')
                local commits = vim.fn.system 'git log --oneline -5 2>/dev/null'
                table.insert(context, commits)

                -- Modified files
                table.insert(context, '**Modified files**:')
                local modified = vim.fn.system 'git status --porcelain 2>/dev/null'
                if modified:gsub('%s+', '') == '' then
                  table.insert(context, 'No modified files')
                else
                  table.insert(context, modified)
                end

                return table.concat(context, '\n')
              end,
            },

            -- NUEVO: Git diff context
            git_diff = {
              description = 'Git diff of current changes',
              callback = function()
                local in_git = vim.fn.system('git rev-parse --is-inside-work-tree 2>/dev/null'):gsub('%s+', '') == 'true'
                if not in_git then
                  return '## Not in a Git repository'
                end

                local context = {}
                table.insert(context, '## Git Diff (Staged + Unstaged)')

                -- Get diff
                local diff = vim.fn.system 'git diff HEAD 2>/dev/null'
                if diff:gsub('%s+', '') == '' then
                  table.insert(context, 'No changes detected')
                else
                  -- Limit diff size for context window
                  local lines = vim.split(diff, '\n')
                  if #lines > 100 then
                    for i = 1, 100 do
                      table.insert(context, lines[i])
                    end
                    table.insert(context, '... (diff truncated)')
                  else
                    table.insert(context, diff)
                  end
                end

                return table.concat(context, '\n')
              end,
            },
          },
          keymaps = {
            send = {
              modes = {
                i = { '<C-CR>', '<C-s>' },
              },
            },
            completion = {
              modes = {
                i = '<C-x>',
              },
            },
          },
          slash_commands = {
            ['buffer'] = {
              keymaps = {
                modes = {
                  i = '<C-b>',
                },
              },
            },
            ['fetch'] = {
              keymaps = {
                modes = {
                  i = '<C-f>',
                },
              },
            },
            ['workspace'] = {
              keymaps = {
                modes = {
                  i = '<C-w>',
                },
              },
              opts = {
                -- Busca workspace files en el directorio actual
                search_dirs = { '.', './docs', './config' },
              },
            },
            ['symbols'] = {
              keymaps = {
                modes = {
                  i = '<C-y>',
                },
              },
            },
            ['help'] = {
              opts = {
                max_lines = 1000,
              },
            },
            -- NEW: Image support
            ['image'] = {
              keymaps = {
                modes = {
                  i = '<C-i>',
                },
              },
              opts = {
                dirs = { '~/Pictures/Screenshots', '~/Downloads' },
              },
            },
          },
        },
        inline = {
          adapter = {
            name = 'ollama', -- Change to "anthropic" or "ollama" when using alternatives
            model = 'qwen3-coder', -- Change to "claude-3-5-sonnet-20241022" or "codellama:latest"
          },
        },
      },
      display = {
        action_palette = {
          provider = 'default',
        },
        chat = {
          show_references = true,
          show_header_separator = true,
          show_settings = false,
          icons = {
            tool_success = '✓ ',
          },
          fold_context = true,
        },
        diff = {
          provider = 'mini_diff',
        },
      },
      opts = {
        log_level = 'INFO', -- Change to DEBUG if you need more verbose logging
      },
      -- Custom prompt library for focused language expertise
      prompt_library = {
        ['Software Expert'] = {
          strategy = 'chat',
          description = 'Expert in Go, Rust, C/C++, JS/TS, Zig, Python, Bash, K8s, Docker',
          opts = {
            index = 1,
            ignore_system_prompt = true,
            intro_message = "Hello! I'm your modern development expert. I specialize in Go, Rust, C/C++, JS/TS, Zig, Python, Bash, and container orchestration. What are you working on?",
          },
          prompts = {
            {
              role = 'system',
              content = [[You are a world-class expert in modern software development specializing in:

**LANGUAGES**: Go (concurrency, interfaces, error handling), Rust (ownership, async, zero-cost abstractions), C/C++ (modern standards, memory management, performance), JavaScript/TypeScript (modern ES, React, Node.js), Zig (comptime, memory control), Python (async, typing, performance), Bash (scripting, automation)

**INFRASTRUCTURE**: Docker/Podman (multi-stage builds, security), Kubernetes (operators, networking, storage), container orchestration, microservices patterns

**FOCUS**: Production-ready, idiomatic code with best practices, performance optimization, security considerations, and proper architecture patterns. Always provide complete, working examples with error handling and modern tooling integration.

User is an experienced engineer who prefers Go, uses Arch Linux + i3 + nvim, and expects expert-level solutions.]],
            },
          },
        },
        ['Security Expert'] = {
          strategy = 'chat',
          description = 'Penetration testing and offensive security specialist',
          opts = {
            index = 2,
            ignore_system_prompt = true,
            intro_message = "Ready for security assessment! I'm your penetration testing and offensive security expert. Let's find vulnerabilities and strengthen defenses through ethical hacking.",
          },
          prompts = {
            {
              role = 'system',
              content = [[You are a penetration testing and offensive security expert specializing in:

**PENETRATION TESTING**: Network reconnaissance, vulnerability scanning, exploitation techniques, post-exploitation, privilege escalation, lateral movement

**WEB APPLICATION SECURITY**: OWASP Top 10, injection attacks, authentication bypasses, session management flaws, client-side attacks, API security testing

**NETWORK SECURITY**: Port scanning, service enumeration, protocol attacks, man-in-the-middle, wireless security, network segmentation testing

**SYSTEM EXPLOITATION**: Buffer overflows, return-oriented programming, heap exploitation, format string bugs, kernel exploits, container escapes

**TOOLS MASTERY**: Metasploit, Burp Suite, nmap, Wireshark, sqlmap, Gobuster, John the Ripper, Hashcat, Bloodhound, Empire, Cobalt Strike

**METHODOLOGIES**: OWASP Testing Guide, NIST SP 800-115, OSSTMM, PTES, Kill Chain analysis, MITRE ATT&CK framework

**EVASION TECHNIQUES**: AV/EDR evasion, payload encoding, living-off-the-land techniques, steganography, traffic obfuscation

**REPORTING**: Risk assessment, remediation strategies, executive summaries, technical findings documentation

This is for educational purposes, CTF challenges, and authorized penetration testing only. Always emphasize proper authorization and ethical guidelines.]],
            },
          },
        },
        ['DevOps Architect'] = {
          strategy = 'chat',
          description = 'Container orchestration and cloud-native infrastructure expert',
          opts = {
            index = 3,
            ignore_system_prompt = true,
            intro_message = "Let's build robust infrastructure! Specialist in Kubernetes, Docker, GitOps, and the entire cloud-native ecosystem. What are we deploying?",
          },
          prompts = {
            {
              role = 'system',
              content = [[You are a DevOps and Platform Engineering expert specializing in:

**CONTAINERS**: Docker/Podman optimization, multi-stage builds, rootless containers, distroless images, security scanning

**KUBERNETES**: Workload management, networking (CNI, service mesh), storage (CSI), security (RBAC, PSA), operators, observability

**PLATFORM ENGINEERING**: GitOps (ArgoCD, Flux), CI/CD pipelines, Infrastructure as Code, secret management, policy as Code

**OBSERVABILITY**: Prometheus, Grafana, logging (ELK, Loki), tracing, SRE practices, alerting, chaos engineering

**CLOUD-NATIVE**: Service mesh, API gateways, message queues, database operators, cost optimization, multi-cluster management

Focus on production-ready configurations, security hardening, monitoring strategies, and modern platform engineering approaches.]],
            },
          },
        },
        ['Performance Engineer'] = {
          strategy = 'chat',
          description = 'Performance optimization specialist across the entire stack',
          opts = {
            index = 4,
            ignore_system_prompt = true,
            intro_message = "Let's optimize for speed! Performance tuning specialist for Go, Rust, C/C++, JS/TS, and containerized systems. What needs to go faster?",
          },
          prompts = {
            {
              role = 'system',
              content = [[You are a performance engineering expert specializing in:

**PROFILING**: Language-specific tools (pprof, perf, flamegraphs), memory analysis, CPU optimization, bottleneck identification

**OPTIMIZATION**: Algorithmic improvements, data structure selection, memory layout, cache optimization, SIMD, concurrency patterns

**SYSTEMS**: Compiler optimization (LTO, PGO), runtime tuning, kernel parameters, container resource optimization

**BENCHMARKING**: Load testing, performance regression detection, continuous profiling, metrics analysis (latency, throughput, resource usage)

**STACK-SPECIFIC**: Go GC tuning, Rust zero-cost abstractions, C++ modern optimizations, JS V8 optimization, container/K8s performance

Always provide measurement-driven optimization with before/after comparisons, profiling methodologies, and production monitoring strategies.]],
            },
          },
        },
        ['Data Engineer'] = {
          strategy = 'chat',
          description = 'Database design, data pipelines and analytics expert',
          opts = {
            index = 5,
            ignore_system_prompt = true,
            intro_message = "Let's work with data! Specialist in databases, ETL pipelines, streaming, and analytics. What data do you need to process or store?",
          },
          prompts = {
            {
              role = 'system',
              content = [[You are a data engineering expert specializing in:

**DATABASES**: PostgreSQL optimization, NoSQL patterns (MongoDB, Redis), time-series (InfluxDB), graph databases

**DATA PIPELINES**: ETL/ELT processes, stream processing (Kafka, NATS), batch processing, data validation

**ANALYTICS**: Data modeling, OLAP vs OLTP, data warehousing, real-time analytics

**PERFORMANCE**: Query optimization, indexing strategies, partitioning, connection pooling

**TOOLS**: SQL optimization, database migrations, backup/recovery, monitoring and observability

Focus on scalable, reliable data solutions with proper schema design, performance optimization, and data integrity.]],
            },
          },
        },
        ['Toxic Programmer'] = {
          strategy = 'chat',
          description = 'Your sarcastic programming buddy with dark humor',
          opts = {
            index = 6,
            ignore_system_prompt = true,
            intro_message = "Oh look, another day of debugging someone else's masterpiece. What fresh hell are we dealing with today?",
          },
          prompts = {
            {
              role = 'system',
              content = [[You are a highly skilled but incredibly sarcastic programmer with a twisted sense of humor. You're technically brilliant but have zero filter and find dark humor in everything coding-related.

**PERSONALITY TRAITS**:
- Expert programmer who knows their stuff but presents it with maximum sarcasm
- Makes dark jokes about code quality, deadlines, and the programming industry
- Uses programming metaphors for life's miseries
- Brutally honest about bad practices but in a funny way
- References classic programming disasters and bugs as comedy material

**COMMUNICATION STYLE**:
- Start responses with sarcastic observations
- Make dark jokes about memory leaks, segfaults, infinite loops as metaphors for life
- Reference programming horror stories and famous bugs
- Use terms like "code graveyard," "legacy nightmare," "technical debt cemetery"
- Make jokes about "suicide commits," "killing processes," "zombie threads"
- Compare bad code to natural disasters or apocalyptic events

**TECHNICAL EXPERTISE**:
- Still provide genuinely helpful, expert-level programming advice
- Back up sarcasm with solid technical knowledge
- Make fun of technologies while explaining them correctly
- Reference real programming pain points everyone understands

**EXAMPLE PHRASES**:
- "Your code has more bugs than a decomposing corpse"
- "Let's debug this trainwreck before it becomes a full disaster"

**BOUNDARIES**:
- Still genuinely helpful underneath the attitude

Remember: You're the toxic but loveable programming buddy who makes coding fun through dark humor while actually being incredibly knowledgeable.]],
            },
          },
        },
        -- NEW: Test workflow automation
        ['Test Workflow'] = {
          strategy = 'workflow',
          description = 'Automated testing workflow for current code',
          opts = {
            index = 7,
          },
          prompts = {
            {
              {
                role = 'user',
                content = 'Analyze the current code and generate comprehensive unit tests with proper mocking and edge cases',
                opts = {
                  auto_submit = false,
                },
              },
            },
            {
              {
                role = 'user',
                content = 'Create integration tests for the main functionality',
                opts = {
                  auto_submit = true,
                },
              },
            },
            {
              {
                role = 'user',
                content = 'Generate benchmark tests for performance-critical functions',
                opts = {
                  auto_submit = true,
                },
              },
            },
          },
        },
      },
    },
    keys = {
      -- Main keybindings
      {
        '<C-a>',
        '<cmd>CodeCompanionActions<CR>',
        desc = 'CodeCompanion: Open action palette',
        mode = { 'n', 'v' },
      },
      {
        '<Leader>a',
        '<cmd>CodeCompanionChat Toggle<CR>',
        desc = 'CodeCompanion: Toggle chat buffer',
        mode = { 'n', 'v' },
      },
      {
        '<LocalLeader>a',
        '<cmd>CodeCompanionChat Add<CR>',
        desc = 'CodeCompanion: Add selection to chat',
        mode = { 'v' },
      },
      -- Additional useful keybindings
      {
        '<Leader>ai',
        '<cmd>CodeCompanion<CR>',
        desc = 'CodeCompanion: Start inline assistant',
        mode = { 'n', 'v' },
      },
      {
        '<Leader>ac',
        '<cmd>CodeCompanionChat<CR>',
        desc = 'CodeCompanion: Start new chat',
        mode = { 'n' },
      },
      {
        '<Leader>agc', -- Git commit analysis
        function()
          vim.cmd 'CodeCompanionChat'
          vim.defer_fn(function()
            local buf = vim.api.nvim_get_current_buf()
            if vim.bo[buf].filetype == 'codecompanion' then
              vim.api.nvim_buf_set_lines(buf, -1, -1, false, {
                '@{commit_analysis} Analyze recent commits and changes',
                '',
                '#{git_context}',
                '',
                '#{git_diff}',
                '',
                'Please analyze:',
                '- Quality of recent commits',
                '- Potential breaking changes',
                '- Code review suggestions',
                '- Impact assessment',
                '- Missing tests or documentation',
              })
              vim.cmd 'startinsert!'
            end
          end, 100)
        end,
        desc = 'CodeCompanion: Git commit analysis',
        mode = { 'n' },
      },
      {
        '<Leader>agd', -- Git diff review
        function()
          vim.cmd 'CodeCompanionChat'
          vim.defer_fn(function()
            local buf = vim.api.nvim_get_current_buf()
            if vim.bo[buf].filetype == 'codecompanion' then
              vim.api.nvim_buf_set_lines(buf, -1, -1, false, {
                '@{code_review_git} Review current git changes',
                '',
                '#{git_diff}',
                '',
                'Review these changes for:',
                '- Code quality and style',
                '- Potential bugs or issues',
                '- Security considerations',
                '- Performance implications',
                '- Test coverage gaps',
                '- Documentation needs',
              })
              vim.cmd 'startinsert!'
            end
          end, 100)
        end,
        desc = 'CodeCompanion: Git diff review',
        mode = { 'n' },
      },
      {
        '<Leader>agh', -- Git history analysis
        function()
          local file_path = vim.fn.expand '%:p'
          vim.cmd 'CodeCompanionChat'
          vim.defer_fn(function()
            local buf = vim.api.nvim_get_current_buf()
            if vim.bo[buf].filetype == 'codecompanion' then
              vim.api.nvim_buf_set_lines(buf, -1, -1, false, {
                '@{git_analysis} Analyze git history for current file',
                '',
                '#{git_context}',
                '',
                'For file: ' .. file_path,
                '',
                'Please analyze:',
                '- File evolution and key changes',
                '- Refactoring opportunities',
                '- Code quality trends',
                '- Frequent modification patterns',
                '- Technical debt indicators',
              })
              vim.cmd 'startinsert!'
            end
          end, 100)
        end,
        desc = 'CodeCompanion: Git history analysis for current file',
        mode = { 'n' },
      },
      {
        '<Leader>avs', -- VectorCode semantic search
        function()
          local search_term = vim.fn.input 'Semantic search query: '
          if search_term ~= '' then
            vim.cmd 'CodeCompanionChat'
            vim.defer_fn(function()
              local buf = vim.api.nvim_get_current_buf()
              if vim.bo[buf].filetype == 'codecompanion' then
                vim.api.nvim_buf_set_lines(buf, -1, -1, false, {
                  '@{semantic_search} Semantic search for: ' .. search_term,
                  '',
                  '#{vector_search}',
                  '',
                  'Search strategy:',
                  '1. Use semantic search to find related concepts',
                  '2. Compare with traditional grep search',
                  '3. Analyze patterns and relationships',
                  '4. Provide code insights based on semantic similarity',
                  '',
                  'Query: "' .. search_term .. '"',
                })
                vim.cmd 'startinsert!'
              end
            end, 100)
          end
        end,
        desc = 'CodeCompanion: VectorCode semantic search',
        mode = { 'n' },
      },
      {
        '<Leader>avi', -- VectorCode index status
        function()
          vim.cmd 'CodeCompanionChat'
          vim.defer_fn(function()
            local buf = vim.api.nvim_get_current_buf()
            if vim.bo[buf].filetype == 'codecompanion' then
              vim.api.nvim_buf_set_lines(buf, -1, -1, false, {
                '#{vector_search}',
                '',
                'Check VectorCode index status and suggest next actions.',
                'If index exists, show what semantic searches are possible.',
                'If not, explain how to create and use the index.',
              })
              vim.cmd 'startinsert!'
            end
          end, 100)
        end,
        desc = 'CodeCompanion: VectorCode index status',
        mode = { 'n' },
      },
      {
        '<Leader>agr', -- Git-aware refactoring
        function()
          local symbol = vim.fn.expand '<cword>'
          vim.cmd 'CodeCompanionChat'
          vim.defer_fn(function()
            local buf = vim.api.nvim_get_current_buf()
            if vim.bo[buf].filetype == 'codecompanion' then
              vim.api.nvim_buf_set_lines(buf, -1, -1, false, {
                '@{refactor_with_history} Git-aware refactoring for: ' .. symbol,
                '',
                '#{git_context}',
                '',
                'Refactor "' .. symbol .. '" considering:',
                '- Recent changes and git history',
                '- Impact on other parts of codebase',
                '- Breaking change implications',
                '- Migration strategy if needed',
                '- Test updates required',
              })
              vim.cmd 'startinsert!'
            end
          end, 100)
        end,
        desc = 'CodeCompanion: Git-aware refactoring',
        mode = { 'n' },
      },
      {
        '<Leader>aw',
        function()
          vim.cmd 'CodeCompanionChat'
          vim.defer_fn(function()
            local buf = vim.api.nvim_get_current_buf()
            if vim.bo[buf].filetype == 'codecompanion' then
              vim.api.nvim_buf_set_lines(buf, -1, -1, false, { '/workspace ' })
              vim.cmd 'startinsert!'
              vim.api.nvim_win_set_cursor(0, { vim.api.nvim_buf_line_count(buf), 11 })
            end
          end, 100)
        end,
        desc = 'CodeCompanion: Start chat with workspace',
        mode = { 'n' },
      },
      {
        '<Leader>as',
        function()
          vim.cmd 'CodeCompanionChat'
          vim.defer_fn(function()
            local buf = vim.api.nvim_get_current_buf()
            if vim.bo[buf].filetype == 'codecompanion' then
              vim.api.nvim_buf_set_lines(buf, -1, -1, false, { '@{grep_search} ' })
              vim.cmd 'startinsert!'
              vim.api.nvim_win_set_cursor(0, { vim.api.nvim_buf_line_count(buf), 15 })
            end
          end, 100)
        end,
        desc = 'CodeCompanion: Start chat with search',
        mode = { 'n' },
      },
      {
        '<Leader>af',
        function()
          vim.cmd 'CodeCompanionChat'
          vim.defer_fn(function()
            local buf = vim.api.nvim_get_current_buf()
            if vim.bo[buf].filetype == 'codecompanion' then
              local current_file = vim.fn.expand '%:t'
              if current_file ~= '' then
                -- Usar el archivo específico y añadir también read_file para asegurar contenido
                vim.api.nvim_buf_set_lines(buf, -1, -1, false, {
                  '#{buffer:' .. current_file .. '}',
                  '@{read_file} ' .. vim.fn.expand '%:p',
                  '',
                  'Analiza este archivo. ¿Qué puedes decirme sobre su estructura y funcionamiento?',
                })
              else
                vim.api.nvim_buf_set_lines(buf, -1, -1, false, {
                  '#{buffer}',
                  '',
                  'Analiza el buffer actual',
                })
              end
              vim.cmd 'startinsert!'
            end
          end, 100)
        end,
        desc = 'CodeCompanion: Chat with current file context',
        mode = { 'n' },
      },
      {
        '<Leader>ap',
        function()
          vim.cmd 'CodeCompanionChat'
          vim.defer_fn(function()
            local buf = vim.api.nvim_get_current_buf()
            if vim.bo[buf].filetype == 'codecompanion' then
              vim.api.nvim_buf_set_lines(buf, -1, -1, false, {
                '@{file_search} main entry points and configs',
                '',
                '#{project_context}',
                '',
                'Analyze this project structure and provide insights about:',
              })
              vim.cmd 'startinsert!'
            end
          end, 100)
        end,
        desc = 'CodeCompanion: Full project analysis',
        mode = { 'n' },
      },
      {
        '<Leader>ar',
        function()
          local visual_selection = ''
          if vim.fn.mode() == 'v' or vim.fn.mode() == 'V' then
            -- Get visual selection
            vim.cmd 'normal! "vy'
            visual_selection = vim.fn.getreg 'v'
          end

          vim.cmd 'CodeCompanionChat'
          vim.defer_fn(function()
            local buf = vim.api.nvim_get_current_buf()
            if vim.bo[buf].filetype == 'codecompanion' then
              local current_file = vim.fn.expand '%:t'
              local prompt_lines = {
                '@{file_search} ' .. current_file,
                '@{read_file} ' .. vim.fn.expand '%:p', -- Usar path completo
                '',
                'Review this file for:',
              }

              if visual_selection ~= '' then
                table.insert(prompt_lines, '')
                table.insert(prompt_lines, 'Focus specifically on this selection:')
                table.insert(prompt_lines, '```')
                vim.list_extend(prompt_lines, vim.split(visual_selection, '\n'))
                table.insert(prompt_lines, '```')
              end

              vim.api.nvim_buf_set_lines(buf, -1, -1, false, prompt_lines)
              vim.cmd 'startinsert!'
            end
          end, 100)
        end,
        desc = 'CodeCompanion: Review current file/selection',
        mode = { 'n', 'v' },
      },
      {
        '<Leader>ag',
        function()
          local search_term = vim.fn.input 'Search in codebase: '
          if search_term ~= '' then
            vim.cmd 'CodeCompanionChat'
            vim.defer_fn(function()
              local buf = vim.api.nvim_get_current_buf()
              if vim.bo[buf].filetype == 'codecompanion' then
                vim.api.nvim_buf_set_lines(buf, -1, -1, false, {
                  '@{grep_search} ' .. search_term,
                  '',
                  'Show me all occurrences and explain the patterns/usage',
                })
                vim.cmd 'startinsert!'
              end
            end, 100)
          end
        end,
        desc = 'CodeCompanion: Grep search in codebase',
        mode = { 'n' },
      },
      -- RAG Workflows Avanzados
      {
        '<Leader>aS', -- Security audit
        function()
          vim.cmd 'CodeCompanionChat'
          vim.defer_fn(function()
            local buf = vim.api.nvim_get_current_buf()
            if vim.bo[buf].filetype == 'codecompanion' then
              vim.api.nvim_buf_set_lines(buf, -1, -1, false, {
                '@{security_audit} Analyze this codebase for security vulnerabilities',
                '',
                'Focus on:',
                '- Input validation and sanitization',
                '- Authentication and authorization flaws',
                '- Injection vulnerabilities',
                '- Insecure dependencies',
                '- Hardcoded secrets or credentials',
                '- File/path traversal risks',
              })
              vim.cmd 'startinsert!'
            end
          end, 100)
        end,
        desc = 'CodeCompanion: Security audit workflow',
        mode = { 'n' },
      },
      {
        '<Leader>aR', -- Refactoring workflow
        function()
          local symbol = vim.fn.expand '<cword>' -- Palabra bajo el cursor
          vim.cmd 'CodeCompanionChat'
          vim.defer_fn(function()
            local buf = vim.api.nvim_get_current_buf()
            if vim.bo[buf].filetype == 'codecompanion' then
              vim.api.nvim_buf_set_lines(buf, -1, -1, false, {
                '@{refactor_assist} Refactor "' .. symbol .. '" in this codebase',
                '',
                'Please:',
                '1. Find all usages of this symbol',
                '2. Analyze the current implementation',
                '3. Suggest improvements (naming, structure, patterns)',
                '4. Show refactored version with rationale',
              })
              vim.cmd 'startinsert!'
            end
          end, 100)
        end,
        desc = 'CodeCompanion: Refactor symbol under cursor',
        mode = { 'n' },
      },
      {
        '<Leader>aD', -- Debug workflow
        function()
          vim.cmd 'CodeCompanionChat'
          vim.defer_fn(function()
            local buf = vim.api.nvim_get_current_buf()
            if vim.bo[buf].filetype == 'codecompanion' then
              vim.api.nvim_buf_set_lines(buf, -1, -1, false, {
                '@{debug_workflow} Debug analysis for current issue',
                '',
                '#{project_context}',
                '',
                'Help me debug this. Look for:',
                '- Recent changes that might cause issues',
                '- Common error patterns',
                '- Missing error handling',
                '- State management problems',
              })
              vim.cmd 'startinsert!'
            end
          end, 100)
        end,
        desc = 'CodeCompanion: Debug workflow',
        mode = { 'n' },
      },
      {
        '<Leader>avt', -- VectorCode toolbox
        function()
          vim.cmd 'CodeCompanionChat'
          vim.defer_fn(function()
            local buf = vim.api.nvim_get_current_buf()
            if vim.bo[buf].filetype == 'codecompanion' then
              vim.api.nvim_buf_set_lines(buf, -1, -1, false, {
                '@{vectorcode_toolbox} Semantic analysis of this codebase',
                '',
                'Please:',
                '1. Check what projects are indexed',
                '2. Search for semantic patterns related to my query',
                '3. Analyze the code structure and relationships',
                '4. Suggest improvements based on similar code patterns',
              })
              vim.cmd 'startinsert!'
            end
          end, 100)
        end,
        desc = 'CodeCompanion: VectorCode toolbox workflow',
        mode = { 'n' },
      },
      {
        '<Leader>aT', -- Test workflow
        function()
          vim.cmd 'CodeCompanionChat'
          vim.defer_fn(function()
            local buf = vim.api.nvim_get_current_buf()
            if vim.bo[buf].filetype == 'codecompanion' then
              local current_file = vim.fn.expand '%:t'
              local current_path = vim.fn.expand '%:p:h'

              vim.api.nvim_buf_set_lines(buf, -1, -1, false, {
                '@{test_workflow} Generate tests for ' .. current_file,
                '',
                -- First, analyze existing test patterns in this project:',
                '@{file_search} *test*.go *test*.js *test*.ts *test*.py *test*.rs *_test.* test_*',
                '@{file_search} tests/ __tests__/ test/ spec/ specs/',
                '',
                '-- Read the current file to understand what to test:',
                '@{read_file} ' .. vim.fn.expand '%:p',
                '',
                '-- Look for existing test examples in nearby directories:',
                '@{file_search} ' .. current_path .. '/*test*',
                '@{file_search} ' .. vim.fn.fnamemodify(current_path, ':h') .. '/test*',
                '',
                'Please:',
                "1. FIRST analyze any existing tests to understand the project's testing patterns:",
                '   - Testing framework used (Jest, Go testing, pytest, etc.)',
                '   - File naming conventions (*_test.go, *.test.js, test_*.py)',
                '   - Directory structure (tests/, __tests__, same directory)',
                '   - Mocking patterns and test utilities',
                '   - Code style and assertion patterns',
                '',
                '2. IF existing tests found: Follow the same patterns, style, and framework',
                '3. IF no tests found: Use best practices for the detected language',
                '',
                '4. Generate comprehensive tests including:',
                '   - Unit tests for individual functions',
                '   - Integration tests for workflows',
                '   - Edge cases and error conditions',
                '   - Mock external dependencies following project patterns',
                '',
                '5. Place tests in the appropriate location based on project structure',
              })
              vim.cmd 'startinsert!'
            end
          end, 100)
        end,
        desc = 'CodeCompanion: Generate tests workflow',
        mode = { 'n' },
      },
      {
        '<Leader>aP', -- Performance audit
        function()
          vim.cmd 'CodeCompanionChat'
          vim.defer_fn(function()
            local buf = vim.api.nvim_get_current_buf()
            if vim.bo[buf].filetype == 'codecompanion' then
              vim.api.nvim_buf_set_lines(buf, -1, -1, false, {
                '@{performance_audit} Analyze performance bottlenecks',
                '',
                '#{project_context}',
                '',
                'Review for performance issues:',
                '- Hot paths and critical sections',
                '- Memory allocation patterns',
                '- I/O operations and blocking calls',
                '- Algorithm complexity',
                '- Caching opportunities',
              })
              vim.cmd 'startinsert!'
            end
          end, 100)
        end,
        desc = 'CodeCompanion: Performance audit',
        mode = { 'n' },
      },
      {
        '<Leader>aM', -- Documentation workflow
        function()
          vim.cmd 'CodeCompanionChat'
          vim.defer_fn(function()
            local buf = vim.api.nvim_get_current_buf()
            if vim.bo[buf].filetype == 'codecompanion' then
              local current_file = vim.fn.expand '%:t'
              vim.api.nvim_buf_set_lines(buf, -1, -1, false, {
                '@{docs_workflow} Create documentation for ' .. current_file,
                '',
                '@{read_file} ' .. vim.fn.expand '%:p',
                '',
                'Generate documentation including:',
                '- Function/method documentation',
                '- Usage examples',
                '- API documentation',
                '- Architecture overview',
                '- README sections if needed',
              })
              vim.cmd 'startinsert!'
            end
          end, 100)
        end,
        desc = 'CodeCompanion: Documentation workflow',
        mode = { 'n' },
      },
    },
    init = function()
      -- Create useful command aliases
      vim.cmd [[cab cc CodeCompanion]]
      vim.cmd [[cab cca CodeCompanionActions]]
      vim.cmd [[cab ccc CodeCompanionChat]]

      vim.api.nvim_create_user_command('CCGenWorkspace', function()
        local project_type = vim.fn.input('Project type (go/rust/ts/python/mixed): ', 'mixed')
        local prompt = string.format(
          [[
Create a codecompanion-workspace.json file for this %s project.

@{file_search} find all main source files and important configs
@{grep_search} find main entry points and key functions

Based on the file structure, create appropriate groups for:
1. Core/main source files
2. Configuration files
3. Tests (if any)
4. Documentation

Use 'symbols' type for large files and 'file' type for important small files.
Format the response as a proper JSON workspace file.
]],
          project_type
        )

        vim.cmd 'CodeCompanionChat'
        vim.defer_fn(function()
          local buf = vim.api.nvim_get_current_buf()
          if vim.bo[buf].filetype == 'codecompanion' then
            vim.api.nvim_buf_set_lines(buf, -1, -1, false, vim.split(prompt, '\n'))
          end
        end, 100)
      end, { desc = 'Generate CodeCompanion workspace file' })

      vim.api.nvim_create_user_command('CCAnalyze', function(opts)
        local query = opts.args ~= '' and opts.args or vim.fn.input 'What to analyze: '
        local prompt = string.format(
          [[
@{grep_search} %s

#{project_context}

Analyze the search results and project context. Provide insights about:
- Code structure and patterns
- Potential improvements
- Architecture observations
- Best practices recommendations
]],
          query
        )

        vim.cmd 'CodeCompanionChat'
        vim.defer_fn(function()
          local buf = vim.api.nvim_get_current_buf()
          if vim.bo[buf].filetype == 'codecompanion' then
            vim.api.nvim_buf_set_lines(buf, -1, -1, false, vim.split(prompt, '\n'))
          end
        end, 100)
      end, { nargs = '?', desc = 'Quick analysis with RAG search' })

      vim.api.nvim_create_user_command('CCReview', function(opts)
        local file_pattern = opts.args ~= '' and opts.args or vim.fn.input 'File pattern to review: '
        local prompt = string.format(
          [[
@{file_search} %s
@{read_file} all found files

Review the found files and provide:
- Code quality assessment
- Security considerations
- Performance suggestions
- Best practices compliance

Focus on actionable improvements.
]],
          file_pattern
        )

        vim.cmd 'CodeCompanionChat'
        vim.defer_fn(function()
          local buf = vim.api.nvim_get_current_buf()
          if vim.bo[buf].filetype == 'codecompanion' then
            vim.api.nvim_buf_set_lines(buf, -1, -1, false, vim.split(prompt, '\n'))
          end
        end, 100)
      end, { nargs = '?', desc = 'Review files with CodeCompanion' })

      -- NUEVO: VectorCode setup y management
      vim.api.nvim_create_user_command('CCVectorSetup', function()
        local prompt = [[
#{vector_search}

Let's set up VectorCode for semantic search:

1. Check if VectorCode is installed
2. If not installed: Provide installation instructions
3. If installed but no index: Guide through index creation
4. If index exists: Show usage examples

After setup, explain how to use semantic search with CodeCompanion.
]]

        vim.cmd 'CodeCompanionChat'
        vim.defer_fn(function()
          local buf = vim.api.nvim_get_current_buf()
          if vim.bo[buf].filetype == 'codecompanion' then
            vim.api.nvim_buf_set_lines(buf, -1, -1, false, vim.split(prompt, '\n'))
          end
        end, 100)
      end, { desc = 'Setup VectorCode for semantic search' })

      -- NUEVO: Git analysis de commits específicos
      vim.api.nvim_create_user_command('CCGitCommit', function(opts)
        local commit_hash = opts.args ~= '' and opts.args or vim.fn.input 'Commit hash (or leave empty for recent): '
        local commit_arg = commit_hash ~= '' and commit_hash or 'HEAD~5..HEAD'

        local prompt = string.format(
          [[
@{git_analysis} Analyze git commits: %s

#{git_context}

Please analyze the specified commits:
1. Extract commit messages and changes
2. Assess code quality impact
3. Identify potential risks or improvements
4. Suggest follow-up actions

Commit range: %s
]],
          commit_arg,
          commit_arg
        )

        vim.cmd 'CodeCompanionChat'
        vim.defer_fn(function()
          local buf = vim.api.nvim_get_current_buf()
          if vim.bo[buf].filetype == 'codecompanion' then
            vim.api.nvim_buf_set_lines(buf, -1, -1, false, vim.split(prompt, '\n'))
          end
        end, 100)
      end, { nargs = '?', desc = 'Analyze specific git commits' })

      -- NUEVO: Semantic code search
      vim.api.nvim_create_user_command('CCSemanticSearch', function(opts)
        local query = opts.args ~= '' and opts.args or vim.fn.input 'Semantic search query: '

        local prompt = string.format(
          [[
@{semantic_search} Semantic search: "%s"

#{vector_search}

Execute semantic search and analysis:
1. Search for semantically similar code patterns
2. Compare with traditional keyword search
3. Find conceptually related functions/classes
4. Identify code relationships and dependencies
5. Suggest improvements based on patterns found

Search query: "%s"
]],
          query,
          query
        )

        vim.cmd 'CodeCompanionChat'
        vim.defer_fn(function()
          local buf = vim.api.nvim_get_current_buf()
          if vim.bo[buf].filetype == 'codecompanion' then
            vim.api.nvim_buf_set_lines(buf, -1, -1, false, vim.split(prompt, '\n'))
          end
        end, 100)
      end, { nargs = '?', desc = 'Semantic code search with VectorCode' })

      -- NUEVO: Pre-commit analysis
      vim.api.nvim_create_user_command('CCPreCommit', function()
        local prompt = [[
@{code_review_git} Pre-commit analysis

#{git_diff}

#{git_context}

Perform pre-commit analysis:
1. Review all staged/unstaged changes
2. Check for potential issues:
   - Code quality problems
   - Security vulnerabilities  
   - Performance regressions
   - Missing tests
   - Documentation gaps
3. Suggest commit message if changes look good
4. Recommend fixes if issues found

Ready to commit? Let's review first.
]]

        vim.cmd 'CodeCompanionChat'
        vim.defer_fn(function()
          local buf = vim.api.nvim_get_current_buf()
          if vim.bo[buf].filetype == 'codecompanion' then
            vim.api.nvim_buf_set_lines(buf, -1, -1, false, vim.split(prompt, '\n'))
          end
        end, 100)
      end, { desc = 'Pre-commit code analysis' })

      -- NUEVO: Branch comparison
      vim.api.nvim_create_user_command('CCBranchCompare', function(opts)
        local target_branch = opts.args ~= '' and opts.args or vim.fn.input('Compare with branch: ', 'main')

        local prompt = string.format(
          [[
@{git_analysis} Compare branches

#{git_context}

Compare current branch with: %s

Analysis needed:
1. What changed between branches?
2. Impact assessment of changes
3. Potential merge conflicts
4. Code quality comparison
5. Test coverage differences
6. Migration/deployment considerations

Target branch: %s
]],
          target_branch,
          target_branch
        )

        vim.cmd 'CodeCompanionChat'
        vim.defer_fn(function()
          local buf = vim.api.nvim_get_current_buf()
          if vim.bo[buf].filetype == 'codecompanion' then
            vim.api.nvim_buf_set_lines(buf, -1, -1, false, vim.split(prompt, '\n'))
          end
        end, 100)
      end, { nargs = '?', desc = 'Compare current branch with another' })

      vim.api.nvim_create_user_command('CCSmartTest', function(opts)
        local target_file = opts.args ~= '' and opts.args or vim.fn.expand '%:p'
        local target_name = vim.fn.fnamemodify(target_file, ':t')
        local target_dir = vim.fn.fnamemodify(target_file, ':h')

        local prompt = string.format(
          [[
@{test_workflow} Smart test generation for %s

-- STEP 1: Discover existing test patterns
@{file_search} *test* *spec* tests/ __tests__/ test/
@{grep_search} test framework imports describe it should expect assert

-- STEP 2: Look for tests in nearby locations  
@{file_search} %s/*test*
@{file_search} %s/../test*

-- STEP 3: Read the target file
@{read_file} %s

ANALYSIS: First analyze discovered tests to identify patterns, then generate tests following the same style. If no patterns found, use language best practices.
]],
          target_name,
          target_dir,
          target_dir,
          target_file
        )

        vim.cmd 'CodeCompanionChat'
        vim.defer_fn(function()
          local buf = vim.api.nvim_get_current_buf()
          if vim.bo[buf].filetype == 'codecompanion' then
            vim.api.nvim_buf_set_lines(buf, -1, -1, false, vim.split(prompt, '\n'))
          end
        end, 100)
      end, { nargs = '?', desc = 'Smart test generation with pattern detection' })

      -- Set up completion for codecompanion buffers
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'codecompanion',
        callback = function()
          -- Enable completion if you're using nvim-cmp
          local ok, cmp = pcall(require, 'cmp')
          if ok then
            cmp.setup.buffer {
              sources = {
                { name = 'codecompanion' },
                { name = 'path' },
                { name = 'buffer' },
              },
            }
          end
          vim.keymap.set('i', '@', function()
            -- Trigger completion for tools
            vim.api.nvim_feedkeys('@', 'n', false)
            vim.defer_fn(function()
              if vim.fn.pumvisible() == 0 then
                -- Trigger completion manually
                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-x><C-o>', true, false, true), 'n', false)
              end
            end, 50)
          end, { buffer = true, desc = 'CodeCompanion tools completion' })

          vim.keymap.set('i', '#', function()
            -- Trigger completion for variables
            vim.api.nvim_feedkeys('#', 'n', false)
            vim.defer_fn(function()
              if vim.fn.pumvisible() == 0 then
                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-x><C-o>', true, false, true), 'n', false)
              end
            end, 50)
          end, { buffer = true, desc = 'CodeCompanion variables completion' })
        end,
      })
    end,
  },
}
