return {
    'nvim-java/nvim-java',
    dependencies = {
        'nvim-java/lua-async-await',
        'nvim-java/nvim-java-core',
        'nvim-java/nvim-java-test',
        'nvim-java/nvim-java-dap',
        'mfussenegger/nvim-dap',
    },
    config = function()
        -- Dynamically set Java home using mise (only runs when opening Java files)
        local mise_java_path = vim.fn.trim(vim.fn.system('mise where java 2>/dev/null || echo ""'))
        if mise_java_path ~= "" and vim.fn.isdirectory(mise_java_path) == 1 then
            vim.g.java_home = mise_java_path .. '/bin/java'
        end
        
        -- Setup nvim-java (this calls vim.lsp.config('jdtls', ...) internally)
        require('java').setup {
            jdk = {
                auto_install = false,
            },
            -- Configure root directory detection for multi-module Maven projects
            root_markers = {
                -- First try to find the nearest pom.xml (for individual modules)
                'pom.xml',
                -- Then try Gradle files
                'gradlew',
                'gradle.gradle',
                'build.gradle',
                -- Then try Maven wrapper
                'mvnw',
                -- Then fall back to .git
                '.git',
            },
            -- Configure Java test and debug bundles
            java_test = {
                enable = true,
            },
            java_debug_adapter = {
                enable = true,
            },
            -- Configure DAP terminal settings for Java
            dap = {
                config_overrides = {
                    console = 'externalTerminal', -- Use external terminal to avoid buffer issues
                },
            },
            -- Additional jdtls settings to handle generated sources
            jdtls = {
                settings = {
                    java = {
                        -- Exclude generated project files from detection
                        import = {
                            exclusions = {
                                "**/target/generated-sources/openapi/pom.xml",
                                "**/target/generated-sources/openapi/.project",
                                "**/target/generated-sources/openapi/.classpath",
                            },
                        },
                        -- Configure to ignore generated sources as a separate project
                        configuration = {
                            updateBuildConfiguration = "automatic",
                        },
                        -- Reduce diagnostic noise from generated code
                        eclipse = {
                            downloadSources = false,
                        },
                    },
                },
            },
        }

        -- Override jdtls root_dir to find closest pom.xml (like ts_ls does with package.json)
        vim.lsp.config('jdtls', {
            root_dir = function(bufnr, on_dir)
                local buffer_path = vim.api.nvim_buf_get_name(bufnr)
                
                -- IMPORTANT: Skip generated sources - don't use their pom.xml
                -- If we're in target/generated-sources, find the parent module's pom.xml
                if buffer_path:match('target/generated%-sources') then
                    -- Go up to find the module pom.xml (skip the generated pom.xml)
                    local current_dir = vim.fn.fnamemodify(buffer_path, ':h')
                    while current_dir ~= '/' do
                        -- Move up until we're out of target/
                        if not current_dir:match('target/') then
                            local pom = current_dir .. '/pom.xml'
                            if vim.fn.filereadable(pom) == 1 then
                                on_dir(current_dir)
                                return
                            end
                        end
                        current_dir = vim.fn.fnamemodify(current_dir, ':h')
                    end
                end
                
                -- Find the nearest pom.xml by searching upward from current file
                local root = vim.fs.root(bufnr, { 'pom.xml' })
                if root then
                    on_dir(root)
                    return
                end

                -- Fallback to Gradle project
                root = vim.fs.root(bufnr, { 'build.gradle', 'settings.gradle' })
                if root then
                    on_dir(root)
                    return
                end
                -- Final fallback to .git
                root = vim.fs.root(bufnr, { '.git' })
                if root then
                    on_dir(root)
                end
            end,
        })
        -- Enable jdtls as recommended by official nvim-java docs
        vim.lsp.enable 'jdtls'

        -- Setup DAP configurations for Java after LSP is ready
        vim.api.nvim_create_autocmd('LspAttach', {
            pattern = '*.java',
            callback = function(args)
                local client = vim.lsp.get_client_by_id(args.data.client_id)
                if client and client.name == 'jdtls' then
                    -- Setup Java DAP (nvim-java handles this automatically)
                    -- Just call config_dap to ensure DAP configurations are set up
                    local ok, java = pcall(require, 'java')
                    if ok and java.dap then
                        pcall(java.dap.config_dap)
                    end
                    
                    -- Configure DAP for Java to use externalTerminal to avoid buffer issues
                    local dap = require('dap')
                    if dap.configurations.java then
                        for _, config in ipairs(dap.configurations.java) do
                            -- Use externalTerminal to avoid "unmodified buffer" errors
                            config.console = 'externalTerminal'
                        end
                    end

                    -- Java-specific debug keymaps
                    vim.keymap.set('n', '<leader>dt', function()
                        require('jdtls.dap').test_nearest_method()
                    end, {
                        buffer = args.buf,
                        desc = 'Debug: Test Nearest Method'
                    })

                    vim.keymap.set('n', '<leader>dT', function()
                        require('jdtls.dap').test_class()
                    end, {
                        buffer = args.buf,
                        desc = 'Debug: Test Class'
                    })

                    vim.keymap.set('n', '<leader>dc', function()
                        require('jdtls').pick_test()
                    end, {
                        buffer = args.buf,
                        desc = 'Debug: Pick Test'
                    })
                    
                    -- Setup main class configs and run/debug
                    vim.keymap.set('n', '<leader>dr', function()
                        require('jdtls.dap').setup_dap_main_class_configs()
                        vim.cmd('DapContinue')
                    end, {
                        buffer = args.buf,
                        desc = 'Debug: Run/Debug Main Class'
                    })
                end
            end,
        })
    end,
}
