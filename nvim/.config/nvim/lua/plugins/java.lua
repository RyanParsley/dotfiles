return {
    'nvim-java/nvim-java',
    config = function()
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
        }

        -- Override jdtls root_dir to find closest pom.xml (like ts_ls does with package.json)
        vim.lsp.config('jdtls', {
            root_dir = function(bufnr, on_dir)
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
    end,
}
