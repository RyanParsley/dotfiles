return {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v2.x",
    dependencies = {
        "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons",
        "MunifTanjim/nui.nvim"
    },
    opts = {
        filesystem = {
            filtered_items = {
                visible = false,
                show_hidden_count = false,
                hide_dotfiles = false,
                hide_gitignored = false,
                hide_by_name = {'.git', '.DS_Store', 'thumbs.db'},
                never_show = {'.DS_Store'}
            }
        }
    }
}
