return {
    {
        'stevearc/conform.nvim',
        event = { 'BufReadPost', 'BufWritePost', 'BufNewFile' },
        dependencies = { 'mason.nvim' },
        lazy = true,
        cmd = 'ConformInfo',
        keys = {
            {
                '<leader>f',
                function()
                    require('conform').format {
                        async = true,
                        lsp_format = 'fallback',
                    }
                end,
                mode = '',
                desc = '[F]ormat buffer',
            },
        },
        opts = {
            formatters_by_ft = {
                lua = { 'stylua' },
                fish = { 'fish_indent' },
                sh = { 'shfmt' },
                java = { 'prettierd', 'prettier', stop_after_first = true },
                javascript = { 'prettierd', 'prettier', stop_after_first = true },
                typescript = { 'prettierd', 'prettier', stop_after_first = true },
                ['markdown'] = { 'prettierd', 'prettier', stop_after_first = true },
                ['markdown.mdx'] = { 'prettierd', 'prettier', stop_after_first = true },
                python = { "isort", "black" },
            },
            default_format_opts = {
                lsp_format = 'fallback',
            },
            format_on_save = {
                timeout_ms = 1000,
            },
        },
    },
    {
        'mfussenegger/nvim-lint',
        event = { 'BufReadPost', 'BufWritePost', 'BufNewFile' },
        opts = {
            linters_by_ft = {
                fish = { 'fish' },
                markdown = { 'markdownlint-cli2' },
                java = { 'checkstyle' },
                javascript = { 'eslint_d' },
                typescript = { 'eslint_d' },
            },
        },
        config = function() end,
    },
}
