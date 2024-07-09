return {
    {
        'iamcco/markdown-preview.nvim',
        cmd = {
            'MarkdownPreviewToggle',
            'MarkdownPreview',
            'MarkdownPreviewStop',
        },
        build = function()
            vim.fn['mkdp#util#install']()
        end,
        keys = {
            {
                '<leader>cp',
                ft = 'markdown',
                '<cmd>MarkdownPreviewToggle<cr>',
                desc = 'Markdown Preview',
            },
        },
        config = function()
            vim.cmd [[do FileType]]
        end,
    },
    {
        'ribelo/taskwarrior.nvim',
        opts = {
            -- your configuration comes here
            -- or leave it empty to use the default settings
            -- refer to the configuration section below
        },
        -- or
        config = true,
    },
    {
        'lukas-reineke/headlines.nvim',
        dependencies = 'nvim-treesitter/nvim-treesitter',
        opts = function()
            local opts = {}
            for _, ft in ipairs { 'markdown', 'norg', 'rmd', 'org', 'telekasten' } do
                opts[ft] = {
                    headline_highlights = {},
                    -- disable bullets for now. See https://github.com/lukas-reineke/headlines.nvim/issues/66
                    bullets = {},
                }
                for i = 1, 6 do
                    local hl = 'Headline' .. i
                    vim.api.nvim_set_hl(0, hl, { link = 'Headline', default = true })
                    table.insert(opts[ft].headline_highlights, hl)
                end
            end
            return opts
        end,
        ft = { 'markdown', 'norg', 'rmd', 'org', 'telekasten' },
        config = function(_, opts)
            -- PERF: schedule to prevent headlines slowing down opening a file
            vim.schedule(function()
                require('headlines').setup(opts)
                require('headlines').refresh()
            end)
        end,
    },
}
