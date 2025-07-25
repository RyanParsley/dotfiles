return {
    'joeveiga/ng.nvim',
    'mfussenegger/nvim-jdtls',
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
            automatic_enable = true,
            ensure_installed = {
                'angularls',
                'bashls',
                'html',
                'gradle_ls',
                'lua_ls',
                'jdtls',
                'marksman',
                'quick_lint_js',
                'rust_analyzer',
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
            local capabilities = require('cmp_nvim_lsp').default_capabilities()
            local capabilities_oxide = capabilities
            capabilities_oxide.workspace = {
                didChangeWatchedFiles = { dynamicRegistration = true },
            }
            require('mason').setup()
            require('mason-tool-installer').setup {
                -- Install these linters, formatters, debuggers automatically
                ensure_installed = {},
            }
            -- There is an issue with mason-tools-installer running with VeryLazy, since it triggers on VimEnter which has already occurred prior to this plugin loading so we need to call install explicitly
            -- https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim/issues/39
            vim.api.nvim_command 'MasonToolsInstall'
            local lspconfig = require 'lspconfig'
            local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()
            local lsp_attach = function(client, bufnr)
                -- Create your keybindings here...
            end

            require('lspconfig').astro.setup {
                capabilities = capabilities,
                init_options = {},
                settings = {
                    inlay_hints = true, -- enable/disable inlay hints on start
                    typescript = {
                        inlayHints = {
                            includeInlayParameterNameHints = 'all',
                            includeInlayParameterNameHintsWhenArgumentMatchesName = true,
                            includeInlayFunctionParameterTypeHints = true,
                            includeInlayVariableTypeHints = true,
                            includeInlayVariableTypeHintsWhenTypeMatchesName = true,
                            includeInlayPropertyDeclarationTypeHints = true,
                            includeInlayFunctionLikeReturnTypeHints = true,
                            includeInlayEnumMemberValueHints = true,
                        },
                    },
                },
            }
            lspconfig.eslint.setup { capabilities = capabilities }
            lspconfig.markdown_oxide.setup {
                on_attach = function(client, bufnr)
                    local function check_codelens_support()
                        local clients = vim.lsp.get_active_clients { bufnr = 0 }
                        for _, c in ipairs(clients) do
                            if c.server_capabilities.codeLensProvider then
                                return true
                            end
                        end
                        return false
                    end
                    -- refresh codelens on TextChanged and InsertLeave as well
                    vim.api.nvim_create_autocmd(
                        { 'TextChanged', 'InsertLeave', 'CursorHold', 'LspAttach', 'BufEnter' },
                        {
                            buffer = bufnr,
                            callback = function()
                                if check_codelens_support() then
                                    vim.lsp.codelens.refresh { bufnr = 0 }
                                end
                            end,
                        }
                    )
                    -- trigger codelens refresh
                    vim.api.nvim_exec_autocmds('User', { pattern = 'LspAttached' })
                    -- setup Markdown Oxide daily note commands
                    if client.name == 'markdown_oxide' then
                        vim.api.nvim_create_user_command('Daily', function(args)
                            local input = args.args

                            vim.lsp.buf.execute_command { command = 'jump', arguments = { input } }
                        end, { desc = 'Open daily note', nargs = '*' })
                    end
                end,
                capabilities = capabilities_oxide,
                filetypes = { 'markdown' },
                root_dir = lspconfig.util.root_pattern('.git', '.obsidian', '.moxide.toml'),
                cmd = { 'markdown-oxide' },
            }
            lspconfig.angularls.setup {
                on_attach = function(_, bufnr)
                    -- refresh codelens on TextChanged and InsertLeave as well
                    vim.api.nvim_create_autocmd({
                        'TextChanged',
                        'InsertLeave',
                        'CursorHold',
                        'LspAttach',
                    }, { buffer = bufnr, callback = vim.lsp.codelens.refresh })

                    -- trigger codelens refresh
                    vim.api.nvim_exec_autocmds('User', { pattern = 'LspAttached' })
                end,
            }
            lspconfig.ts_ls.setup {
                capabilities = capabilities,
                on_attach = function(client)
                    if client.server_capabilities.inlayHintProvider then
                        vim.lsp.inlay_hint.enable(true)
                    end
                end,
                settings = {
                    typescript = {
                        tsdk = vim.fn.stdpath 'data' .. '/mason/packages/typescript/lib', -- Path to TypeScript SDK
                        inlayHints = {
                            includeInlayParameterNameHints = 'all',
                            includeInlayParameterNameHintsWhenArgumentMatchesName = true,
                            includeInlayFunctionParameterTypeHints = true,
                            includeInlayVariableTypeHints = true,
                            includeInlayVariableTypeHintsWhenTypeMatchesName = true,
                            includeInlayPropertyDeclarationTypeHints = true,
                            includeInlayFunctionLikeReturnTypeHints = true,
                            includeInlayEnumMemberValueHints = true,
                        },
                    },
                    javascript = {
                        inlayHints = {
                            includeInlayParameterNameHints = 'all',
                            includeInlayParameterNameHintsWhenArgumentMatchesName = true,
                            includeInlayFunctionParameterTypeHints = true,
                            includeInlayVariableTypeHints = true,
                            includeInlayVariableTypeHintsWhenTypeMatchesName = true,
                            includeInlayPropertyDeclarationTypeHints = true,
                            includeInlayFunctionLikeReturnTypeHints = true,
                            includeInlayEnumMemberValueHints = true,
                        },
                    },
                },
            }
            lspconfig.nushell.setup { capabilities = capabilities }
            lspconfig.html.setup { capabilities = capabilities }
            lspconfig.lua_ls.setup { capabilities = capabilities }
            lspconfig.stylelint_lsp.setup {
                capabilities = capabilities,
                settings = {
                    stylelintplus = {
                        autoFixOnSave = true,
                        autoFixOnFormat = true,
                    },
                },
            }
            vim.keymap.set('n', 'K', vim.lsp.buf.hover, {})
            vim.keymap.set('n', '<leader>gd', vim.lsp.buf.definition, {})
            vim.keymap.set('n', '<leader>gr', vim.lsp.buf.references, {})
            vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, {})

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
