return {
    {
        'mrcjkb/rustaceanvim',
        version = '^6', -- Recommended
        ft = { 'rust' },
        lazy = false, -- This plugin is already lazy
        ['rust-analyzer'] = {
            cargo = {
                allFeatures = true,
            },
        },
        dependencies = {},
        config = function()
            vim.g.rustacean_opts = {
                server = {
                    settings = {
                        ['rust-analyzer'] = {
                            inlayHints = {
                                typeHints = {
                                    enable = true,
                                },
                                parameterHints = {
                                    enable = true,
                                },
                            },
                        },
                    },
                },
            }
            local mason_registry = require 'mason-registry'
            local codelldb = mason_registry.get_package 'codelldb'
            local extension_path = codelldb:get_install_path() .. '/extensions/'

            local codelldb_path = extension_path .. 'adapter/codelldb'
            local liblldb_path = extension_path .. 'lldb/lib/liblldb'
            local this_os = vim.uv.os_uname().sysname

            -- The path is different on Windows
            if this_os:find 'Windows' then
                codelldb_path = extension_path .. 'adapter\\codelldb.exe'
                liblldb_path = extension_path .. 'lldb\\bin\\liblldb.dll'
            else
                -- The liblldb extension is .so for Linux and .dylib for MacOS
                liblldb_path = liblldb_path .. (this_os == 'Linux' and '.so' or '.dylib')
            end

            local cfg = require 'rustaceanvim.config'
            return {
                dap = {
                    adapter = cfg.get_codelldb_adapter(codelldb_path, liblldb_path),
                },
            }
        end,
    },
    {
        'saecki/crates.nvim',
        tag = 'stable',
        config = function() end,
    },
}
