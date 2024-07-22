return {
    'zapling/mason-conform.nvim',
    'zaid/vim-rec',
    'tpope/vim-fugitive',
    'tpope/vim-rhubarb',
    'evanleck/vim-svelte',
    'aserowy/tmux.nvim',
    'tpope/vim-sleuth',
    'nvim-tree/nvim-web-devicons',
    'Canop/nvim-bacon',
    'nvim-neotest/nvim-nio',
    'mattn/webapi-vim',
    {
        'numToStr/Comment.nvim',
        opts = {
            -- add any options here
        },
        lazy = false,
    },
    {
        'folke/which-key.nvim',
        config = function()
            require('which-key').setup {
                -- your configuration comes here
                -- or leave it empty to use the default settings
                -- refer to the configuration section below
            }
        end,
    },
    {
        -- Add indentation guides even on blank lines
        'lukas-reineke/indent-blankline.nvim',
        -- Enable `lukas-reineke/indent-blankline.nvim`
        -- See `:help indent_blankline.txt`
        main = 'ibl',
        opts = {},
    }, -- Highlight todo, notes, etc in comments
    {
        'folke/todo-comments.nvim',
        event = 'VimEnter',
        dependencies = { 'nvim-lua/plenary.nvim' },
        opts = { signs = false },
    },
    { 'nvim-neorg/neorg', opts = {} },
}
