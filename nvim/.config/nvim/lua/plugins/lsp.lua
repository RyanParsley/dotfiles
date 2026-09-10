return {
    'joeveiga/ng.nvim',
    {
        'mason-org/mason.nvim',
        lazy = false,
        opts = {},
    },
    {
        'mason-org/mason-lspconfig.nvim',
        lazy = false,
        opts = {
            ensure_installed = {
                'angularls',
                'astro',
                'bashls',
                'html',
                'lua_ls',
                'marksman',
                'quick_lint_js',
                'ts_ls',
                'yamlls',
            },
            automatic_enable = {
                'angularls',
                'astro',
                'bashls',
                'eslint',
                'html',
                'lua_ls',
                'markdown_oxide',
                'marksman',
                'nushell',
                'quick_lint_js',
                'stylelint_lsp',
                'ts_ls',
                'vale_ls',
                'yamlls',
            },
        },
    },
    {
        'neovim/nvim-lspconfig',
        lazy = false,
        dependencies = {
            -- Automatically install LSPs and related tools to stdpath for Neovim
            { 'mason-org/mason.nvim', config = true }, -- NOTE: Must be loaded before dependants
            'mason-org/mason-lspconfig.nvim',
            'WhoIsSethDaniel/mason-tool-installer.nvim',
            -- Useful status updates for LSP.
            -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
            { 'j-hui/fidget.nvim', opts = {} },

            -- `neodev` configures Lua LSP for your Neovim config, runtime and plugins
            -- used for completion, annotations and signatures of Neovim apis
            { 'folke/lazydev.nvim', opts = {} },
        },
        opts = {
            inlay_hints = { enabled = true },
            servers = {
                angularls = {},
            },
            setup = {},
        },

        config = function()
            -- Get default capabilities from nvim-cmp
            local capabilities = require('cmp_nvim_lsp').default_capabilities()

            -- Set global default capabilities for all LSP servers
            -- This is especially important for nvim-java which uses vim.lsp.enable internally
            vim.lsp.config('*', {
                capabilities = capabilities,
            })

            -- Disable vale_ls by preventing it from finding a root directory
            -- It will only start if .vale.ini exists in the project
            vim.lsp.config('vale_ls', {
                root_dir = function(bufnr, on_dir)
                    -- Check if .vale.ini exists by searching upward
                    local root = vim.fs.root(bufnr, { '.vale.ini' })
                    if root then
                        on_dir(root)
                    end
                    -- If no root found, don't call on_dir() - this prevents LSP from starting
                end,
            })

            -- Shared on_attach function for common LSP setup
            local function on_attach(client, bufnr)
                -- Set up codelens refresh for supported servers
                if client.server_capabilities.codeLensProvider then
                    vim.lsp.codelens.enable(true, { bufnr = bufnr })
                end
            end

            require('mason').setup()
            require('mason-tool-installer').setup {
                ensure_installed = {
                    -- Formatters
                    'stylua',
                    'shfmt',
                    'prettierd',
                    'google-java-format',
                    'stylelint-language-server',

                    -- Linters
                    'eslint_d',
                    'markdownlint-cli2',
                    'checkstyle',
                    'statix',

                    -- Debuggers
                    'codelldb',
                    'js-debug-adapter',

                    -- Tools
                    'bacon',
                    'bacon-ls',
                    'tree-sitter-cli',
                    'zk',
                },
            }
            -- Configure LSP servers using vim.lsp.config (new API)
            vim.lsp.config('astro', {
                capabilities = capabilities,
                on_attach = on_attach,
                settings = {
                    typescript = {
                        inlayHints = {
                            parameterNames = {
                                enabled = 'all',
                            },
                            parameterTypes = {
                                enabled = true,
                            },
                            variableTypes = {
                                enabled = true,
                            },
                            propertyDeclarationTypes = {
                                enabled = true,
                            },
                            functionLikeReturnTypes = {
                                enabled = true,
                            },
                            enumMemberValues = {
                                enabled = true,
                            },
                        },
                    },
                },
                filetypes = { 'astro', 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' },
                root_dir = function(bufnr, on_dir)
                    local root =
                        vim.fs.root(bufnr, { 'astro.config.mjs', 'astro.config.ts', 'astro.config.js', 'package.json' })
                    if root then
                        on_dir(root)
                    end
                end,
            })

            vim.lsp.config('eslint', { capabilities = capabilities })

            vim.lsp.config('markdown_oxide', {
                on_attach = function(client, bufnr)
                    -- Use shared on_attach for common setup
                    on_attach(client, bufnr)

                    -- setup Markdown Oxide daily note commands
                    if client.name == 'markdown_oxide' then
                        vim.api.nvim_create_user_command('Daily', function(args)
                            local input = args.args
                            local clients =
                                vim.lsp.get_clients { bufnr = vim.api.nvim_get_current_buf(), name = 'markdown_oxide' }
                            if clients[1] then
                                clients[1]:exec_cmd { command = 'jump', arguments = { input } }
                            end
                        end, { desc = 'Open daily note', nargs = '*' })
                    end
                end,
                capabilities = capabilities,
                filetypes = { 'markdown' },
                root_markers = { '.git', '.obsidian', '.moxide.toml' },
                cmd = { 'markdown-oxide' },
            })

            -- TypeScript/JavaScript language server with Nx workspace detection
            vim.lsp.config('ts_ls', {
                capabilities = capabilities,
                on_attach = on_attach,
                root_dir = function(bufnr, on_dir)
                    -- Try to find Nx workspace root first (highest priority)
                    local root = vim.fs.root(bufnr, { 'nx.json' })
                    if root then
                        on_dir(root)
                        return
                    end

                    -- Fallback to Angular workspace
                    root = vim.fs.root(bufnr, { 'angular.json' })
                    if root then
                        on_dir(root)
                        return
                    end

                    -- Fallback to package.json or tsconfig.json
                    root = vim.fs.root(bufnr, { 'package.json', 'tsconfig.json', 'jsconfig.json' })
                    if root then
                        on_dir(root)
                    end
                end,
                settings = {
                    typescript = {
                        inlayHints = {
                            includeInlayParameterNameHints = 'all',
                            includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                            includeInlayFunctionParameterTypeHints = true,
                            includeInlayVariableTypeHints = true,
                            includeInlayPropertyDeclarationTypeHints = true,
                            includeInlayFunctionLikeReturnTypeHints = true,
                            includeInlayEnumMemberValueHints = true,
                        },
                    },
                    javascript = {
                        inlayHints = {
                            includeInlayParameterNameHints = 'all',
                            includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                            includeInlayFunctionParameterTypeHints = true,
                            includeInlayVariableTypeHints = true,
                            includeInlayPropertyDeclarationTypeHints = true,
                            includeInlayFunctionLikeReturnTypeHints = true,
                            includeInlayEnumMemberValueHints = true,
                        },
                    },
                },
            })

            vim.lsp.config('angularls', {
                on_attach = on_attach,
                capabilities = capabilities,
                filetypes = { 'typescript', 'html', 'typescriptreact', 'htmlangular' },
                root_dir = function(bufnr, on_dir)
                    -- Try to find Nx workspace root first
                    local root = vim.fs.root(bufnr, { 'nx.json' })
                    if root then
                        on_dir(root)
                        return
                    end

                    -- Fallback to Angular workspace
                    root = vim.fs.root(bufnr, { 'angular.json', 'project.json' })
                    if root then
                        on_dir(root)
                    end
                end,
            })

            vim.lsp.config('nushell', { capabilities = capabilities })
            vim.lsp.config('html', { capabilities = capabilities })
            vim.lsp.config('lua_ls', { capabilities = capabilities })
            vim.lsp.config('stylelint_lsp', { capabilities = capabilities })

            vim.lsp.config('nixd', { capabilities = capabilities })
            vim.lsp.enable 'nixd'

            -- LSP keymaps
            vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = 'Show LSP hover information' })
            vim.keymap.set('n', '<leader>gd', vim.lsp.buf.definition, { desc = 'Go to definition' })
            vim.keymap.set('n', '<leader>gr', vim.lsp.buf.references, { desc = 'Find references' })
            vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { desc = 'Code actions' })

            -- Diagnostic keymaps
            local function jump_to_diagnostic(count)
                vim.diagnostic.jump {
                    count = count,
                    on_jump = function(_, bufnr)
                        vim.diagnostic.open_float { bufnr = bufnr, scope = 'cursor', focus = false }
                    end,
                }
            end
            vim.keymap.set('n', '[d', function()
                jump_to_diagnostic(-1)
            end, { desc = 'Go to previous diagnostic message' })
            vim.keymap.set('n', ']d', function()
                jump_to_diagnostic(1)
            end, { desc = 'Go to next diagnostic message' })
            vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
            vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })
        end,
    },
    {
        'nvimdev/lspsaga.nvim',
        config = function()
            require('lspsaga').setup {}
        end,
        dependencies = {
            'nvim-treesitter/nvim-treesitter',
            'nvim-tree/nvim-web-devicons',
        },
    },
}
