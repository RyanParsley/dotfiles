return {
    'joeveiga/ng.nvim',
    {
        'williamboman/mason.nvim',
        lazy = false,
        config = function()
            require('mason').setup()
        end,
        opts = {
            ensure_installed = {
                'js-debug-adapter',
            },
        },
    },
    {
        'williamboman/mason-lspconfig.nvim',
        lazy = false,
        opts = {
            auto_install = true,
            ensure_installed = {
                'angularls',
                'astro',
                'bashls',
                'html',
                'lua_ls',
                'marksman',
                'quick_lint_js',
                'rust_analyzer',
                'ts_ls',
                'yamlls',
            },
        },
    },
    {
        'neovim/nvim-lspconfig',
        lazy = false,
        dependencies = {
            -- Automatically install LSPs and related tools to stdpath for Neovim
            { 'williamboman/mason.nvim', config = true }, -- NOTE: Must be loaded before dependants
            'williamboman/mason-lspconfig.nvim',
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
                -- Enable inlay hints if supported
                if client.server_capabilities.inlayHintProvider then
                    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
                    -- Refresh inlay hints after a short delay
                    vim.defer_fn(function()
                        if vim.lsp.inlay_hint.refresh then
                            vim.lsp.inlay_hint.refresh { bufnr = bufnr }
                        end
                    end, 1000)
                end

                -- Set up codelens refresh for supported servers
                if client.server_capabilities.codeLensProvider then
                    local codelens_group = vim.api.nvim_create_augroup('lsp_codelens_' .. bufnr, { clear = true })
                    vim.api.nvim_create_autocmd(
                        { 'TextChanged', 'InsertLeave', 'CursorHold', 'LspAttach', 'BufEnter' },
                        {
                            buffer = bufnr,
                            group = codelens_group,
                            callback = function()
                                vim.lsp.codelens.refresh { bufnr = bufnr }
                            end,
                            desc = 'Refresh LSP codelens',
                        }
                    )
                    -- Trigger initial codelens refresh
                    vim.api.nvim_exec_autocmds('User', { pattern = 'LspAttached' })
                end
            end

            require('mason').setup()
            require('mason-tool-installer').setup {
                -- Install these linters, formatters, debuggers automatically
                ensure_installed = {},
            }
            -- There is an issue with mason-tools-installer running with VeryLazy, since it triggers on VimEnter which has already occurred prior to this plugin loading so we need to call install explicitly
            -- https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim/issues/39
            vim.cmd 'MasonToolsInstall'

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
                            vim.lsp.buf.execute_command { command = 'jump', arguments = { input } }
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
                filetypes = { 'typescript', 'html', 'typescriptreact', 'typescript.tsx', 'html.angular' },
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
            vim.lsp.config('stylelint_lsp', {
                capabilities = capabilities,
                settings = {
                    stylelintplus = {
                        autoFixOnSave = true,
                        autoFixOnFormat = true,
                    },
                },
            })

            -- LSP keymaps
            vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = 'Show LSP hover information' })
            vim.keymap.set('n', '<leader>gd', vim.lsp.buf.definition, { desc = 'Go to definition' })
            vim.keymap.set('n', '<leader>gr', vim.lsp.buf.references, { desc = 'Find references' })
            vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { desc = 'Code actions' })

            -- Diagnostic keymaps
            vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
            vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
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
