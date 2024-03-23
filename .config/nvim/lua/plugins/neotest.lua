return {
    'nvim-neotest/neotest',
    dependencies = {
        'nvim-lua/plenary.nvim', 'nvim-treesitter/nvim-treesitter',
        'antoinemadec/FixCursorHold.nvim', 'haydenmeade/neotest-jest',
        'rouge8/neotest-rust', 'nvim-neotest/nvim-nio'
    },
    config = function()
        require('neotest').setup {
            noremap = true,
            silent = true,
            nowait = true,
            adapters = {
                require 'neotest-jest' {
                    jestCommand = 'npm test',
                    env = {CI = true}
                },
                require 'neotest-rust' {
                    args = {'--no-capture'},
                    dap_adapter = 'lldb'
                }
            }
        }
    end
}
