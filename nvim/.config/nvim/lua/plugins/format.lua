return {
    {
        -- Autoformat
        'stevearc/conform.nvim',
        event = { 'BufReadPost', 'BufWritePost', 'BufNewFile' },
        dependencies = { 'mason.nvim' },
        lazy = true,
        cmd = 'ConformInfo',
        keys = {
            {
                -- Customize or remove this keymap to your liking
                '<leader>f',
                function()
                    require('conform').format {
                        async = true,
                        lsp_format = 'fallback',
                    }
                end,
                mode = '',
                desc = '[F]ormat buffer',
            },
        },
        opts = {
            format = {
                timeout_ms = 3000,
                async = false, -- not recommended to change
                quiet = false, -- not recommended to change
                lsp_fallback = true, -- not recommended to change
            },
            notify_on_error = false,
            format_on_save = function(bufnr)
                -- Disable "format_on_save lsp_fallback" for languages that don't
                -- have a well standardized coding style. You can add additional
                -- languages here or re-enable it for the disabled ones.
                local disable_filetypes = { c = true, cpp = true }
                return {
                    timeout_ms = 500,
                    lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
                }
            end,
            -- this chunk is from lazyvim
            -- https://www.lazyvim.org/extras/lang/markdown
            formatters = {
                ['markdown-toc'] = {
                    condition = function(_, ctx)
                        for _, line in ipairs(vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, false)) do
                            if line:find '<!%-%- toc %-%->' then
                                return true
                            end
                        end
                    end,
                },
                ['markdownlint-cli2'] = {
                    condition = function(_, ctx)
                        local diag = vim.tbl_filter(function(d)
                            return d.source == 'markdownlint'
                        end, vim.diagnostic.get(ctx.buf))
                        return #diag > 0
                    end,
                },
            },
            formatters_by_ft = {
                lua = { 'stylua' },
                fish = { 'fish_indent' },
                sh = { 'shfmt' },
                -- Conform can also run multiple formatters sequentially
                -- python = { "isort", "black" },
                --
                -- You can use a sub-list to tell conform to run *until* a formatter
                -- is found.
                java = { { 'prettierd', 'prettier' } },
                javascript = { { 'prettierd', 'prettier' } },
                typescript = { { 'prettierd', 'prettier' } },
                ['markdown'] = { { 'prettierd', 'prettier' }, 'markdownlint-cli2', 'markdown-toc' },
                ['markdown.mdx'] = { { 'prettierd', 'prettier' }, 'markdownlint-cli2', 'markdown-toc' },
            },
        },
    },
    {
        'mfussenegger/nvim-lint',
        event = { 'BufReadPost', 'BufWritePost', 'BufNewFile' },
        opts = {
            -- Event to trigger linters
            events = { 'BufWritePost', 'BufReadPost', 'InsertLeave' },
            linters_by_ft = {
                fish = { 'fish' },
                markdown = { 'markdownlint-cli2' },
                -- Use the "*" filetype to run linters on all filetypes.
                -- ['*'] = { 'global linter' },
                -- Use the "_" filetype to run linters on filetypes that don't have other linters configured.
                -- ['_'] = { 'fallback linter' },
                -- ["*"] = { "typos" },
            },
            -- LazyVim extension to easily override linter options
            -- or add custom linters.
            ---@type table<string,table>
            linters = {
                -- -- Example of using selene only when a selene.toml file is present
                -- selene = {
                --   -- `condition` is another LazyVim extension that allows you to
                --   -- dynamically enable/disable linters based on the context.
                --   condition = function(ctx)
                --     return vim.fs.find({ "selene.toml" }, { path = ctx.filename, upward = true })[1]
                --   end,
                -- },
            },
        },
        config = function(_, opts)
            local M = {}

            local lint = require 'lint'
            for name, linter in pairs(opts.linters) do
                if type(linter) == 'table' and type(lint.linters[name]) == 'table' then
                    lint.linters[name] = vim.tbl_deep_extend('force', lint.linters[name], linter)
                    if type(linter.prepend_args) == 'table' then
                        vim.list_extend(lint.linters[name].args, linter.prepend_args)
                    end
                else
                    lint.linters[name] = linter
                end
            end
            lint.linters_by_ft = opts.linters_by_ft

            function M.debounce(ms, fn)
                local timer = vim.uv.new_timer()
                return function(...)
                    local argv = { ... }
                    timer:start(ms, 0, function()
                        timer:stop()
                        vim.schedule_wrap(fn)(unpack(argv))
                    end)
                end
            end

            function M.lint()
                -- Use nvim-lint's logic first:
                -- * checks if linters exist for the full filetype first
                -- * otherwise will split filetype by "." and add all those linters
                -- * this differs from conform.nvim which only uses the first filetype that has a formatter
                local names = lint._resolve_linter_by_ft(vim.bo.filetype)

                -- Create a copy of the names table to avoid modifying the original.
                names = vim.list_extend({}, names)

                -- Add fallback linters.
                if #names == 0 then
                    vim.list_extend(names, lint.linters_by_ft['_'] or {})
                end

                -- Add global linters.
                vim.list_extend(names, lint.linters_by_ft['*'] or {})

                -- Filter out linters that don't exist or don't match the condition.
                local ctx = { filename = vim.api.nvim_buf_get_name(0) }
                ctx.dirname = vim.fn.fnamemodify(ctx.filename, ':h')
                names = vim.tbl_filter(function(name)
                    local linter = lint.linters[name]
                    if not linter then
                        LazyVim.warn('Linter not found: ' .. name, { title = 'nvim-lint' })
                    end
                    return linter and not (type(linter) == 'table' and linter.condition and not linter.condition(ctx))
                end, names)

                -- Run linters.
                if #names > 0 then
                    lint.try_lint(names)
                end
            end

            vim.api.nvim_create_autocmd(opts.events, {
                group = vim.api.nvim_create_augroup('nvim-lint', { clear = true }),
                callback = M.debounce(100, M.lint),
            })
        end,
    },
}
