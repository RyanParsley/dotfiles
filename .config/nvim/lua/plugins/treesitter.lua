-- Highlight, edit, and navigate code
return {
    'nushell/tree-sitter-nu', {
        'nvim-treesitter/nvim-treesitter',
        dependencies = {
            'nvim-treesitter/nvim-treesitter-textobjects',
            'nushell/tree-sitter-nu'
        },
        config = function()
            pcall(require('nvim-treesitter.install').update {with_sync = true})
            -- [[ Configure Treesitter ]]
            -- See `:help nvim-treesitter`
            require('nvim-treesitter.configs').setup {
                -- Add languages to be installed here that you want installed for treesitter
                ensure_installed = {
                    'angular', 'astro', 'c', 'cpp', 'css', 'go', 'html', 'lua',
                    'markdown', 'markdown_inline', 'nu', 'python', 'rust',
                    'scss', 'toml', 'tsx', 'typescript', 'vimdoc', 'vim'
                },

                -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
                auto_install = true,

                highlight = {
                    enable = true,
                    additional_vim_regex_highlighting = {'markdown'}
                },
                indent = {enable = true, disable = {'python'}},
                incremental_selection = {
                    enable = true,
                    keymaps = {
                        init_selection = '<c-space>',
                        node_incremental = '<c-space>',
                        scope_incremental = '<c-s>',
                        node_decremental = '<M-space>'
                    }
                },
                textobjects = {
                    select = {
                        enable = true,
                        lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
                        keymaps = {
                            -- You can use the capture groups defined in textobjects.scm
                            ['aa'] = '@parameter.outer',
                            ['ia'] = '@parameter.inner',
                            ['af'] = '@function.outer',
                            ['if'] = '@function.inner',
                            ['ac'] = '@class.outer',
                            ['ic'] = '@class.inner'
                        }
                    },
                    move = {
                        enable = true,
                        set_jumps = true, -- whether to set jumps in the jumplist
                        goto_next_start = {
                            [']m'] = '@function.outer',
                            [']]'] = '@class.outer'
                        },
                        goto_next_end = {
                            [']M'] = '@function.outer',
                            [']['] = '@class.outer'
                        },
                        goto_previous_start = {
                            ['[m'] = '@function.outer',
                            ['[['] = '@class.outer'
                        },
                        goto_previous_end = {
                            ['[M'] = '@function.outer',
                            ['[]'] = '@class.outer'
                        }
                    },
                    swap = {
                        enable = true,
                        swap_next = {['<leader>a'] = '@parameter.inner'},
                        swap_previous = {['<leader>A'] = '@parameter.inner'}
                    }
                },
                refactor = {
                    highlight_definitions = {
                        enable = true,
                        clear_on_cursor_move = true
                    },
                    highlight_current_scope = {enable = true},
                    smart_rename = {
                        enable = true,
                        -- Assign keymaps to false to disable them, e.g. `smart_rename = false`.
                        keymaps = {smart_rename = 'grr'}
                    },
                    navigation = {
                        enable = true,
                        -- Assign keymaps to false to disable them, e.g. `goto_definition = false`.
                        keymaps = {
                            goto_definition = 'gnd',
                            list_definitions = 'gnD',
                            list_definitions_toc = 'gO',
                            goto_next_usage = '<a-*>',
                            goto_previous_usage = '<a-#>'
                        }
                    }
                }
            }
        end
    }, 'MDeiml/tree-sitter-markdown',
    'nvim-treesitter/nvim-treesitter-refactor',
    -- fork of https://github.com/nvim-treesitter/nvim-treesitter-angular with bug patch
    {'elgiano/nvim-treesitter-angular', branch = 'topic/jsx-fix'}
}
