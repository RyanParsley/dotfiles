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
