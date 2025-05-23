return {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v3.x',
    dependencies = {
        'nvim-lua/plenary.nvim',
        'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
        'MunifTanjim/nui.nvim',
        -- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
    },
    cmd = 'Neotree',
    keys = {
        {
            '<leader>fe',
            function()
                require('neo-tree.command').execute { toggle = true }
            end,
            desc = 'Explorer NeoTree (root dir)',
        },
        {
            '<leader>fE',
            function()
                require('neo-tree.command').execute {
                    toggle = true,
                    dir = vim.loop.cwd(),
                }
            end,
            desc = 'Explorer NeoTree (cwd)',
        },
        {
            '<leader>e',
            '<leader>fe',
            desc = 'Explorer NeoTree (root dir)',
            remap = true,
        },
        {
            '<leader>E',
            '<leader>fE',
            desc = 'Explorer NeoTree (cwd)',
            remap = true,
        },
        {
            '<leader>ge',
            function()
                require('neo-tree.command').execute {
                    source = 'git_status',
                    toggle = true,
                }
            end,
            desc = 'Git explorer',
        },
        {
            '<leader>be',
            function()
                require('neo-tree.command').execute {
                    source = 'buffers',
                    toggle = true,
                }
            end,
            desc = 'Buffer explorer',
        },
    },
    deactivate = function()
        vim.cmd [[Neotree close]]
    end,
    opts = {
        sources = { 'filesystem', 'buffers', 'git_status', 'document_symbols' },
        open_files_do_not_replace_types = {
            'terminal',
            'Trouble',
            'trouble',
            'qf',
            'Outline',
        },
        filesystem = {
            bind_to_cwd = false,
            follow_current_file = { enabled = true },
            use_libuv_file_watcher = true,
            filtered_items = { visible = true, hide_dotfiles = false },
            window = {
                mappings = {
                    ['<leader>p'] = 'image_wezterm', -- " or another map
                },
            },
            commands = {
                image_wezterm = function(state)
                    local node = state.tree:get_node()
                    if node.type == 'file' then
                        require('image_preview').PreviewImage(node.path)
                    end
                end,
            },
        },
        window = { mappings = { ['<space>'] = 'none' } },
        default_component_configs = {
            indent = {
                with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
                expander_collapsed = '',
                expander_expanded = '',
                expander_highlight = 'NeoTreeExpander',
            },
        },
    },
    config = function(_, opts)
        opts.event_handlers = opts.event_handlers or {}
        require('neo-tree').setup(opts)
        vim.api.nvim_create_autocmd('TermClose', {
            pattern = '*lazygit',
            callback = function()
                if package.loaded['neo-tree.sources.git_status'] then
                    require('neo-tree.sources.git_status').refresh()
                end
            end,
        })
    end,
}
