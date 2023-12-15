return {
    "michaelb/sniprun",
    branch = "master",

    build = "sh install.sh",
    -- do 'sh install.sh 1' if you want to force compile locally
    -- (instead of fetching a binary from the github release). Requires Rust >= 1.65

    config = function()
        require("sniprun").setup({
            interpreter_options = {
                GFM_original = {
                    use_on_filetypes = {
                        "markdown.pandoc", "markdown", "vimwiki",
                        "markdown_fenced_languages", "markdown_inline"
                    },
                    default_filetype = 'typescript' -- default filetype (not github flavored markdown name)
                }
            }
        })
    end
}
