return {
    'nvim-java/nvim-java',
    config = function()
        -- Setup nvim-java (this calls vim.lsp.config('jdtls', ...) internally)
        require('java').setup()
        
        -- Enable jdtls as recommended by official nvim-java docs
        vim.lsp.enable('jdtls')
    end,
}
