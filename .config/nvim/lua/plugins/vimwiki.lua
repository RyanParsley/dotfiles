return {
    'vimwiki/vimwiki',
    config = function()
        vim.g.vimwiki_list = {
            {
                name = "notes",
                path = '~/Projects/notes',
                syntax = 'markdown',
                ext = '.md'
            }
        }
    end
}
