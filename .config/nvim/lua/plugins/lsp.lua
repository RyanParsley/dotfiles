return {
    'joeveiga/ng.nvim',
    'nvim-java/nvim-java',
    {
        'williamboman/mason.nvim',
        lazy = false,
        config = function()
            require('mason').setup()
        end,
        opts = { ensure_installed = { 'java-debug-adapter', 'java-test' } },
    },
    {
        'williamboman/mason-lspconfig.nvim',
        lazy = false,
        opts = { auto_install = true },
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
            { 'folke/neodev.nvim', opts = {} },
        },
        opts = {
            inlay_hints = { enabled = true },
            servers = {
                jdtls = {},
            },
            setup = {
                jdtls = function()
                    return true -- avoid duplicate servers
                end,
            },
        },
        config = function()
            local capabilities = require('cmp_nvim_lsp').default_capabilities()
            local capabilities_oxide = capabilities
            capabilities_oxide.workspace = {
                didChangeWatchedFiles = { dynamicRegistration = true },
            }
            require('mason').setup()
            require('mason-lspconfig').setup {
                -- Install these LSPs automatically
                ensure_installed = {
                    'bashls',
                    'html',
                    'gradle_ls',
                    'lua_ls',
                    'jdtls',
                    'marksman',
                    'quick_lint_js',
                    'yamlls',
                },
            }
            require('mason-tool-installer').setup {
                -- Install these linters, formatters, debuggers automatically
                ensure_installed = {
                    'java-debug-adapter',
                    'java-test',
                },
            }
            -- There is an issue with mason-tools-installer running with VeryLazy, since it triggers on VimEnter which has already occurred prior to this plugin loading so we need to call install explicitly
            -- https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim/issues/39
            vim.api.nvim_command 'MasonToolsInstall'
            local lspconfig = require 'lspconfig'
            local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()
            local lsp_attach = function(client, bufnr)
                -- Create your keybindings here...
            end

            require('mason-lspconfig').setup_handlers {
                function(server_name)
                    -- Don't call setup for JDTLS Java LSP because it will be setup from a separate config
                    if server_name ~= 'jdtls' then
                        lspconfig[server_name].setup {
                            on_attach = lsp_attach,
                            capabilities = lsp_capabilities,
                        }
                    end
                end,
            }

            require('neodev').setup()
            require('lspconfig').jdtls.setup {}
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
                on_attach = function(client, bufnr)
                    if client.server_capabilities.inlayHintProvider then
                        vim.lsp.inlay_hint.enable(true)
                    end
                end,
                settings = {
                    implicitProjectConfiguration = { checkJs = true },
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
