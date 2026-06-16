return {
    {
        'vuki656/package-info.nvim',
        dependencies = {
            'MunifTanjim/nui.nvim',
        },
        keys = {
            '<leader>ps',
            '<leader>ph',
            '<leader>pt',
            '<leader>pu',
            '<leader>pd',
            '<leader>pi',
            '<leader>pp',
        },
        opts = {
            notifications = true,
            autostart = true,
        },
        config = function(_, opts)
            require('package-info').setup(opts)

            local map = function(lhs, rhs, desc)
                vim.keymap.set('n', lhs, rhs, { silent = true, noremap = true, desc = desc })
            end

            -- which-key group label (the `+` prefix is the which-key convention)
            map('<leader>p', '<Nop>', '+package info')

            map('<leader>ps', function() require('package-info').show() end, '[S]how versions')
            map('<leader>ph', function() require('package-info').hide() end, '[H]ide versions')
            map('<leader>pt', function() require('package-info').toggle() end, '[T]oggle versions')
            map('<leader>pu', function() require('package-info').update() end, '[U]pdate dependency')
            map('<leader>pd', function() require('package-info').delete() end, '[D]elete dependency')
            map('<leader>pi', function() require('package-info').install() end, '[I]nstall dependency')
            map('<leader>pp', function() require('package-info').change_version() end, 'Change [v]ersion')

            pcall(function()
                require('telescope').load_extension 'package_info'
            end)
        end,
    },
}
