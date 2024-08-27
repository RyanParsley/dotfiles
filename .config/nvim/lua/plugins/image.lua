return {
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
}
