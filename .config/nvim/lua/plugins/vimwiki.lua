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
