-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.markdown_fenced_languages = {
    "scss", "css", "javascript", "typescript", "bash", "lua", "go", "rust", "c",
    "cpp"
}

-- Install package manager
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system {
        'git', 'clone', '--filter=blob:none',
        'https://github.com/folke/lazy.nvim.git', '--branch=stable', -- latest stable release
        lazypath
    }
end
vim.opt.rtp:prepend(lazypath)
vim.opt.relativenumber = true

-- NOTE: Here is where you install your plugins.
--  You can configure plugins using the `config` key.
--
--  You can also configure plugins after the setup call,
--    as they will be available in your neovim runtime.
require('lazy').setup({
    -- NOTE: First, some plugins that don't require any configuration
    {
        "nvim-neotest/neotest",
        dependencies = {
            "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter",
            "antoinemadec/FixCursorHold.nvim", "haydenmeade/neotest-jest",
            "rouge8/neotest-rust"
        },
        config = function()
            local neotest = require("neotest")
            local map_opts = {noremap = true, silent = true, nowait = true}

            require("neotest").setup({
                adapters = {
                    require('neotest-jest')({
                        jestCommand = "npm test",
                        env = {CI = true}
                    }),
                    require("neotest-rust") {
                        args = {"--no-capture"},
                        dap_adapter = "lldb"
                    }
                }
            })
        end
    }, {
        "L3MON4D3/LuaSnip",
        -- follow latest release.
        version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
        -- install jsregexp (optional!).
        build = "make install_jsregexp"
    }, -- Git related plugins
    'tpope/vim-fugitive', {
        'kdheepak/lazygit.nvim',
        -- optional for floating window border decoration
        dependencies = {
            'nvim-telescope/telescope.nvim', 'nvim-lua/plenary.nvim'
        },
        config = function()
            require('telescope').load_extension('lazygit')
        end
    }, 'tpope/vim-rhubarb', 'evanleck/vim-svelte',
    {
        'aserowy/tmux.nvim',
        config = function() return require("tmux").setup() end
    }, {
        "michaelb/sniprun",
        branch = "master",

        build = "sh install.sh",
        -- do 'sh install.sh 1' if you want to force compile locally
        -- (instead of fetching a binary from the github release). Requires Rust >= 1.65

        config = function()
            require("sniprun").setup({
                interpreter_options = {
                    GFM_original = {
                        use_on_filetypes = {
                            "markdown.pandoc", "markdown", "vimwiki",
                            "markdown_fenced_languages", "markdown_inline"
                        },
                        default_filetype = 'typescript' -- default filetype (not github flavored markdown name)
                    }
                }
            })
        end
    }, {
        'folke/noice.nvim',
        event = 'VeryLazy',
        opts = {
            -- add any options here
        },
        dependencies = {
            -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
            'MunifTanjim/nui.nvim', -- OPTIONAL:
            --   `nvim-notify` is only needed, if you want to use the notification view.
            --   If not available, we use `mini` as the fallback
            'rcarriga/nvim-notify'
        }
    }, -- Detect tabstop and shiftwidth automatically
    'tpope/vim-sleuth', -- Format all the things
    'sbdchd/neoformat', 'nvim-tree/nvim-web-devicons', 'LhKipp/nvim-nu',
    'Canop/nvim-bacon', 'mattn/webapi-vim', {
        'simrat39/rust-tools.nvim',
        config = function()
            local rt = require("rust-tools")
            vim.g.rust_clip_command = "pbcopy"

            rt.setup({
                server = {
                    standalone = true,
                    on_attach = function(_, bufnr)
                        -- Hover actions
                        vim.keymap.set("n", "<Leader>ch",
                                       rt.hover_actions.hover_actions,
                                       {buffer = bufnr})
                        -- Code action groups
                        vim.keymap.set("n", "<Leader>ca",
                                       rt.code_action_group.code_action_group,
                                       {buffer = bufnr})
                    end
                },
                tools = {hover_actions = {auto_focus = true}}
            })
        end
    }, 'mfussenegger/nvim-dap',
    {'rcarriga/nvim-dap-ui', config = function() end},
    -- adds more lsp support, specifically I'm solving for nu today
    -- I need to confirm it works with baked in and not against 
    {
        "jay-babu/mason-null-ls.nvim",
        event = {"BufReadPre", "BufNewFile"},
        dependencies = {
            "williamboman/mason.nvim", "jose-elias-alvarez/null-ls.nvim"
        },
        config = function()
            -- require("your.null-ls.config") -- require your null-ls config here (example below)
        end
    }, -- Obisidan support in neovim
    {
        "epwalsh/obsidian.nvim",
        -- lazy = true,
        -- event = { "BufReadPre Users/ryan/Notes/**.md" },
        -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand':
        -- event = { "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/**.md" },
        dependencies = {
            -- Required.
            "nvim-lua/plenary.nvim"
        },
        opts = {
            dir = "~/Notes", -- no need to call 'vim.fn.expand' here
            daily_notes = {
                -- Optional, if you keep daily notes in a separate directory.
                folder = "journal/daily"
            },
            templates = {subdir = "templates"},
            use_advanced_uri = true,
            -- Optional, by default when you use `:ObsidianFollowLink` on a link to an external
            -- URL it will be ignored but you can customize this behavior here.
            follow_url_func = function(url)
                -- Open the URL in the default web browser.
                vim.fn.jobstart({"open", url}) -- Mac OS
                -- vim.fn.jobstart({"xdg-open", url})  -- linux
            end
        }
    }, -- make it a little nicer to work with notes
    {
        'vimwiki/vimwiki',
        config = function()
            vim.g.vimwiki_list = {
                {
                    name = "notes",
                    path = '~/Projects/notes',
                    syntax = 'markdown',
                    ext = '.md'
                }
            }
        end
    }, -- NOTE: This is where your plugins related to LSP can be installed.
    --  The configuration is done below. Search for lspconfig to find it below.
    { -- LSP Configuration & Plugins
        'neovim/nvim-lspconfig',
        dependencies = {
            -- Automatically install LSPs to stdpath for neovim
            'williamboman/mason.nvim', 'williamboman/mason-lspconfig.nvim',

            -- Useful status updates for LSP
            -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
            {'j-hui/fidget.nvim', tag = 'legacy', opts = {}},

            -- Additional lua configuration, makes nvim stuff amazing!
            'folke/neodev.nvim'
        }
    }, {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v2.x",
        dependencies = {
            "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
            "MunifTanjim/nui.nvim"
        },
        opts = {
            filesystem = {
                filtered_items = {
                    visible = false,
                    show_hidden_count = false,
                    hide_dotfiles = false,
                    hide_gitignored = false,
                    hide_by_name = {'.git', '.DS_Store', 'thumbs.db'},
                    never_show = {'.DS_Store'}
                }
            }
        }
    }, { -- Autocompletion
        'hrsh7th/nvim-cmp',
        dependencies = {
            'hrsh7th/cmp-nvim-lsp', 'L3MON4D3/LuaSnip',
            'saadparwaiz1/cmp_luasnip'
        }
    }, {
        'Equilibris/nx.nvim',
        dependencies = {'nvim-telescope/telescope.nvim'},
        config = function()
            require("nx").setup {
                -- Base command to run all other nx commands, some other values may be:
                -- - `npm nx`
                -- - `yarn nx`
                -- - `pnpm nx`
                nx_cmd_root = 'npx nx',

                -- Command running capabilities,
                -- see nx.m.command-runners for more details
                command_runner = require('nx.command-runners').terminal_cmd(),
                -- Form rendering capabilities,
                -- see nx.m.form-renderers for more detials
                form_renderer = require('nx.form-renderers').telescope(),

                -- Whether or not to load nx configuration,
                -- see nx.loading-and-reloading for more details
                read_init = true
            }
        end
    }, -- Useful plugin to show you pending keybinds.
    {
        "folke/which-key.nvim",
        config = function()
            vim.o.timeout = true
            vim.o.timeoutlen = 300
            require("which-key").setup({
                -- your configuration comes here
                -- or leave it empty to use the default settings
                -- refer to the configuration section below
            })
        end
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
    }, { -- I prefer the nord theme
        'shaunsingh/nord.nvim',
        -- I don't know why this was in kickstarter
        -- priority = 1000,
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
    }, {
        -- Add indentation guides even on blank lines
        'lukas-reineke/indent-blankline.nvim',
        -- Enable `lukas-reineke/indent-blankline.nvim`
        -- See `:help indent_blankline.txt`
        main = 'ibl',
        opts = {}
    }, {'numToStr/Comment.nvim', opts = {}}, -- Fuzzy Finder (files, lsp, etc)
    {
        'nvim-telescope/telescope.nvim',
        version = '*',
        dependencies = {'nvim-lua/plenary.nvim'}
    }, -- Fuzzy Finder Algorithm which requires local dependencies to be built.
    -- Only load if `make` is available. Make sure you have the system
    -- requirements installed.
    {
        'nvim-telescope/telescope-fzf-native.nvim',
        -- NOTE: If you are having trouble with this installation,
        --       refer to the README for telescope-fzf-native for more instructions.
        build = 'make',
        cond = function() return vim.fn.executable 'make' == 1 end
    }, { -- Highlight, edit, and navigate code
        'nvim-treesitter/nvim-treesitter',
        dependencies = {'nvim-treesitter/nvim-treesitter-textobjects'},
        config = function()
            pcall(require('nvim-treesitter.install').update {with_sync = true})
        end
    }, 'MDeiml/tree-sitter-markdown',
    'nvim-treesitter/nvim-treesitter-refactor',

    -- fork of https://github.com/nvim-treesitter/nvim-treesitter-angular with bug patch
    {"elgiano/nvim-treesitter-angular", branch = "topic/jsx-fix"}

    -- NOTE: Next Step on Your Neovim Journey: Add/Configure additional "plugins" for kickstart
    --       These are some example plugins that I've included in the kickstart repository.
    --       Uncomment any of the lines below to enable them.
    -- require 'kickstart.plugins.autoformat',
    -- require 'kickstart.plugins.debug',

    -- NOTE: The import below automatically adds your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
    --    You can use this folder to prevent any conflicts with this init.lua if you're interested in keeping
    --    up-to-date with whatever is in the kickstart repo.
    --
    --    For additional information see: https://github.com/folke/lazy.nvim#-structuring-your-plugins
    --
    --    An additional note is that if you only copied in the `init.lua`, you can just comment this line
    --    to get rid of the warning telling you that there are not plugins in `lua/custom/plugins/`.
    -- { import = 'custom.plugins' },
}, {})

-- [[ Setting options ]]
-- See `:help vim.o`

-- Set highlight on search
vim.o.hlsearch = false

-- Make line numbers default
vim.wo.number = true

-- Enable mouse mode
vim.o.mouse = 'a'

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.o.clipboard = 'unnamedplus'

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case insensitive searching UNLESS /C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeout = true
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

-- [[ Basic Keymaps ]]

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({'n', 'v'}, '<Space>', '<Nop>', {silent = true})

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'",
               {expr = true, silent = true})
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'",
               {expr = true, silent = true})

vim.keymap.set('n', '<leader>b', require'dap'.toggle_breakpoint)

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight',
                                                    {clear = true})
vim.api.nvim_create_autocmd('TextYankPost', {
    callback = function() vim.highlight.on_yank() end,
    group = highlight_group,
    pattern = '*'
})

-- format on save
local format_on_save_group = vim.api.nvim_create_augroup('fmt', {clear = true})
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*",
    command = "undojoin | Neoformat",
    group = format_on_save_group
})

vim.api.nvim_set_keymap("n", "<leader>fb", ":Telescope file_browser",
                        {noremap = true})

require('nu').setup {
    use_lsp_features = true, -- requires https://github.com/jose-elias-alvarez/null-ls.nvim
    -- lsp_feature: all_cmd_names is the source for the cmd name completion.
    -- It can be
    --  * a string, which is interpreted as a shell command and the returned list is the source for completions (requires plenary.nvim)
    --  * a list, which is the direct source for completions (e.G. all_cmd_names = {"echo", "to csv", ...})
    --  * a function, returning a list of strings and the return value is used as the source for completions
    all_cmd_names = [[nu -c 'help commands | get name | str join "\n"']]
}

-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
require('telescope').setup {
    defaults = {mappings = {i = {['<C-u>'] = false, ['<C-d>'] = false}}},
    pickers = {
        find_files = {file_ignore_patterns = {".git/", ".cache"}, hidden = true}
    }
}

-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')

-- See `:help telescope.builtin`
vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles,
               {desc = '[?] Find recently opened files'})
vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers,
               {desc = '[ ] Find existing buffers'})
vim.keymap.set('n', '<leader>/', function()
    -- You can pass additional configuration to telescope to change theme, layout, etc.
    require('telescope.builtin').current_buffer_fuzzy_find(require(
                                                               'telescope.themes').get_dropdown {
        winblend = 10,
        previewer = false
    })
end, {desc = '[/] Fuzzily search in current buffer'})

vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files,
               {desc = '[S]earch [F]iles'})
vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags,
               {desc = '[S]earch [H]elp'})
vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string,
               {desc = '[S]earch current [W]ord'})
vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep,
               {desc = '[S]earch by [G]rep'})
vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics,
               {desc = '[S]earch [D]iagnostics'})

-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
require('nvim-treesitter.configs').setup {
    -- Add languages to be installed here that you want installed for treesitter
    ensure_installed = {
        'angular', 'astro', 'c', 'cpp', 'css', 'go', 'html', 'lua', 'nu',
        'markdown', 'markdown_inline', 'python', 'rust', 'scss', 'toml', 'tsx',
        'typescript', 'vimdoc', 'vim'
    },

    -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
    auto_install = false,

    highlight = {
        enable = true,
        additional_vim_regex_highlighting = {"markdown"}
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
        highlight_definitions = {enable = true, clear_on_cursor_move = true},
        highlight_current_scope = {enable = true},
        smart_rename = {
            enable = true,
            -- Assign keymaps to false to disable them, e.g. `smart_rename = false`.
            keymaps = {smart_rename = "grr"}
        },
        navigation = {
            enable = true,
            -- Assign keymaps to false to disable them, e.g. `goto_definition = false`.
            keymaps = {
                goto_definition = "gnd",
                list_definitions = "gnD",
                list_definitions_toc = "gO",
                goto_next_usage = "<a-*>",
                goto_previous_usage = "<a-#>"
            }
        }
    }
}

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev,
               {desc = "Go to previous diagnostic message"})
vim.keymap.set('n', ']d', vim.diagnostic.goto_next,
               {desc = "Go to next diagnostic message"})
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float,
               {desc = "Open floating diagnostic message"})
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist,
               {desc = "Open diagnostics list"})

-- LSP settings.
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
    -- NOTE: Remember that lua is a real programming language, and as such it is possible
    -- to define small helper and utility functions so you don't have to repeat yourself
    -- many times.
    --
    -- In this case, we create a function that lets us more easily define mappings specific
    -- for LSP related items. It sets the mode, buffer and description for us each time.
    local nmap = function(keys, func, desc)
        if desc then desc = 'LSP: ' .. desc end

        vim.keymap.set('n', keys, func, {buffer = bufnr, desc = desc})
    end

    nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
    nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

    nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
    nmap('gr', require('telescope.builtin').lsp_references,
         '[G]oto [R]eferences')
    nmap('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
    nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
    nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols,
         '[D]ocument [S]ymbols')
    nmap('<leader>ws',
         require('telescope.builtin').lsp_dynamic_workspace_symbols,
         '[W]orkspace [S]ymbols')

    -- See `:help K` for why this keymap
    nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
    nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

    -- Lesser used LSP functionality
    nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
    nmap('<leader>wa', vim.lsp.buf.add_workspace_folder,
         '[W]orkspace [A]dd Folder')
    nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder,
         '[W]orkspace [R]emove Folder')
    nmap('<leader>wl', function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, '[W]orkspace [L]ist Folders')

    -- Create a command `:Format` local to the LSP buffer
    vim.api.nvim_buf_create_user_command(bufnr, 'Format',
                                         function(_) vim.lsp.buf.format() end, {
        desc = 'Format current buffer with LSP'
    })
end

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--
--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
local servers = {
    -- clangd = {},
    -- gopls = {},
    -- pyright = {},
    -- rust_analyzer = {},
    -- tsserver = {},

    lua_ls = {
        Lua = {
            workspace = {checkThirdParty = false},
            telemetry = {enable = false},
            diagnostics = {globals = {'vim'}}
        }
    }
}

-- Setup neovim lua configuration
require('neodev').setup()

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Setup mason so it can manage external tooling
require('mason').setup()

-- Ensure the servers above are installed
local mason_lspconfig = require 'mason-lspconfig'

mason_lspconfig.setup {ensure_installed = vim.tbl_keys(servers)}

mason_lspconfig.setup_handlers {
    function(server_name)
        require('lspconfig')[server_name].setup {
            capabilities = capabilities,
            on_attach = on_attach,
            settings = servers[server_name]
        }
    end
}
-- lsp borders and hover
local _border = "single"

vim.lsp.handlers["textDocument/hover"] =
    vim.lsp.with(vim.lsp.handlers.hover, {border = _border})

vim.lsp.handlers["textDocument/signatureHelp"] =
    vim.lsp.with(vim.lsp.handlers.signature_help, {border = _border})

vim.diagnostic.config {float = {border = _border}}

require('lspconfig.ui.windows').default_options = {border = _border}

-- nvim-cmp setup
local cmp = require 'cmp'
local luasnip = require 'luasnip'

luasnip.config.setup {}

cmp.setup {
    snippet = {expand = function(args) luasnip.lsp_expand(args.body) end},
    mapping = cmp.mapping.preset.insert {
        ['<C-d>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete {},
        ['<CR>'] = cmp.mapping.confirm {
            behavior = cmp.ConfirmBehavior.Replace,
            select = true
        },
        ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            else
                fallback()
            end
        end, {'i', 's'}),
        ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end, {'i', 's'})
    },
    sources = {{name = 'nvim_lsp'}, {name = 'luasnip'}}
}

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
