return {
    {
        'shaunsingh/nord.nvim',
        priority = 1000,
        config = function() vim.cmd.colorscheme 'nord' end
    }, { -- Set lualine as statusline
        'nvim-lualine/lualine.nvim',
        -- See `:help lualine.txt`
        opts = {
            options = {
                icons_enabled = false,
                theme = 'nord',
                component_separators = '|',
                section_separators = ''
            }
        }
    },
    { -- Adds git releated signs to the gutter, as well as utilities for managing changes
        'lewis6991/gitsigns.nvim',
        opts = {
            -- See `:help gitsigns.txt`
            signs = {
                add = {text = '+'},
                change = {text = '~'},
                delete = {text = '_'},
                topdelete = {text = '‾'},
                changedelete = {text = '~'}
            }
        }
    }
}
