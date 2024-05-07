return {
    'simrat39/inlay-hints.nvim',
    'lvimuser/lsp-inlayhints.nvim',
    'joeveiga/ng.nvim',
    {
        'williamboman/mason.nvim',
        lazy = false,
        config = function() require('mason').setup() end
    },
    {
        'williamboman/mason-lspconfig.nvim',
        lazy = false,
        opts = {auto_install = true}
    },
    {
        'neovim/nvim-lspconfig',
        lazy = false,
        dependencies = {
            -- Automatically install LSPs to stdpath for neovim
            'williamboman/mason.nvim',
            'williamboman/mason-lspconfig.nvim',

            -- Useful status updates for LSP
            -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
            {'j-hui/fidget.nvim', tag = 'legacy', opts = {}},

            -- Additional lua configuration, makes nvim stuff amazing!
            'folke/neodev.nvim',
            'simrat39/inlay-hints.nvim',
            'lvimuser/lsp-inlayhints.nvim'
        },
        opts = {inlay_hints = {enabled = true}},
        config = function()
            local capabilities = require('cmp_nvim_lsp').default_capabilities()
            local capabilities_oxide = capabilities
            capabilities_oxide.workspace = {
                didChangeWatchedFiles = {dynamicRegistration = true}
            }

            require('neodev').setup()

            local lspconfig = require 'lspconfig'
            lspconfig.eslint.setup {capabilities = capabilities}
            lspconfig.markdown_oxide.setup {
                on_attach = function(_, bufnr)
                    -- refresh codelens on TextChanged and InsertLeave as well
                    vim.api.nvim_create_autocmd({
                        'TextChanged',
                        'InsertLeave',
                        'CursorHold',
                        'LspAttach'
                    }, {buffer = bufnr, callback = vim.lsp.codelens.refresh})

                    -- trigger codelens refresh
                    vim.api
                        .nvim_exec_autocmds('User', {pattern = 'LspAttached'})
                end,
                capabilities = capabilities_oxide,
                filetypes = {'markdown'},
                root_dir = lspconfig.util.root_pattern('.git', '.obsidian',
                                                       '.moxide.toml', '*.md'),
                cmd = {'markdown-oxide'}
            }
            lspconfig.angularls.setup {
                on_attach = function(_, bufnr)
                    -- refresh codelens on TextChanged and InsertLeave as well
                    vim.api.nvim_create_autocmd({
                        'TextChanged',
                        'InsertLeave',
                        'CursorHold',
                        'LspAttach'
                    }, {buffer = bufnr, callback = vim.lsp.codelens.refresh})

                    -- trigger codelens refresh
                    vim.api
                        .nvim_exec_autocmds('User', {pattern = 'LspAttached'})
                end
            }
            lspconfig.tsserver.setup {
                capabilities = capabilities,
                on_attach = function(client, bufnr)
                    require('lsp-inlayhints').on_attach(client, bufnr)
                    require('inlay-hints').on_attach(client, bufnr)
                    if client.server_capabilities.inlayHintProvider then
                        vim.lsp.inlay_hint.enable(bufnr, true)
                    end
                end,
                settings = {
                    implicitProjectConfiguration = {checkJs = true},
                    javascript = {
                        {format = {enable = true}},
                        inlayHints = {
                            includeInlayEnumMemberValueHints = true,
                            includeInlayFunctionLikeReturnTypeHints = true,
                            includeInlayFunctionParameterTypeHints = true,
                            includeInlayParameterNameHints = 'all', -- 'none' | 'literals' | 'all';
                            includeInlayParameterNameHintsWhenArgumentMatchesName = true,
                            includeInlayPropertyDeclarationTypeHints = true,
                            includeInlayVariableTypeHints = true
                        }
                    },
                    typescript = {
                        {format = {enable = true}},
                        inlayHints = {
                            includeInlayEnumMemberValueHints = true,
                            includeInlayFunctionLikeReturnTypeHints = true,
                            includeInlayFunctionParameterTypeHints = true,
                            includeInlayParameterNameHints = 'all', -- 'none' | 'literals' | 'all';
                            includeInlayParameterNameHintsWhenArgumentMatchesName = true,
                            includeInlayPropertyDeclarationTypeHints = true,
                            includeInlayVariableTypeHints = true
                        }
                    }
                }
            }
            lspconfig.nushell.setup {capabilities = capabilities}
            lspconfig.html.setup {capabilities = capabilities}
            lspconfig.lua_ls.setup {capabilities = capabilities}
            lspconfig.stylelint_lsp.setup {
                capabilities = capabilities,
                settings = {
                    stylelintplus = {
                        autoFixOnSave = true,
                        autoFixOnFormat = true
                    }
                }
            }
            vim.keymap.set('n', 'K', vim.lsp.buf.hover, {})
            vim.keymap.set('n', '<leader>gd', vim.lsp.buf.definition, {})
            vim.keymap.set('n', '<leader>gr', vim.lsp.buf.references, {})
            vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, {})

            -- Diagnostic keymaps
            vim.keymap.set('n', '[d', vim.diagnostic.goto_prev,
                           {desc = 'Go to previous diagnostic message'})
            vim.keymap.set('n', ']d', vim.diagnostic.goto_next,
                           {desc = 'Go to next diagnostic message'})
            vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float,
                           {desc = 'Open floating diagnostic message'})
            vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist,
                           {desc = 'Open diagnostics list'})
        end
    },
    {
        'nvimdev/lspsaga.nvim',
        config = function() require('lspsaga').setup {} end,
        dependencies = {
            'nvim-treesitter/nvim-treesitter',
            'nvim-tree/nvim-web-devicons'
        }
    }
}
