local config = {
    cmd = { vim.fn.expand '~/.local/share/nvim/mason/packages/jdtls/bin/jdtls' },
    root_dir = vim.fs.dirname(vim.fs.find({ 'gradlew', '.git', 'mvnw' }, { upward = true })[1] or vim.fn.getcwd()),
}
require('jdtls').start_or_attach(config)
