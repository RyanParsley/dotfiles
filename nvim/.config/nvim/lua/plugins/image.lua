return {
    {
        '3rd/image.nvim',
        dependencies = {
            {
                'nvim-treesitter/nvim-treesitter',
                build = ':TSUpdate',
                config = function()
                    require('nvim-treesitter.configs').setup {
                        ensure_installed = { 'markdown' },
                        highlight = { enable = true },
                    }
                end,
            },
        },
        opts = {
            -- "ueberzug" or "kitty"
            backend = 'kitty',
            processor = 'magick_cli', -- or "magick_rock"
            integrations = {
                markdown = {
                    only_render_image_at_cursor = true,
                    only_render_image_at_cursor_mode = 'inline', -- "popup" or "inline", defaults to "popup"
                },
            },
        },
    },
    {
        'adelarsq/image_preview.nvim',
        event = 'VeryLazy',
        config = function()
            require('image_preview').setup()
        end,
    },
}
