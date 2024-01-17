return {
    'epwalsh/obsidian.nvim',
    -- lazy = true,
    -- event = { "BufReadPre Users/ryan/Notes/**.md" },
    -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand':
    -- event = { "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/**.md" },
    dependencies = {
        -- Required.
        'nvim-lua/plenary.nvim'
    },
    opts = {
        dir = '~/Notes', -- no need to call 'vim.fn.expand' here
        daily_notes = {
            -- Optional, if you keep daily notes in a separate directory.
            folder = 'journal/daily'
        },
        templates = {subdir = 'templates'},
        use_advanced_uri = true,
        -- Optional, by default when you use `:ObsidianFollowLink` on a link to an external
        -- URL it will be ignored but you can customize this behavior here.
        follow_url_func = function(url)
            -- Open the URL in the default web browser.
            vim.fn.jobstart {'open', url} -- Mac OS
            -- vim.fn.jobstart({"xdg-open", url})  -- linux
        end
    }
}
