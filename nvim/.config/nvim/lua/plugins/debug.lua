-- debug.lua
return {
    {
        'mxsdev/nvim-dap-vscode-js',
        main = 'dap-vscode-js',
        opts = {
            debugger_cmd = { 'js-debug-adapter' },
            adapters = { 'pwa-node' },
        },
        config = function(_, opts)
            require('dap-vscode-js').setup(opts)
        end,
        dependencies = { 'mfussenegger/nvim-dap' },
    },
    'nvim-neotest/nvim-nio',
    {
        'mfussenegger/nvim-dap',
        dependencies = {
            'rcarriga/nvim-dap-ui',
            'jay-babu/mason-nvim-dap.nvim',
            {
                'mason-org/mason.nvim',
            },

            -- Add your own debuggers here
            'leoluz/nvim-dap-go',
        },
        config = function()
            local dap = require 'dap'
            local dapui = require 'dapui'

            -- Configure DAP to handle terminal buffers properly
            -- This prevents the "requires unmodified buffer" error
            dap.defaults.fallback.force_external_terminal = false

            -- Set terminal options to avoid buffer modification issues
            dap.defaults.fallback.terminal_win_cmd = function()
                -- Create a new scratch buffer for the terminal
                vim.cmd 'belowright 15new'
                local bufnr = vim.api.nvim_get_current_buf()
                vim.bo[bufnr].bufhidden = 'wipe'
                vim.bo[bufnr].buflisted = false
                return bufnr
            end

            require('mason-nvim-dap').setup {
                automatic_installation = false,

                -- You can provide additional configuration to the handlers,
                -- see mason-nvim-dap README for more information
                handlers = {
                    function(config)
                        require('mason-nvim-dap').default_setup(config)
                    end,
                    javadbg = function() end,
                    javatest = function() end,
                },

                -- You'll need to check that you have the required things installed
                -- online, please don't ask me how to install them :)
                ensure_installed = {
                    'delve',
                    'firefox',
                    'chrome',
                },
            }
            -- Basic debugging keymaps, feel free to change to your liking!
            vim.keymap.set('n', '<F5>', dap.continue, { desc = 'Debug: Start/Continue' })
            vim.keymap.set('n', '<F1>', dap.step_into, { desc = 'Debug: Step Into' })
            vim.keymap.set('n', '<F2>', dap.step_over, { desc = 'Debug: Step Over' })
            vim.keymap.set('n', '<F3>', dap.step_out, { desc = 'Debug: Step Out' })
            vim.keymap.set('n', '<leader>db', dap.toggle_breakpoint, { desc = 'Debug: Toggle Breakpoint' })
            vim.keymap.set('n', '<leader>B', function()
                dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
            end, { desc = 'Debug: Set Breakpoint' })

            for _, language in ipairs { 'typescript', 'javascript' } do
                dap.configurations[language] = {
                    {
                        type = 'pwa-node',
                        request = 'launch',
                        name = 'Launch file',
                        program = '${file}',
                        cwd = '${workspaceFolder}',
                        runtimeExecutable = 'node',
                    },
                }
            end

            require('dapui').setup()

            -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
            vim.keymap.set('n', '<F7>', dapui.toggle, { desc = 'Debug: See last session result.' })

            dap.listeners.after.event_initialized['dapui_config'] = dapui.open
            dap.listeners.before.event_terminated['dapui_config'] = dapui.close
            dap.listeners.before.event_exited['dapui_config'] = dapui.close

            -- Install golang specific config
            require('dap-go').setup()
        end,
    },
}
