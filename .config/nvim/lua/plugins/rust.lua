return {
    {
        'mrcjkb/rustaceanvim',
        version = '^4', -- Recommended
        ft = {'rust'},
        config = function()
            vim.g.rustaceanvim = {
                inlay_hints = {highlight = 'NonText'},
                tools = {hover_actions = {auto_focus = true}}
            }
        end
    }
}
