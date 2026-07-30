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
                local extension_path = vim.env.HOME .. '/.vscode/extensions/vadimcn.vscode-lldb-1.10.0/'
                local codelldb_path = extension_path .. 'adapter/codelldb'
                local liblldb_path = extension_path .. 'lldb/lib/liblldb'
                local this_os = vim.uv.os_uname().sysname

                if this_os:find 'Windows' then
                    codelldb_path = extension_path .. 'adapter\\codelldb.exe'
                    liblldb_path = extension_path .. 'lldb\\bin\\liblldb.dll'
                else
                    liblldb_path = liblldb_path .. (this_os == 'Linux' and '.so' or '.dylib')
                end

                local cfg = require 'rustaceanvim.config'
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
                    dap = {
                        adapter = cfg.get_codelldb_adapter(codelldb_path, liblldb_path),
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
