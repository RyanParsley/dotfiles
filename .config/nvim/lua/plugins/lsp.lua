return {
    {
        'williamboman/mason.nvim',
        lazy = false,
        config = function() require('mason').setup() end
    }, {
        'williamboman/mason-lspconfig.nvim',
        lazy = false,
        opts = {auto_install = true}
    }, {
        'neovim/nvim-lspconfig',
        lazy = false,
        dependencies = {
            -- Automatically install LSPs to stdpath for neovim
            'williamboman/mason.nvim', 'williamboman/mason-lspconfig.nvim',

            -- Useful status updates for LSP
            -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
            {'j-hui/fidget.nvim', tag = 'legacy', opts = {}},

            -- Additional lua configuration, makes nvim stuff amazing!
            'folke/neodev.nvim'
        },
        config = function()
            local capabilities = require('cmp_nvim_lsp').default_capabilities()
            require('neodev').setup()

            local lspconfig = require('lspconfig')
            lspconfig.tsserver.setup({
                capabilities = capabilities,
                settings = {typescript = {format = {enable = true}}}
            })
            lspconfig.html.setup({capabilities = capabilities})
            lspconfig.lua_ls.setup({capabilities = capabilities})
            lspconfig.stylelint_lsp.setup({
                capabilities = capabilities,
                settings = {
                    stylelintplus = {
                        autoFixOnSave = true,
                        autoFixOnFormat = true
                    }
                }
            })
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
    }
}
