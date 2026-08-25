return {
    {
        'mrcjkb/rustaceanvim',
        version = '^9', -- Recommended for Neovim 0.12+
        ft = { 'rust' },
        lazy = false, -- This plugin is already lazy
        ['rust-analyzer'] = {
            cargo = {
                allFeatures = true,
            },
        },
        dependencies = {
            'mfussenegger/nvim-dap',
        },
        config = function()
            vim.g.rustaceanvim = function()
                return {
                    server = {
                        cmd = { 'rust-analyzer' },
                        settings = {
                            ['rust-analyzer'] = {
                                cargo = {
                                    allFeatures = true,
                                    loadOutDirsFromCheck = true,
                                },
                                inlayHints = {
                                    typeHints = { enable = true },
                                    parameterHints = { enable = true },
                                },
                                procMacro = {
                                    ignored = {
                                        leptos_macro = { 'server' },
                                    },
                                },
                            },
                        },
                    },
                }
            end
        end,
    },
    {
        'saecki/crates.nvim',
        tag = 'stable',
        config = function() end,
    },
}
