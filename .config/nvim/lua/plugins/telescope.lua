return {
    'nvim-telescope/telescope-ui-select.nvim',
    {
        'nvim-telescope/telescope.nvim',
        version = '*',
        dependencies = {'nvim-lua/plenary.nvim'},
        config = function()
            vim.api.nvim_set_keymap('n', '<leader>fb',
                                    ':Telescope file_browser', {noremap = true})

            -- [[ Configure Telescope ]]
            -- See `:help telescope` and `:help telescope.setup()`
            require('telescope').setup {
                defaults = {
                    mappings = {i = {['<C-u>'] = false, ['<C-d>'] = false}}
                },
                pickers = {
                    find_files = {
                        file_ignore_patterns = {
                            '.git/',
                            '.cache',
                            '.obsidian',
                            'Archive'
                        },
                        hidden = true
                    }
                },
                previewers = {vimgrep = {new = 'bat'}}
            }

            -- Enable telescope fzf native, if installed
            pcall(require('telescope').load_extension, 'fzf')
            -- See `:help telescope.builtin`
            vim.keymap.set('n', '<leader>?',
                           require('telescope.builtin').oldfiles,
                           {desc = '[?] Find recently opened files'})
            vim.keymap.set('n', '<leader><space>',
                           require('telescope.builtin').buffers,
                           {desc = '[ ] Find existing buffers'})
            vim.keymap.set('n', '<leader>/', function()
                -- You can pass additional configuration to telescope to change theme, layout, etc.
                require('telescope.builtin').current_buffer_fuzzy_find(require(
                                                                           'telescope.themes').get_dropdown {
                    winblend = 10,
                    previewer = true
                })
            end, {desc = '[/] Fuzzily search in current buffer'})

            vim.keymap.set('n', '<leader>sf',
                           require('telescope.builtin').find_files,
                           {desc = '[S]earch [F]iles'})
            vim.keymap.set('n', '<leader>sh',
                           require('telescope.builtin').help_tags,
                           {desc = '[S]earch [H]elp'})
            vim.keymap.set('n', '<leader>sw',
                           require('telescope.builtin').grep_string,
                           {desc = '[S]earch current [W]ord'})
            vim.keymap.set('n', '<leader>sg',
                           require('telescope.builtin').live_grep,
                           {desc = '[S]earch by [G]rep'})
            vim.keymap.set('n', '<leader>sd',
                           require('telescope.builtin').diagnostics,
                           {desc = '[S]earch [D]iagnostics'})
            -- Shortcut for searching your Neovim configuration files
            vim.keymap.set('n', '<leader>sn', function()
                require('telescope.builtin').find_files {cwd = '~/Notes/'}
            end, {desc = '[S]earch [N]otes'})
            -- Shortcut for searching your Neovim configuration files
            vim.keymap.set('n', '<leader>sv', function()
                require('telescope.builtin').find_files {
                    cwd = vim.fn.stdpath 'config'
                }
            end, {desc = '[S]earch neo[V]im files'})
        end
    }, -- Fuzzy Finder (files, lsp, etc)
    -- Fuzzy Finder Algorithm which requires local dependencies to be built.
    -- Only load if `make` is available. Make sure you have the system
    -- requirements installed.
    {
        'nvim-telescope/telescope-fzf-native.nvim',
        -- NOTE: If you are having trouble with this installation,
        --       refer to the README for telescope-fzf-native for more instructions.
        build = 'make',
        cond = function() return vim.fn.executable 'make' == 1 end
    }
}
