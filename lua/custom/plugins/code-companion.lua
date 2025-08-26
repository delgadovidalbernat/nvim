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
      },
      adapters = {
        tavily = function()
          return require('codecompanion.adapters').extend('tavily', {
            env = {
              api_key = 'cmd:echo $TAVILY_API_KEY',
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
            name = 'ollama', -- Change to "anthropic" or "ollama" when using alternatives
            model = 'qwen3-coder', -- Change to "claude-3-5-sonnet-20241022" or "codellama:latest"
          },
          roles = {
            user = 'Berni', -- Using your preferred name
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
    },
    init = function()
      -- Create useful command aliases
      vim.cmd [[cab cc CodeCompanion]]
      vim.cmd [[cab cca CodeCompanionActions]]
      vim.cmd [[cab ccc CodeCompanionChat]]

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
              },
            }
          end
        end,
      })
    end,
  },
}
