return {
    {
        '3rd/image.nvim',
        build = false,
        cond = function()
            return #vim.api.nvim_list_uis() > 0
        end,
        dependencies = {
            'nvim-treesitter/nvim-treesitter',
        },
        opts = {
            backend = 'kitty',
            -- Zellij supports standard Kitty placements, not Unicode placeholders.
            kitty_method = 'normal',
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
