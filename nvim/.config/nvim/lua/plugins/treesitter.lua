local parsers = {
    'angular',
    'astro',
    'bash',
    'c',
    'comment',
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
    'nix',
    'nu',
    'python',
    'regex',
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
        config = function()
            require('nvim-treesitter').install(parsers)

            -- Highlighting and indentation are opt-in as of the nvim-treesitter
            -- "main" branch rewrite; the plugin no longer enables them for you.
            vim.api.nvim_create_autocmd('FileType', {
                pattern = '*',
                callback = function()
                    local ok = pcall(vim.treesitter.start)
                    if ok then
                        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                    end
                end,
            })
        end,
    },
    {
        'nvim-treesitter/nvim-treesitter-textobjects',
        branch = 'main',
        dependencies = { 'nvim-treesitter/nvim-treesitter' },
        init = function()
            vim.g.no_plugin_maps = true
        end,
        config = function()
            require('nvim-treesitter-textobjects').setup {
                select = {
                    lookahead = true,
                },
                move = {
                    set_jumps = true,
                },
            }

            local select = require 'nvim-treesitter-textobjects.select'
            local move = require 'nvim-treesitter-textobjects.move'
            local swap = require 'nvim-treesitter-textobjects.swap'

            local function select_map(lhs, query, desc)
                vim.keymap.set({ 'x', 'o' }, lhs, function()
                    select.select_textobject(query, 'textobjects')
                end, { desc = desc })
            end

            select_map('aa', '@parameter.outer', 'Select outer parameter')
            select_map('ia', '@parameter.inner', 'Select inner parameter')
            select_map('af', '@function.outer', 'Select outer function')
            select_map('if', '@function.inner', 'Select inner function')
            select_map('ac', '@class.outer', 'Select outer class')
            select_map('ic', '@class.inner', 'Select inner class')

            local function move_map(lhs, fn, query, desc)
                vim.keymap.set({ 'n', 'x', 'o' }, lhs, function()
                    fn(query, 'textobjects')
                end, { desc = desc })
            end

            move_map(']m', move.goto_next_start, '@function.outer', 'Next function start')
            move_map(']]', move.goto_next_start, '@class.outer', 'Next class start')
            move_map(']M', move.goto_next_end, '@function.outer', 'Next function end')
            move_map('][', move.goto_next_end, '@class.outer', 'Next class end')
            move_map('[m', move.goto_previous_start, '@function.outer', 'Previous function start')
            move_map('[[', move.goto_previous_start, '@class.outer', 'Previous class start')
            move_map('[M', move.goto_previous_end, '@function.outer', 'Previous function end')
            move_map('[]', move.goto_previous_end, '@class.outer', 'Previous class end')

            vim.keymap.set('n', '<leader>a', function()
                swap.swap_next '@parameter.inner'
            end, { desc = 'Swap with next parameter' })
            vim.keymap.set('n', '<leader>A', function()
                swap.swap_previous '@parameter.inner'
            end, { desc = 'Swap with previous parameter' })
        end,
    },
}
