return {
    'nvim-java/nvim-java',
    dependencies = { 'mfussenegger/nvim-dap' },
    config = function()
        require('java').setup {
            jdk = {
                auto_install = false,
                path = '/Users/ryan/.local/share/mise/installs/java/24.0.1',
            },
            java_test = {
                enable = true,
            },
            java_debug_adapter = {
                enable = true,
            },
        }

        vim.lsp.config('jdtls', {
            root_dir = function(bufnr, on_dir)
                local buffer_path = vim.api.nvim_buf_get_name(bufnr)

                if buffer_path:match 'target/generated%-sources' then
                    local current_dir = vim.fn.fnamemodify(buffer_path, ':h')
                    while current_dir ~= '/' do
                        if not current_dir:match 'target/' then
                            local pom = current_dir .. '/pom.xml'
                            if vim.fn.filereadable(pom) == 1 then
                                on_dir(current_dir)
                                return
                            end
                        end
                        current_dir = vim.fn.fnamemodify(current_dir, ':h')
                    end
                end

                local root = vim.fs.root(bufnr, { 'pom.xml' })
                if root then
                    on_dir(root)
                    return
                end

                root = vim.fs.root(bufnr, {
                    'gradlew',
                    'settings.gradle',
                    'settings.gradle.kts',
                    'build.gradle',
                    'build.gradle.kts',
                })
                if root then
                    on_dir(root)
                    return
                end

                root = vim.fs.root(bufnr, { '.git' })
                if root then
                    on_dir(root)
                end
            end,
            settings = {
                java = {
                    import = {
                        exclusions = {
                            '**/target/generated-sources/openapi/pom.xml',
                            '**/target/generated-sources/openapi/.project',
                            '**/target/generated-sources/openapi/.classpath',
                        },
                    },
                    configuration = {
                        updateBuildConfiguration = 'automatic',
                    },
                    eclipse = {
                        downloadSources = false,
                    },
                },
            },
        })
        vim.lsp.enable 'jdtls'

        vim.api.nvim_create_autocmd('LspAttach', {
            pattern = '*.java',
            callback = function(args)
                local client = vim.lsp.get_client_by_id(args.data.client_id)
                if not client or client.name ~= 'jdtls' then
                    return
                end

                local java = require 'java'
                vim.keymap.set('n', '<leader>dt', function()
                    java.test.debug_current_method()
                end, {
                    buf = args.buf,
                    desc = 'Debug: Current Test Method',
                })
                vim.keymap.set('n', '<leader>dT', function()
                    java.test.debug_current_class()
                end, {
                    buf = args.buf,
                    desc = 'Debug: Current Test Class',
                })
                vim.keymap.set('n', '<leader>dr', function()
                    require('dap').continue()
                end, {
                    buf = args.buf,
                    desc = 'Debug: Run/Debug Main Class',
                })
            end,
        })
    end,
}
