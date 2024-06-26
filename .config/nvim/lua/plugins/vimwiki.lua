local note_dir = '~/Notes'
local home = vim.fn.expand(note_dir)
local templates = vim.fn.expand(home) .. '/templates/telekasten'

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
        'renerocksai/telekasten.nvim',
        dependencies = {
            'nvim-telescope/telescope.nvim',
            'renerocksai/calendar-vim',
        },
        config = function()
            require('telekasten').setup {
                home = vim.fn.expand '~/Notes',
                dailies = home .. '/Journal/daily/' .. os.date '%Y/%m-%B/',
                weeklies = home .. '/Journal/weekly/' .. os.date '%Y/',
                template_new_daily = templates .. 'daily-template.md',
                template_new_weekly = templates .. 'weekly-template.md',
            }

            -- Launch panel if nothing is typed after <leader>z
            -- vim.keymap.set("n", "<leader>z", "<cmd>Telekasten panel<CR>")

            -- Most used functions
            vim.keymap.set('n', '<leader>zf', '<cmd>Telekasten find_notes<CR>')
            vim.keymap.set('n', '<leader>zg', '<cmd>Telekasten search_notes<CR>')
            vim.keymap.set('n', '<leader>zd', '<cmd>Telekasten goto_today<CR>')
            vim.keymap.set('n', '<leader>zz', '<cmd>Telekasten follow_link<CR>')
            vim.keymap.set('n', '<leader>zn', '<cmd>Telekasten new_note<CR>')
            vim.keymap.set('n', '<leader>zc', '<cmd>Telekasten show_calendar<CR>')
            vim.keymap.set('n', '<leader>zb', '<cmd>Telekasten show_backlinks<CR>')
            vim.keymap.set('n', '<leader>zI', '<cmd>Telekasten insert_img_link<CR>')

            -- Call insert link automatically when we start typing a link
            vim.keymap.set('i', '[[', '<cmd>Telekasten insert_link<CR>')
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
