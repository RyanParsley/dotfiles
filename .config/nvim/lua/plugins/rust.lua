return {
    {
        'mrcjkb/rustaceanvim',
        version = '^5', -- Recommended
        lazy = false, -- This plugin is already lazy
        ft = { 'rust' },
        dependencies = {
            'simrat39/inlay-hints.nvim',
            { 'lvimuser/lsp-inlayhints.nvim', opts = {} },
        },
        config = function()
            vim.g.rustaceanvim = {
                inlay_hints = { highlight = 'NonText' },
                tools = { hover_actions = { auto_focus = true } },
            }
        end,
    },
}
