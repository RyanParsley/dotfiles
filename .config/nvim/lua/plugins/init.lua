return {
    'tpope/vim-fugitive', 'tpope/vim-rhubarb', 'evanleck/vim-svelte',
    'aserowy/tmux.nvim', 'tpope/vim-sleuth', 'sbdchd/neoformat',
    'nvim-tree/nvim-web-devicons', 'Canop/nvim-bacon', 'mattn/webapi-vim', {
        'numToStr/Comment.nvim',
        opts = {
            -- add any options here
        },
        lazy = false
    }, {
        'jay-babu/mason-null-ls.nvim',
        event = {'BufReadPre', 'BufNewFile'},
        dependencies = {
            'williamboman/mason.nvim', 'jose-elias-alvarez/null-ls.nvim'
        },
        config = function()
            -- require("your.null-ls.config") -- require your null-ls config here (example below)
        end
    }, {
        'folke/which-key.nvim',
        config = function()
            require('which-key').setup {
                -- your configuration comes here
                -- or leave it empty to use the default settings
                -- refer to the configuration section below
            }
        end
    }, {
        -- Add indentation guides even on blank lines
        'lukas-reineke/indent-blankline.nvim',
        -- Enable `lukas-reineke/indent-blankline.nvim`
        -- See `:help indent_blankline.txt`
        main = 'ibl',
        opts = {}
    }, {'willothy/wezterm.nvim', config = true}
}
