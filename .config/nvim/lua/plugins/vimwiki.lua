local note_dir = '~/Notes'
local home = vim.fn.expand(note_dir)
local templates = vim.fn.expand(home) .. '/templates/telekasten'

return {
    {
        "iamcco/markdown-preview.nvim",
        cmd = {
            "MarkdownPreviewToggle",
            "MarkdownPreview",
            "MarkdownPreviewStop"
        },
        ft = {"markdown"},
        build = function() vim.fn["mkdp#util#install"]() end
    },
    {
        'vimwiki/vimwiki',
        init = function()
            vim.g.vimwiki_list = {
                {
                    name = 'notes',
                    path = note_dir,
                    syntax = 'markdown',
                    ext = '.md'
                }
            }
        end
    },
    {
        "zk-org/zk-nvim",
        config = function()
            require("zk").setup({
                -- can be "telescope", "fzf", "fzf_lua" or "select" (`vim.ui.select`)
                -- it's recommended to use "telescope", "fzf" or "fzf_lua"
                picker = "telescope",

                lsp = {
                    -- `config` is passed to `vim.lsp.start_client(config)`
                    config = {
                        cmd = {"zk", "lsp"},
                        name = "zk"
                        -- on_attach = ...
                        -- etc, see `:h vim.lsp.start_client()`
                    },

                    -- automatically attach buffers in a zk notebook that match the given filetypes
                    auto_attach = {enabled = true, filetypes = {"markdown"}}
                }
            })
        end
    },
    {
        'renerocksai/telekasten.nvim',
        dependencies = {
            'nvim-telescope/telescope.nvim',
            'renerocksai/calendar-vim'
        },
        config = function()
            require('telekasten').setup({
                home = home,
                dailies = home .. '/journal/' .. 'daily',
                weeklies = home .. '/journal/' .. 'weekly',
                template_new_daily = templates .. 'daily-template.md',
                template_new_weekly = templates .. 'weekly-template.md'
            })

            -- Launch panel if nothing is typed after <leader>z
            -- vim.keymap.set("n", "<leader>z", "<cmd>Telekasten panel<CR>")

            -- Most used functions
            vim.keymap.set("n", "<leader>zf", "<cmd>Telekasten find_notes<CR>")
            vim.keymap
                .set("n", "<leader>zg", "<cmd>Telekasten search_notes<CR>")
            vim.keymap.set("n", "<leader>zd", "<cmd>Telekasten goto_today<CR>")
            vim.keymap.set("n", "<leader>zz", "<cmd>Telekasten follow_link<CR>")
            vim.keymap.set("n", "<leader>zn", "<cmd>Telekasten new_note<CR>")
            vim.keymap.set("n", "<leader>zc",
                           "<cmd>Telekasten show_calendar<CR>")
            vim.keymap.set("n", "<leader>zb",
                           "<cmd>Telekasten show_backlinks<CR>")
            vim.keymap.set("n", "<leader>zI",
                           "<cmd>Telekasten insert_img_link<CR>")

            -- Call insert link automatically when we start typing a link
            vim.keymap.set("i", "[[", "<cmd>Telekasten insert_link<CR>")
        end
    },
    {
        "ribelo/taskwarrior.nvim",
        opts = {
            -- your configuration comes here
            -- or leave it empty to use the default settings
            -- refer to the configuration section below
        },
        -- or 
        config = true
    }
}
