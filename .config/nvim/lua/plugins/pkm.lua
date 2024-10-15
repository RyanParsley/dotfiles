return {
    -- This config is mostly about markdown and things that enrich a markdown
    -- centric PKM.
    --
    -- I'm not sure if I want both obsidian.nvim and Markdown Oxide. I'm a
    -- little unclear on where one stops and the other starts, but they seem to
    -- play nice together.
    --
    -- Telekasten looked interesting/ useful, but didn't see a ton of value
    -- coming from it in practice so recently removed it.
    --
    -- Markdown Oxide config mostly lives in the lsp configuration file.
    --
    {
        'epwalsh/obsidian.nvim',
        version = '*', -- recommended, use latest release instead of latest commit
        lazy = true,
        ft = 'markdown',
        -- event = { "BufReadPre Users/ryan/Notes/**.md" },
        -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand':
        -- event = { "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/**.md" },
        dependencies = {
            -- Required.
            'nvim-lua/plenary.nvim',
        },
        opts = {
            dir = '~/Notes', -- no need to call 'vim.fn.expand' here
            daily_notes = {
                -- Optional, if you keep daily notes in a separate directory.
                folder = 'Journal/Daily',
            },
            templates = { subdir = 'templates' },
            use_advanced_uri = true,
            -- Optional, by default when you use `:ObsidianFollowLink` on a link to an external
            -- URL it will be ignored but you can customize this behavior here.
            follow_url_func = function(url)
                -- Open the URL in the default web browser.
                vim.fn.jobstart { 'open', url } -- Mac OS
                -- vim.fn.jobstart({"xdg-open", url})  -- linux
            end,
            ui = {
                enable = false,
            },
        },
        keys = {
            {
                '<leader>nn',
                '<cmd>ObsidianNew<cr>',
                desc = 'Obsidian - New Note',
            },
            {
                '<leader>nt',
                '<cmd>ObsidianNewFromTemplate<cr>',
                desc = 'Obsidian - New From Template',
            },
            {
                '<leader>nm',
                function()
                    local input = vim.fn.input 'Meeting Name: '
                    vim.cmd('ObsidianNewFromTemplate notes/meetings/' .. input .. '.md')
                end,
                desc = 'Obsidian - New Meeting',
            },
            {
                '<leader>it',
                '<cmd>ObsidianTemplate<cr>',
                desc = 'Obsidian - Insert Template',
            },
        },
    },
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
        'MeanderingProgrammer/render-markdown.nvim',
        dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' }, -- if you use the mini.nvim suite
        -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
        -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
        ---@module 'render-markdown'
        ---@type render.md.UserConfig
    },
}
