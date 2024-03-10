return {
    'michaelb/sniprun',
    branch = 'master',

    build = 'sh install.sh',
    -- do 'sh install.sh 1' if you want to force compile locally
    -- (instead of fetching a binary from the github release). Requires Rust >= 1.65

    config = function()
        require('sniprun').setup {
            display = {"Terminal"},
            display_options = {
                terminal_scrollback = vim.o.scrollback, -- change terminal display scrollback lines
                terminal_line_number = false, -- whether show line number in terminal window
                terminal_signcolumn = false, -- whether show signcolumn in terminal window
                terminal_position = "vertical", -- # or "horizontal", to open as horizontal split instead of vertical split
                terminal_width = 45, -- # change the terminal display option width (if vertical)
                terminal_height = 20 -- # change the terminal display option height (if horizontal)
            },
            interpreter_options = {
                Generic = {
                    nushell = {
                        supported_filetypes = {"nu"},
                        extension = ".nu",

                        interpreter = "nu",
                        compiler = "",

                        exe_name = "",
                        boilerplate_pre = "",
                        boilerplate_post = ""
                    }
                },
                GFM_original = {
                    use_on_filetypes = {
                        'markdown.pandoc', 'markdown', 'vimwiki', 'telekasten',
                        'markdown_fenced_languages', 'markdown_inline'
                    },
                    default_filetype = 'typescript' -- default filetype (not github flavored markdown name)
                }
            }
        }
    end
}
