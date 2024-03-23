return {
    'nvim-neotest/neotest',
    dependencies = {
        'nvim-lua/plenary.nvim', 'nvim-treesitter/nvim-treesitter',
        'antoinemadec/FixCursorHold.nvim', 'nvim-neotest/nvim-nio'
    },
    config = function()
        require('neotest').setup {
            noremap = true,
            silent = true,
            nowait = true,
            adapters = {}
        }
    end
}
