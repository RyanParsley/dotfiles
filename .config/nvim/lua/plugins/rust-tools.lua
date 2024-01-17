return {
    'simrat39/rust-tools.nvim',
    config = function()
        local rt = require 'rust-tools'
        vim.g.rust_clip_command = 'pbcopy'

        rt.setup {
            server = {
                standalone = true,
                on_attach = function(_, bufnr)
                    -- Hover actions
                    vim.keymap.set('n', '<Leader>ch',
                                   rt.hover_actions.hover_actions,
                                   {buffer = bufnr})
                    -- Code action groups
                    vim.keymap.set('n', '<Leader>ca',
                                   rt.code_action_group.code_action_group,
                                   {buffer = bufnr})
                end
            },
            tools = {hover_actions = {auto_focus = true}}
        }
    end
}
