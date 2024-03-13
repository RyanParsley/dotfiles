return {
    {
        'mrcjkb/rustaceanvim',
        version = '^4', -- Recommended
        ft = {'rust'},
        dependencies = {
            'simrat39/inlay-hints.nvim',
            {'lvimuser/lsp-inlayhints.nvim', opts = {}}
        },
        config = function()
            vim.g.rustaceanvim = {
                inlay_hints = {highlight = 'NonText'},
                tools = {hover_actions = {auto_focus = true}},
                server = {
                    on_attach = function(client, bufnr)
                        require('lsp-inlayhints').on_attach(client, bufnr)
                        require('inlay-hints').on_attach(client, bufnr)
                    end
                }
            }
        end
    }
}
