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
            require('nvim-treesitter').install(parsers)
            require('nvim-treesitter-textobjects').setup {
                select = { lookahead = true },
                move = { set_jumps = true },
            }
            vim.treesitter.language.register('angular', 'htmlangular')

            local filetypes = {}
            for _, lang in ipairs(parsers) do
                vim.list_extend(filetypes, vim.treesitter.language.get_filetypes(lang))
            end

            vim.api.nvim_create_autocmd('FileType', {
                group = vim.api.nvim_create_augroup('treesitter_start', { clear = true }),
                pattern = vim.list.unique(filetypes),
                callback = function(args)
                    local lang = vim.treesitter.language.get_lang(args.match)
                    if not lang or not vim.treesitter.language.add(lang) then
                        return
                    end

                    vim.treesitter.start(args.buf, lang)
                    if lang == 'markdown' then
                        vim.bo[args.buf].syntax = 'ON'
                    end
                    if lang ~= 'python' and vim.treesitter.query.get(lang, 'indents') then
                        vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                    end
                end,
                desc = 'Enable Tree-sitter highlighting and indentation',
            })

            local select = require 'nvim-treesitter-textobjects.select'
            vim.keymap.set({ 'x', 'o' }, 'aa', function()
                select.select_textobject('@parameter.outer', 'textobjects')
            end, { desc = 'Select outer parameter' })
            vim.keymap.set({ 'x', 'o' }, 'ia', function()
                select.select_textobject('@parameter.inner', 'textobjects')
            end, { desc = 'Select inner parameter' })
            vim.keymap.set({ 'x', 'o' }, 'af', function()
                select.select_textobject('@function.outer', 'textobjects')
            end, { desc = 'Select outer function' })
            vim.keymap.set({ 'x', 'o' }, 'if', function()
                select.select_textobject('@function.inner', 'textobjects')
            end, { desc = 'Select inner function' })
            vim.keymap.set({ 'x', 'o' }, 'ac', function()
                select.select_textobject('@class.outer', 'textobjects')
            end, { desc = 'Select outer class' })
            vim.keymap.set({ 'x', 'o' }, 'ic', function()
                select.select_textobject('@class.inner', 'textobjects')
            end, { desc = 'Select inner class' })

            local move = require 'nvim-treesitter-textobjects.move'
            vim.keymap.set({ 'n', 'x', 'o' }, ']m', function()
                move.goto_next_start('@function.outer', 'textobjects')
            end, { desc = 'Next function start' })
            vim.keymap.set({ 'n', 'x', 'o' }, ']]', function()
                move.goto_next_start('@class.outer', 'textobjects')
            end, { desc = 'Next class start' })
            vim.keymap.set({ 'n', 'x', 'o' }, ']M', function()
                move.goto_next_end('@function.outer', 'textobjects')
            end, { desc = 'Next function end' })
            vim.keymap.set({ 'n', 'x', 'o' }, '][', function()
                move.goto_next_end('@class.outer', 'textobjects')
            end, { desc = 'Next class end' })
            vim.keymap.set({ 'n', 'x', 'o' }, '[m', function()
                move.goto_previous_start('@function.outer', 'textobjects')
            end, { desc = 'Previous function start' })
            vim.keymap.set({ 'n', 'x', 'o' }, '[[', function()
                move.goto_previous_start('@class.outer', 'textobjects')
            end, { desc = 'Previous class start' })
            vim.keymap.set({ 'n', 'x', 'o' }, '[M', function()
                move.goto_previous_end('@function.outer', 'textobjects')
            end, { desc = 'Previous function end' })
            vim.keymap.set({ 'n', 'x', 'o' }, '[]', function()
                move.goto_previous_end('@class.outer', 'textobjects')
            end, { desc = 'Previous class end' })

            local swap = require 'nvim-treesitter-textobjects.swap'
            vim.keymap.set('n', '<leader>a', function()
                swap.swap_next '@parameter.inner'
            end, { desc = 'Swap with next parameter' })
            vim.keymap.set('n', '<leader>A', function()
                swap.swap_previous '@parameter.inner'
            end, { desc = 'Swap with previous parameter' })
        end,
    },
}
