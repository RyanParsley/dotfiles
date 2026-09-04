local parsers = {
    'angular',
    'astro',
    'bash',
    'c',
    'cpp',
    'css',
    'go',
    'html',
    'java',
    'javascript',
    'jq',
    'json',
    'lua',
    'markdown',
    'markdown_inline',
    'nu',
    'python',
    'rust',
    'scss',
    'svelte',
    'toml',
    'tsx',
    'typescript',
    'vim',
    'vimdoc',
    'yaml',
}

return {
    {
        'nvim-treesitter/nvim-treesitter',
        branch = 'main',
        lazy = false,
        build = ':TSUpdate',
        dependencies = {
            {
                'nvim-treesitter/nvim-treesitter-textobjects',
                branch = 'main',
                init = function()
                    vim.g.no_plugin_maps = true
                end,
            },
        },
        config = function()
            require('nvim-treesitter.configs').setup {
                ensure_installed = parsers,
                auto_install = true,
                highlight = { enable = true },
                indent = { enable = true },
                textobjects = {
                    select = {
                        enable = true,
                        lookahead = true,
                        keymaps = {
                            ['aa'] = { query = '@parameter.outer', desc = 'Select outer parameter' },
                            ['ia'] = { query = '@parameter.inner', desc = 'Select inner parameter' },
                            ['af'] = { query = '@function.outer', desc = 'Select outer function' },
                            ['if'] = { query = '@function.inner', desc = 'Select inner function' },
                            ['ac'] = { query = '@class.outer', desc = 'Select outer class' },
                            ['ic'] = { query = '@class.inner', desc = 'Select inner class' },
                         },
                    },
                    move = {
                        enable = true,
                        set_jumps = true,
                        goto_next_start = {
                            [']m'] = { query = '@function.outer', desc = 'Next function start' },
                            [']]'] = { query = '@class.outer', desc = 'Next class start' },
                         },
                        goto_next_end = {
                            [']M'] = { query = '@function.outer', desc = 'Next function end' },
                            [']['] = { query = '@class.outer', desc = 'Next class end' },
                         },
                        goto_previous_start = {
                            ['[m'] = { query = '@function.outer', desc = 'Previous function start' },
                            ['[['] = { query = '@class.outer', desc = 'Previous class start' },
                         },
                        goto_previous_end = {
                            ['[M'] = { query = '@function.outer', desc = 'Previous function end' },
                            ['[]'] = { query = '@class.outer', desc = 'Previous class end' },
                         },
                    },
                    swap = {
                        enable = true,
                        swap_next = {
                            ['<leader>a'] = '@parameter.inner',
                         },
                        swap_previous = {
                            ['<leader>A'] = '@parameter.inner',
                         },
                    },
                },
             }
        end,
    },
}
