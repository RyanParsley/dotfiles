-- Highlight, edit, and navigate code
return {
    {
        'nvim-treesitter/nvim-treesitter',
        dependencies = {'nvim-treesitter/nvim-treesitter-textobjects'},
        config = function()
            pcall(require('nvim-treesitter.install').update {with_sync = true})
        end
    }, 'MDeiml/tree-sitter-markdown',
    'nvim-treesitter/nvim-treesitter-refactor',
    -- fork of https://github.com/nvim-treesitter/nvim-treesitter-angular with bug patch
    {"elgiano/nvim-treesitter-angular", branch = "topic/jsx-fix"}
}
