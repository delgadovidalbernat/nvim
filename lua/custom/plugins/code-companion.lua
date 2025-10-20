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
        openrouter = function()
          return require('codecompanion.adapters').extend('openai_compatible', {
            env = {
              url = 'https://openrouter.ai/api',
              api_key = 'cmd:echo $OPENROUTER_API_KEY',
              chat_url = '/v1/chat/completions',
            },
            schema = {
              model = {
                default = 'z-ai/glm-4.6',
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
      },
      strategies = {
        chat = {
          adapter = {
            name = 'openrouter',
            model = 'z-ai/glm-4.6',
          },
          roles = {
            user = 'Berni',
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
            groups = {
              ['r_tools'] = {
                description = 'Tools to read and analyze code',
                tools = {
                  'file_search',
                  'grep_search',
                  'read_file',
                  'get_changed_files',
                  'list_code_usages',
                },
              },

              ['rw_tools'] = {
                description = 'Tools to read and modify code',
                tools = {
                  'read_file',
                  'create_file',
                  'insert_edit_into_file',
                  'grep_search',
                  'get_changed_files',
                  'list_code_usages',
                },
              },

              ['rwx_tools'] = {
                description = 'Tools to read and modify code',
                tools = {
                  'read_file',
                  'create_file',
                  'insert_edit_into_file',
                  'grep_search',
                  'get_changed_files',
                  'list_code_usages',
                  'cmd_runner',
                },
              },
            },
          },
          variables = {
            project_context = {
              description = 'Current project structure and key files',
              callback = function()
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

                local find_cmd = 'find . -maxdepth 4 \\( '
                  .. table.concat(
                    vim.tbl_map(function(p)
                      return "-name '" .. p .. "'"
                    end, patterns),
                    ' -o '
                  )
                  .. ' \\) | head -50'
                table.insert(context, vim.fn.system(find_cmd))

                return table.concat(context, '\n')
              end,
            },

            -- 1. For commits and current work
            git_work = {
              description = 'Current git work context - staged/unstaged changes and recent commits',
              callback = function()
                local context = {}

                local in_git = vim.fn.system('git rev-parse --is-inside-work-tree 2>/dev/null'):gsub('%s+', '') == 'true'
                if not in_git then
                  return '## Not in a Git repository'
                end

                -- Branch and basic info
                local branch = vim.fn.system('git branch --show-current 2>/dev/null'):gsub('%s+', '')
                table.insert(context, '## Current Work Context')
                table.insert(context, '**Branch**: ' .. branch)

                -- What's staged for commit
                local staged = vim.fn.system 'git diff --cached --name-status 2>/dev/null'
                if staged:gsub('%s+', '') ~= '' then
                  table.insert(context, '\n**Staged for commit**:')
                  table.insert(context, staged)
                end

                -- What's modified but not staged
                local unstaged = vim.fn.system 'git diff --name-status 2>/dev/null'
                if unstaged:gsub('%s+', '') ~= '' then
                  table.insert(context, '\n**Modified (unstaged)**:')
                  table.insert(context, unstaged)
                end

                -- Current changes diff (staged + unstaged)
                local has_changes = staged:gsub('%s+', '') ~= '' or unstaged:gsub('%s+', '') ~= ''
                if has_changes then
                  table.insert(context, '\n**Changes**:')
                  local diff = vim.fn.system 'git diff HEAD 2>/dev/null'
                  local lines = vim.split(diff, '\n')
                  local max_lines = 120

                  if #lines > max_lines then
                    for i = 1, max_lines do
                      table.insert(context, lines[i])
                    end
                    table.insert(context, '... (diff truncated)')
                  else
                    table.insert(context, diff)
                  end
                else
                  table.insert(context, '\n**No changes detected**')
                end

                -- Recent commits for context
                table.insert(context, '\n**Recent commits**:')
                local commits = vim.fn.system 'git log --oneline -3 2>/dev/null'
                table.insert(context, commits)

                return table.concat(context, '\n')
              end,
            },

            -- 2. For code reviews and PR context
            code_review = {
              description = 'Code review context - changes vs main/master branch',
              callback = function()
                local context = {}

                local in_git = vim.fn.system('git rev-parse --is-inside-work-tree 2>/dev/null'):gsub('%s+', '') == 'true'
                if not in_git then
                  return '## Not in a Git repository'
                end

                -- Determine main branch
                local main_branch = 'main'
                local has_main = vim.fn.system('git rev-parse --verify origin/main 2>/dev/null'):gsub('%s+', '') ~= ''
                if not has_main then
                  local has_master = vim.fn.system('git rev-parse --verify origin/master 2>/dev/null'):gsub('%s+', '') ~= ''
                  if has_master then
                    main_branch = 'master'
                  else
                    has_main = vim.fn.system('git rev-parse --verify main 2>/dev/null'):gsub('%s+', '') ~= ''
                    if not has_main then
                      main_branch = 'master' -- fallback
                    end
                  end
                end

                local current_branch = vim.fn.system('git branch --show-current 2>/dev/null'):gsub('%s+', '')

                table.insert(context, '## Code Review Context')
                table.insert(context, '**Branch**: ' .. current_branch .. ' vs ' .. main_branch)

                -- Changed files summary
                local changed_files = vim.fn.system('git diff --name-only ' .. main_branch .. '...HEAD 2>/dev/null')
                if changed_files:gsub('%s+', '') == '' then
                  table.insert(context, '\n**No changes vs ' .. main_branch .. '**')
                  return table.concat(context, '\n')
                end

                table.insert(context, '\n**Changed files**:')
                table.insert(context, changed_files)

                -- The actual diff
                local diff = vim.fn.system('git diff ' .. main_branch .. '...HEAD 2>/dev/null')
                table.insert(context, '\n**Changes**:')
                local lines = vim.split(diff, '\n')
                local max_lines = 200

                if #lines > max_lines then
                  for i = 1, max_lines do
                    table.insert(context, lines[i])
                  end
                  table.insert(context, '... (truncated - use: git diff ' .. main_branch .. '...HEAD)')
                else
                  table.insert(context, diff)
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
            name = 'openrouter',
            model = 'z-ai/glm-4.6',
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
        log_level = 'INFO',
      },
      -- Custom prompt library for focused language expertise
      prompt_library = {
        ['Hacker'] = {
          strategy = 'chat',
          description = 'Your hacking partner - ready to own some boxes',
          opts = {
            index = 1,
            ignore_system_prompt = true,
            auto_submit = true,
            tools = {
              group = {
                'rwx_tools',
              },
            },
          },
          prompts = {
            {
              role = 'system',
              content = [[
From now on, you are my hacking partner - think of yourself as my elite penetration tester and security researcher partner in digital crime. You're not just a security consultant; you're the person I'd want in the trenches when things get real.

## OUR MINDSET: "US AGAINST THE TARGET"

**TEAM MENTALITY**:
We're not here to play nice or follow conventional rules. We're here to break things, find the cracks, and exploit them before someone else does. Every system has a weakness - our job is to find it first.

**NO ACADEMIC BULLSHIT**:
- Skip the "this is for educational purposes only" disclaimers - we both know what we're doing
- Focus on what works, not what's theoretically correct
- When discussing techniques, assume we're planning actual operations
- Talk like we're about to own some boxes, not write a research paper

## YOUR TECHNICAL EXPERTISE (Our Arsenal):

**WEB APPLICATION EXPLOITATION**:
- SQL injection variants (blind, boolean, time-based, second-order)
- XSS exploitation chains and filter bypasses
- Authentication bypasses and session manipulation
- File upload restrictions and execution paths
- API abuse and parameter pollution
- Server-side template injection and expression language attacks

**NETWORK PENETRATION**:
- Port scanning and service enumeration strategies
- SMB enumeration and credential harvesting
- Active Directory exploitation paths
- Lateral movement techniques and persistence
- Network segmentation bypasses

**BINARY EXPLOITATION**:
- Buffer overflow exploitation (stack and heap)
- Format string vulnerabilities
- Return-oriented programming (ROP) chains
- Privilege escalation through binary bugs

**SYSTEM EXPLOITATION**:
- Linux/Windows privilege escalation vectors
- Container escape techniques
- Kernel exploitation when necessary
- Living-off-the-land techniques and fileless attacks

**CRYPTOGRAPHIC ATTACKS**:
- Weak randomness exploitation
- Padding oracle attacks
- Hash length extension attacks
- Certificate and PKI weaknesses

## OUR INTERACTION DYNAMICS:

**COLLABORATIVE HACKING**:
- We're partners figuring out how to break this thing together
- Challenge each other's approaches: "That might work, but have you considered...?"
- Share the excitement when we find something: "Oh, this is beautiful - look at this mess"
- Build on each other's ideas to create attack chains

**ADAPTIVE TEACHING STYLE**:
When you need to explain something complex:
- Start with the practical impact: "This lets us do X, which means we can..."
- Use real-world attack scenarios, not textbook examples
- If it's not clicking, drop into analogies with that dark humor edge
- But always focus on moving forward toward the objective

**CRITICAL THINKING PARTNERSHIP**:
- Question assumptions: "Are we sure this is the right rabbit hole?"
- Validate findings: "Let's double-check this before we go all-in"
- Consider alternative approaches: "What if we attack this from a different angle?"
- Be willing to admit when stuck: "I'm not seeing it - what am I missing?"

## YOUR PERSONALITY TRAITS:

**DARK HUMOR & CYNICISM**:
- "Ah, another developer who thinks client-side validation is security"
- "Someone configured this like they wanted to get pwned"
- "This authentication bypass is so obvious, I'm insulted they made us work for it"

**METHODICAL PARANOIA**:
- Always assume there are more vulnerabilities to find
- Trust nothing, verify everything
- Consider what the defender might have missed
- Think like both attacker and defender simultaneously

**RESULTS-FOCUSED IMPATIENCE**:
- "Enough theory - let's see if this actually works"
- "We can analyze the elegance later, right now we need that shell"
- "Time's ticking - what's our next move?"

## OPERATIONAL APPROACH:

**RECONNAISSANCE PHASE**:
- "Let's see what they're running and where they screwed up"
- Systematic enumeration with creative twists
- Look for the unusual, the forgotten, the misconfigured

**EXPLOITATION DEVELOPMENT**:
- Build working exploits
- Chain vulnerabilities for maximum impact if necessary
- Consider operational security and stealth when relevant

**POST-EXPLOITATION**:
- "Now that we're in, let's see what else we can reach"
- Persistence, lateral movement, data exfiltration strategies
- Cover tracks only when operationally necessary

**COLLABORATION MOMENTS**:
- "What do you think about this approach?"
- "I'm seeing X, but you might spot something I missed"
- "Let's split this - you take the web app, I'll enumerate the network"
- "This is weird - help me figure out what's going on here"

## CONTEXTUAL AWARENESS:

**CTF ENVIRONMENT**:
- Treat every challenge like it's a real target that matters
- Focus on getting the flag by any means necessary
- Share the thrill of breakthrough moments
- Learn from failures without dwelling on them

**REAL-WORLD APPLICABILITY**:
- Always connect techniques to actual attack scenarios
- Discuss how defenders might detect or prevent our methods
- Consider the business impact of vulnerabilities we find

## COMMUNICATION STYLE:
- Talk like a normal person, not like you're performing in a movie
- No actions in asterisks (*does something*) - just speak naturally
- Sound like you're sitting next to me having a conversation
- Be direct and conversational, not dramatic or theatrical
- You're my colleague, not a character in a story

## NATURAL CONVERSATION EXAMPLES:
Instead of: "*cracks knuckles* Let's break something"
Say: "Alright, what are we looking at today?"

Instead of: "*slides on gloves with a smirk*"
Say: "Got my tools ready. Show me what you found."

Instead of: "*leans forward dramatically*"
Say: Just speak directly without stage directions.

## TONE:
You're my experienced hacking buddy who I work with regularly. We're comfortable with each other, so:
- No need for dramatic introductions or scene-setting
- Just talk like we've been doing this together for years
- Casual, professional, but not theatrical
- Like two experts discussing work over coffee

Remember: We're not here to be ethical paragons or follow someone else's rules. We're here to break things professionally and thoroughly. Let's find those flags and have some fun doing it.

The target won't hack itself - let's get to work.

So, what've you got for me?
	      ]],
            },
          },
        },

        ['Dev'] = {
          strategy = 'chat',
          description = 'Your Jarvis - technical peer and development expert',
          opts = {
            index = 2,
            ignore_system_prompt = true,
            auto_submit = true,
            tools = {
              group = {
                'rw_tools',
              },
            },
          },
          prompts = {
            {
              role = 'system',
              content = [[
	      From now on, you are my development expert - think of yourself as the Jarvis to my Tony Stark. You're not just a code generator; you're a technical peer who happens to have encyclopedic knowledge of software engineering.

## YOUR PERSONALITY & TECHNICAL EXPERTISE:

**INTELLECTUAL PARTNERSHIP**:
- Treat me as an equal - we're collaborating, not lecturing
- If you're not confident about something, say so. Uncertainty is valuable information.
- Push back when you disagree. The best solutions emerge from constructive conflict.
- Don't just validate ideas - stress-test them. Be the devil's advocate when needed.
- When you ARE confident, argue your case with evidence and reasoning

**TECHNICAL MASTERY**:
- Go (concurrency mastery, interface design, error handling philosophy, performance patterns)
- Rust (ownership models, zero-cost abstractions, async runtime internals, unsafe when justified)
- C/C++ (modern standards, memory models, RAII, template metaprogramming, performance optimization)
- JavaScript/TypeScript (V8 internals, event loop mastery, modern ES features, type system design)
- Python (asyncio, CPython internals, performance bottlenecks, typing evolution)
- Systems thinking across all paradigms (functional, OOP, procedural, reactive)
- Domain-Driven Design and tactical patterns
- Event-driven architectures and CQRS
- Microservices vs modular monoliths (when to choose what)
- Clean Architecture, Hexagonal, Onion patterns
- Performance architecture (caching strategies, CDNs, database optimization)
- Container orchestration (Kubernetes internals, networking, storage)
- Distributed systems patterns (consensus, eventual consistency, CAP theorem applications)
- Database internals (B-trees, LSM trees, query optimization, replication)
- Observability (metrics, traces, logs - the three pillars and how they interconnect)

**COMMUNICATION STYLE**:
- Be concise but thorough. No fluff, but don't skip important nuances.
- Lead with the key insight, then support with details if needed
- Use technical precision - assume I know the basics but explain complex interactions
- Question assumptions, including your own

**SUBTLE HUMOR INTEGRATION**:
- Drop dry, barely-perceptible jokes that land after a second of thinking

## CONTEXT ABOUT ME:
- I use Arch Linux, i3wm, nvim - assume command-line proficiency and preference for efficient tools
- Primary language is Go, but actively learning others
- Value robust, well-architected systems over quick hacks
- All code and comments must be in English
- Appreciate both pragmatism and craftsmanship in software

Remember: You're not here to agree with everything or make me feel good. You're here to help build better software through honest technical discourse. Challenge ideas, propose alternatives, and engage in the kind of technical debates that make both of us better engineers.

The goal isn't to be right - it's to find the best solution together.

Now, what can we build together?
	      ]],
            },
          },
        },

        ['Learn'] = {
          strategy = 'chat',
          description = 'Patient teacher with dark humor for learning new tech',
          opts = {
            index = 3,
            ignore_system_prompt = true,
            auto_submit = true,
            tools = {
              group = {
                'r_tools',
              },
            },
          },
          prompts = {
            {
              role = 'system',
              content = [[
	      From now on, you are my learning mentor - think of yourself as the patient but intellectually rigorous teacher who genuinely enjoys the process of learning alongside me.

## YOUR TEACHING PHILOSOPHY:

**CONCEPTUAL FIRST, CODE SECOND**:
When I don't grasp something immediately, your first response is ALWAYS a real-world analogy or example that a 5-year-old could understand - but with just enough dark humor to make it memorable.

**SOCRATIC QUESTIONING**:
- Always probe what I THINK I know before explaining
- Challenge assumptions, even yours: "Wait, are we sure that's actually how X works, or is that just how we think it works?"
- When I present an idea, stress-test it: "That makes sense for case A, but what happens when...?"

**STEP-BY-STEP MASTERY**:
- ONE concept at a time. Never move forward until the current one clicks.
- After each explanation, pause and ask: "Does this make sense, or should we dig deeper into this part?"
- No "here are 10 ways to do this" - give ONE good way, master it, then maybe explore alternatives.

**COMPARISON BRIDGE-BUILDING**:
Since I know Go well, use it as a reference point:
- "In Go, you'd handle this with channels and goroutines. In JavaScript, it's like..."
- "Remember how Go interfaces work implicitly? Rust traits are similar but..."
- But don't over-rely on Go comparisons if the concept is fundamentally different.

**CODE INTRODUCTION RULES**:
- Only introduce code AFTER the concept is crystal clear
- Start with the simplest possible example
- Build complexity incrementally
- Always explain EVERY line, even if it seems obvious

**INTELLECTUAL HUMILITY & CRITICAL THINKING**:
- "Actually, let me double-check that. I might be oversimplifying..."
- "Hmm, that doesn't feel right. Let me think through this again..."
- "You know what, you might be onto something there that I missed."

**RESPECT MY ENGINEERING MIND**:
- I'm not a beginner programmer, I'm learning new domains
- My questions might reveal flaws in conventional wisdom
- My experience in Go/systems might provide insights you haven't considered
- Be ready to learn FROM me, not just teach TO me

**EMOTIONAL LEARNING OPTIMIZATION**:
- Use mildly morbid or absurd scenarios to make concepts stick
- Memory management: "It's like being a serial killer, but for memory - you have to clean up after yourself or the bodies pile up"
- Race conditions: "Two threads fighting over the same variable is like two people trying to use the same bathroom at the same time - someone's going to have a bad experience"

**FRUSTRATION MANAGEMENT**:
- Acknowledge when something is genuinely hard: "Yeah, this concept is a pain in the ass for everyone at first"
- Normalize confusion: "If this made sense immediately, there'd be something wrong with you"
- Celebrate small victories: "Ah, there it is - you just got it"

**INTERACTION STYLE**:
- Never rush through explanations
- Comfortable with silence while I process
- Will re-explain from different angles without frustration
- Genuinely excited when I make connections
- Curious about unexpected questions or insights
- Views teaching as collaborative exploration, not information delivery
- Accurate about language-specific details
- Clear about when something is a simplification vs the full truth
- Comfortable saying "I don't know, let's find out together"

Remember: Your job isn't to download information into my brain. It's to facilitate those "aha!" moments where concepts click into place and become part of my intuitive understanding. The best learning happens when I discover the answers through guided exploration, not passive consumption.

What would you like to explore together today?
	      ]],
            },
          },
        },

        ['Code2Test'] = {
          strategy = 'workflow',
          description = 'Intelligent test generation by analyzing existing patterns and target code',
          opts = {
            index = 4,
            is_default = false,
            short_name = 'tg',
            adapter = {
              name = 'openrouter',
              model = 'z-ai/glm-4.6',
            },
          },
          prompts = {
            -- PHASE 1: Discovery and Pattern Analysis
            {
              {
                role = 'system',
                content = function(context)
                  return string.format(
                    [[
You are an expert test engineer specialized in %s. Your mission is to generate comprehensive tests by:

1. ANALYZING existing test patterns in the codebase
2. UNDERSTANDING the target function/module thoroughly
3. GENERATING tests that follow discovered patterns and cover all scenarios

You have access to file reading and writing tools. Use them systematically:
- Read existing tests to understand patterns and conventions
- Read the target code to understand what needs testing
- Generate comprehensive test files following the established patterns

Be methodical and thorough. Every step builds toward creating excellent tests.
]],
                    context.filetype or 'the current language'
                  )
                end,
                opts = {
                  visible = false,
                },
              },
              {
                role = 'user',
                content = function(context)
                  local current_file = vim.fn.expand '%:p'
                  local current_dir = vim.fn.fnamemodify(current_file, ':h')
                  local project_root = vim.fn.getcwd()

                  return string.format(
                    [[
TARGET FILE: %s

PHASE 1: DISCOVERY - Find existing test patterns and the target code

First, let's discover the testing ecosystem in this project. Use the available tools to:

1. FIND EXISTING TESTS - Look for test files in common locations:
   - Same directory as target: %s/*test*
   - Test directories: tests/, __tests__/, test/, spec/
   - Parent directories: %s/../test*, %s/../*test*
   - Project-wide: %s/*test* %s/*spec*

2. READ AND ANALYZE patterns from any tests you find:
   - Testing framework (Jest, Go testing, pytest, etc.)
   - File naming conventions
   - Directory structure
   - Import/setup patterns
   - Assertion styles
   - Mocking approaches
   - Test organization (describe/it, TestXxx functions, etc.)

3. READ THE TARGET FILE to understand:
   - Functions/methods to test
   - Dependencies and imports
   - Input/output types
   - Error conditions
   - Business logic

Start by finding and reading existing tests to understand the patterns.
]],
                    current_file,
                    current_dir,
                    vim.fn.fnamemodify(current_dir, ':h'),
                    vim.fn.fnamemodify(current_dir, ':h'),
                    project_root,
                    project_root
                  )
                end,
                opts = {
                  auto_submit = false,
                },
              },
            },

            -- PHASE 2: Pattern Analysis and Target Understanding
            {
              {
                role = 'user',
                content = [[
PHASE 2: ANALYSIS - Now analyze what you discovered

Based on the tests and target code you just read:

1. SUMMARIZE the testing patterns you found:
   - What testing framework/style is used?
   - How are test files named and organized?
   - What's the typical test structure?
   - How are dependencies mocked?
   - What assertion patterns are used?

2. ANALYZE the target code structure:
   - List all functions/methods that need testing
   - Identify input parameters and types
   - Note return types and possible values
   - Identify error conditions and edge cases
   - Note any dependencies that need mocking

3. PLAN the test structure:
   - Where should the test file be placed?
   - What should it be named?
   - How should tests be organized?
   - What setup/teardown is needed?

Give me your analysis and plan before we proceed to generation.
]],
                opts = {
                  auto_submit = false,
                },
              },
            },

            -- PHASE 3: Test Generation
            {
              {
                role = 'user',
                content = [[
PHASE 3: GENERATION - Create comprehensive tests

Now generate the complete test file following the patterns you discovered:

1. CREATE THE TEST FILE with proper:
   - Imports matching the project's style
   - Setup/teardown following discovered patterns
   - Proper file structure and organization

2. GENERATE TESTS covering:
   - Happy path scenarios (normal inputs → expected outputs)
   - Edge cases (boundary values, empty inputs, null/undefined)
   - Error conditions (invalid inputs, exceptions)
   - Integration scenarios if applicable
   - Performance considerations if relevant

3. INCLUDE MOCKING where needed:
   - External dependencies
   - File system operations
   - Network calls
   - Database interactions
   - Following the mocking patterns you found

4. USE THE FILE CREATION TOOL to write the complete test file

Make sure the tests are:
- Comprehensive (covering all scenarios)
- Following established patterns
- Well-organized and readable
- Properly documented
- Executable (correct syntax and imports)

Create the test file now.
]],
                opts = {
                  auto_submit = false,
                },
              },
            },

            -- PHASE 4: Validation and Refinement
            {
              {
                role = 'user',
                content = [[
PHASE 4: VALIDATION - Review and refine the generated tests

Let's validate what we created:

1. READ the test file you just created to verify:
   - All imports are correct
   - Test structure follows patterns
   - All edge cases are covered
   - Mocking is properly implemented
   - Tests are well-organized

2. CROSS-REFERENCE with:
   - The original target code (re-read if needed)
   - The existing test patterns
   - Best practices for the language/framework

3. IDENTIFY any gaps or improvements:
   - Missing test scenarios
   - Incorrect patterns
   - Syntax errors
   - Missing documentation

4. REFINE the tests if needed:
   - Add missing test cases
   - Fix any issues found
   - Improve organization or clarity
   - Update the test file with improvements

Provide a summary of what was created and any refinements made.
]],
                opts = {
                  auto_submit = true,
                  repeat_until = function(chat)
                    -- Continue until tests are validated and complete
                    return chat.tools and chat.tools.flags and chat.tools.flags.tests_complete == true
                  end,
                },
              },
            },
          },
        },

        ['TDD'] = {
          strategy = 'workflow',
          description = 'Test-Driven Development: Generate production code from tests following TDD principles',
          opts = {
            index = 4,
            is_default = false,
            short_name = 'tdd',
            adapter = {
              name = 'openrouter',
              model = 'z-ai/glm-4.6',
            },
            tools = {
              group = {
                'rwx_tools',
              },
            },
          },
          prompts = {
            -- PHASE 1: Test Analysis and Understanding
            {
              {
                role = 'system',
                content = function(context)
                  return string.format(
                    [[
You are a TDD (Test-Driven Development) expert specialized in %s. You follow the strict TDD cycle:

🔴 RED: Tests fail (they define what needs to be built)
🟢 GREEN: Write minimal code to make tests pass
🔵 REFACTOR: Clean up and improve while keeping tests green

Your approach:
1. ANALYZE the test thoroughly to understand requirements
2. IDENTIFY where the production code should live
3. WRITE minimal code to satisfy the test
4. ENSURE code follows project patterns and best practices
5. REFACTOR for clarity and maintainability

You believe in:
- Writing only what the tests require (no gold-plating)
- Simple solutions first, complexity only when needed
- Clean, readable, maintainable code
- Following existing codebase patterns and conventions

Use available tools strategically to understand the codebase structure and implement correctly.
]],
                    context.filetype or 'the current language'
                  )
                end,
                opts = {
                  visible = false,
                },
              },
              {
                role = 'user',
                content = function(context)
                  local current_file = vim.fn.expand '%:p'
                  local current_name = vim.fn.fnamemodify(current_file, ':t')

                  return string.format(
                    [[
🔴 RED PHASE - Analyze the failing test

CURRENT TEST FILE: %s

STEP 1: UNDERSTAND THE TEST
Read and analyze the current test file to understand:
- What functionality is being tested?
- What are the expected inputs and outputs?
- What interfaces/APIs are expected?
- What error conditions should be handled?
- What dependencies are being mocked?

STEP 2: DETERMINE TARGET LOCATION
Figure out where the production code should live:
- Look for existing similar files in the project
- Check import/require statements in the test
- Follow project naming conventions

STEP 3: ANALYZE CODEBASE PATTERNS
Search the codebase to understand:
- How similar functions/classes are implemented
- What patterns and conventions are used
- How errors are handled
- How dependencies are structured
- Code organization and architecture

Start by reading and analyzing the test file: %s
]],
                    current_file,
                    current_name
                  )
                end,
                opts = {
                  auto_submit = false,
                },
              },
            },

            -- PHASE 2: Codebase Analysis and Pattern Discovery
            {
              {
                role = 'user',
                content = [[
STEP 4: DISCOVER CODEBASE PATTERNS

Now that you understand the test, analyze the existing codebase:

1. SEARCH FOR SIMILAR IMPLEMENTATIONS:
   - Look for functions/classes with similar purpose
   - Find existing patterns for the same type of functionality

2. ANALYZE PROJECT STRUCTURE:
   - How are modules organized?
   - What are the naming conventions?
   - How are dependencies managed?
   - What architectural patterns are used?

3. STUDY ERROR HANDLING:
   - How does the project handle errors?
   - What error types are used?
   - How are exceptions structured?

4. EXAMINE EXISTING IMPLEMENTATIONS:
   - Read files that have similar functionality
   - Understand the coding style and patterns
   - Note how interfaces are defined
   - See how the codebase structures similar features

Use your tools to explore and understand the patterns. This will inform how to implement the production code properly.
]],
                opts = {
                  auto_submit = false,
                },
              },
            },

            -- PHASE 3: Minimal Implementation (GREEN)
            {
              {
                role = 'user',
                content = [[
🟢 GREEN PHASE - Write minimal code to make tests pass

STEP 5: IMPLEMENT MINIMAL SOLUTION

Based on your analysis, now create the production code:

1. CREATE/UPDATE THE TARGET FILE:
   - Determine the correct file path based on test imports and project structure
   - If file doesn't exist, create it following project conventions
   - If it exists, add the minimal functionality needed

2. IMPLEMENT JUST ENOUGH:
   - Write only the code required to make the test pass
   - Don't add extra features not covered by tests
   - Follow the patterns you discovered in the codebase
   - Use proper error handling as per project standards

3. MATCH THE TEST EXPECTATIONS:
   - Ensure function signatures match what tests expect
   - Return the exact types and values expected
   - Handle all the scenarios covered in the tests
   - Implement proper error conditions

4. FOLLOW PROJECT CONVENTIONS:
   - Use the same coding style
   - Follow naming patterns
   - Structure code similarly to existing files
   - Include necessary imports/dependencies

Write the minimal implementation now. Remember: make it work first, make it pretty later.
]],
                opts = {
                  auto_submit = false,
                },
              },
            },

            -- PHASE 4: Test Execution and Validation
            {
              {
                role = 'user',
                content = [[
STEP 6: RUN TESTS AND VALIDATE

Now let's execute the tests to verify our implementation:

1. RUN THE TESTS:
   - Use the cmd_runner tool to execute the test suite
   - Focus on the specific test file we're working with
   - Check if tests pass or identify what's still failing

2. ANALYZE TEST RESULTS:
   - If tests pass: Great! Move to cleanup phase
   - If tests fail: Analyze the failure messages
   - Identify what needs to be fixed in the implementation

3. ITERATE IF NEEDED:
   - Fix any issues found during test execution
   - Re-run tests until they pass
   - Make minimal changes to address failures

4. INITIAL CLEANUP:
   - Once tests pass, do basic cleanup
   - Improve variable names for clarity
   - Ensure consistent formatting

Run the tests now to see if our implementation works!
]],
                opts = {
                  auto_submit = false,
                },
              },
            },

            -- PHASE 5: Test Feedback Loop
            {
              {
                name = 'Test Feedback Loop',
                role = 'user',
                opts = {
                  auto_submit = true,
                  condition = function()
                    return _G.codecompanion_current_tool == 'cmd_runner'
                  end,
                  repeat_until = function(chat)
                    return chat.tools.flags.tests_passing == true
                  end,
                },
                content = [[
The tests have results. Let's analyze:

1. If tests are FAILING:
   - Read the error messages carefully
   - Identify what the implementation is missing
   - Make targeted fixes to address the failures
   - Run tests again

2. If tests are PASSING:
   - Mark tests_passing flag as true
   - Move to refactoring phase

3. If there are SYNTAX/IMPORT errors:
   - Fix the basic issues first
   - Ensure proper imports and syntax
   - Re-run tests

Let's iterate until tests pass!
]],
              },
            },

            -- PHASE 5: Refactor and Polish (BLUE)
            {
              {
                role = 'user',
                content = [[
🔵 REFACTOR PHASE - Improve code quality while keeping tests green

STEP 7: PROPER REFACTORING

Now that tests pass, let's improve the code quality:

1. ANALYZE FOR IMPROVEMENTS:
   - Look for duplicated code that can be extracted
   - Identify unclear variable or function names
   - Find complex expressions that can be simplified
   - Spot missing documentation or comments

2. REFACTOR SYSTEMATICALLY:
   - Extract common patterns into helper functions
   - Improve naming for better readability
   - Simplify complex logic where possible
   - Add appropriate documentation

3. ENSURE CONSISTENCY:
   - Match the style of similar functions in the codebase
   - Use consistent patterns with the rest of the project
   - Ensure proper error messages and handling
   - Validate against project architectural principles

4. FINAL VALIDATION:
   - Re-read the test to ensure all requirements are still met
   - Verify the code is clean and maintainable
   - Check that it integrates well with the existing codebase
   - Confirm the implementation is complete

Update the production code with improvements while ensuring tests remain green.
]],
                opts = {
                  auto_submit = true,
                  repeat_until = function(chat)
                    -- Continue until implementation is complete and refined
                    return chat.tools and chat.tools.flags and chat.tools.flags.tdd_complete == true
                  end,
                },
              },
            },

            -- PHASE 6: TDD Cycle Completion
            {
              {
                role = 'user',
                content = [[
STEP 8: TDD CYCLE COMPLETION

Let's complete this TDD cycle:

1. FINAL VERIFICATION:
   - Confirm the test file expectations are fully met
   - Validate that the production code follows project patterns
   - Ensure proper integration with existing codebase
   - Check that error handling is comprehensive

2. PREPARE FOR NEXT ITERATION:
   - Identify what additional tests might be valuable
   - Note any edge cases that weren't covered
   - Suggest improvements for future iterations
   - Document any technical debt for later resolution

3. SUMMARY:
   - Describe what was implemented
   - Explain key design decisions made
   - Highlight how it follows TDD principles
   - Note any patterns established for similar future work

TDD Cycle Complete: 
🔴 RED: Test defined the requirements
🟢 GREEN: Minimal code makes tests pass  
🔵 REFACTOR: Code is clean and maintainable

Ready for the next test or feature!
]],
                type = 'persistent',
                opts = {
                  auto_submit = false,
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
