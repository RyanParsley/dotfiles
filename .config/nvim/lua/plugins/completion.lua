return {
    {
        'zbirenbaum/copilot.lua',
        cmd = 'Copilot',
        build = ':Copilot auth',
        event = 'InsertEnter',
        opts = {
            suggestion = { enabled = false },
            panel = { enabled = false },
            filetypes = {
                markdown = true,
                help = true,
            },
        },
    },
    {
        'zbirenbaum/copilot-cmp',
        dependencies = 'copilot.lua',
        config = function(_, opts)
            require('copilot_cmp').setup(opts)
        end,
    },
    { 'AndreM222/copilot-lualine' },
    {
        'CopilotC-Nvim/CopilotChat.nvim',
        branch = 'canary',
        dependencies = {
            { 'zbirenbaum/copilot.lua' }, -- or github/copilot.vim
            { 'nvim-lua/plenary.nvim' }, -- for curl, log wrapper
        },
        opts = {
            debug = true, -- Enable debugging
            -- See Configuration section for rest
        },
        -- See Commands section for default commands if you want to lazy load on them
        keys = {
            -- Show help actions with telescope
            {
                '<leader>ah',
                function()
                    local actions = require 'CopilotChat.actions'
                    require('CopilotChat.integrations.telescope').pick(actions.help_actions())
                end,
                desc = 'CopilotChat - Help actions',
            },
            -- Show prompts actions with telescope
            {
                '<leader>ap',
                function()
                    local actions = require 'CopilotChat.actions'
                    require('CopilotChat.integrations.telescope').pick(actions.prompt_actions())
                end,
                desc = 'CopilotChat - Prompt actions',
            },
            {
                '<leader>ap',
                ":lua require('CopilotChat.integrations.telescope').pick(require('CopilotChat.actions').prompt_actions({selection = require('CopilotChat.select').visual}))<CR>",
                mode = 'x',
                desc = 'CopilotChat - Prompt actions',
            },
            -- Code related commands
            { '<leader>ae', '<cmd>CopilotChatExplain<cr>', desc = 'CopilotChat - Explain code' },
            { '<leader>at', '<cmd>CopilotChatTests<cr>', desc = 'CopilotChat - Generate tests' },
            { '<leader>ar', '<cmd>CopilotChatReview<cr>', desc = 'CopilotChat - Review code' },
            { '<leader>aR', '<cmd>CopilotChatRefactor<cr>', desc = 'CopilotChat - Refactor code' },
            { '<leader>an', '<cmd>CopilotChatBetterNamings<cr>', desc = 'CopilotChat - Better Naming' },
            -- Chat with Copilot in visual mode
            {
                '<leader>av',
                ':CopilotChatVisual',
                mode = 'x',
                desc = 'CopilotChat - Open in vertical split',
            },
            {
                '<leader>ax',
                ':CopilotChatInline<cr>',
                mode = 'x',
                desc = 'CopilotChat - Inline chat',
            },
            -- Custom input for CopilotChat
            {
                '<leader>ai',
                function()
                    local input = vim.fn.input 'Ask Copilot: '
                    if input ~= '' then
                        vim.cmd('CopilotChat ' .. input)
                    end
                end,
                desc = 'CopilotChat - Ask input',
            },
            -- Generate commit message based on the git diff
            {
                '<leader>am',
                '<cmd>CopilotChatCommit<cr>',
                desc = 'CopilotChat - Generate commit message for all changes',
            },
            {
                '<leader>aM',
                '<cmd>CopilotChatCommitStaged<cr>',
                desc = 'CopilotChat - Generate commit message for staged changes',
            },
            -- Quick chat with Copilot
            {
                '<leader>aq',
                function()
                    local input = vim.fn.input 'Quick Chat: '
                    if input ~= '' then
                        vim.cmd('CopilotChatBuffer ' .. input)
                    end
                end,
                desc = 'CopilotChat - Quick chat',
            },
            -- Debug
            { '<leader>ad', '<cmd>CopilotChatDebugInfo<cr>', desc = 'CopilotChat - Debug Info' },
            -- Fix the issue with diagnostic
            { '<leader>af', '<cmd>CopilotChatFixDiagnostic<cr>', desc = 'CopilotChat - Fix Diagnostic' },
            -- Clear buffer and chat history
            { '<leader>al', '<cmd>CopilotChatReset<cr>', desc = 'CopilotChat - Clear buffer and chat history' },
            -- Toggle Copilot Chat Vsplit
            { '<leader>av', '<cmd>CopilotChatToggle<cr>', desc = 'CopilotChat - Toggle' },
            -- Copilot Chat Models
            { '<leader>a?', '<cmd>CopilotChatModels<cr>', desc = 'CopilotChat - Select Models' },
        },
    },
    {
        -- Autocompletion
        'hrsh7th/nvim-cmp',
        event = 'InsertEnter',
        dependencies = {
            -- Snippet Engine & its associated nvim-cmp source
            {
                'L3MON4D3/LuaSnip',
                build = (function()
                    -- Build Step is needed for regex support in snippets
                    -- This step is not supported in many windows environments
                    -- Remove the below condition to re-enable on windows
                    if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
                        return
                    end
                    return 'make install_jsregexp'
                end)(),
            },
            'saadparwaiz1/cmp_luasnip', -- Adds other completion capabilities.
            --  nvim-cmp does not ship with all sources by default. They are split
            --  into multiple repos for maintenance purposes.
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-path',
            -- If you want to add a bunch of pre-configured snippets,
            --    you can use this plugin to help you. It even has snippets
            --    for various frameworks/libraries/etc. but you will have to
            --    set up the ones that are useful for you.
            'rafamadriz/friendly-snippets',
            {
                'zbirenbaum/copilot-cmp',
                dependencies = 'copilot.lua',
                config = function(_, opts)
                    local copilot_cmp = require 'copilot_cmp'
                    copilot_cmp.setup(opts)
                end,
            },
        },
        config = function()
            -- See `:help cmp`
            local cmp = require 'cmp'
            local luasnip = require 'luasnip'
            luasnip.config.setup {}
            require('crates').setup {
                completion = {
                    cmp = {
                        enabled = true,
                    },
                },
            }

            cmp.setup {
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                completion = { completeopt = 'menu,menuone,noinsert' },

                -- For an understanding of why these mappings were
                -- chosen, you will need to read `:help ins-completion`
                --
                -- No, but seriously. Please read `:help ins-completion`, it is really good!
                mapping = cmp.mapping.preset.insert {
                    -- Select the [n]ext item
                    ['<C-n>'] = cmp.mapping.select_next_item(),
                    -- Select the [p]revious item
                    ['<C-p>'] = cmp.mapping.select_prev_item(),

                    -- Accept ([y]es) the completion.
                    --  This will auto-import if your LSP supports it.
                    --  This will expand snippets if the LSP sent a snippet.
                    ['<C-y>'] = cmp.mapping.confirm { select = true },

                    -- Manually trigger a completion from nvim-cmp.
                    --  Generally you don't need this, because nvim-cmp will display
                    --  completions whenever it has completion options available.
                    ['<C-Space>'] = cmp.mapping.complete {},

                    -- Think of <c-l> as moving to the right of your snippet expansion.
                    --  So if you have a snippet that's like:
                    --  function $name($args)
                    --    $body
                    --  end
                    --
                    -- <c-l> will move you to the right of each of the expansion locations.
                    -- <c-h> is similar, except moving you backwards.
                    ['<C-l>'] = cmp.mapping(function()
                        if luasnip.expand_or_locally_jumpable() then
                            luasnip.expand_or_jump()
                        end
                    end, { 'i', 's' }),
                    ['<C-h>'] = cmp.mapping(function()
                        if luasnip.locally_jumpable(-1) then
                            luasnip.jump(-1)
                        end
                    end, { 'i', 's' }),
                },
                sources = {
                    { name = 'path' },
                    { name = 'buffer' },
                    { name = 'copilot' },
                    { name = 'luasnip' },
                    {
                        name = 'nvim_lsp',
                        option = {
                            markdown_oxide = {
                                keyword_pattern = [[\(\k\| \|\/\|#\)\+]],
                            },
                        },
                    },
                    { name = 'crates' },
                },
            }
        end,
    },
}
