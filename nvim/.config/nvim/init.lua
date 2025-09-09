package.path = package.path .. ';' .. vim.fn.expand '$HOME' .. '/.luarocks/share/lua/5.1/?/init.lua'
package.path = package.path .. ';' .. vim.fn.expand '$HOME' .. '/.luarocks/share/lua/5.1/?.lua'
package.cpath = package.cpath .. ';' .. vim.fn.expand '$HOME' .. '/.luarocks/lib/lua/5.1/?.so'
-- tell neovim to use mise version of java
vim.g.java_home = '/Users/ryan/.local/share/mise/installs/java/22.0.2/bin/java'
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.textwidth = 80
vim.opt.colorcolumn = '+1'
-- Note: Auto-wrap on insert (fo+=a) is disabled as it can interfere with YAML and other structured formats
--Set <space> as the leader key See `:help mapleader` NOTE: Must happen before
--plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- TODO: I'd like nu in this list, but as of 2024-02-07 it poses issues
vim.g.markdown_fenced_languages = {
    'scss',
    'css',
    'javascript',
    'typescript',
    'bash',
    'lua',
    'go',
    'rust',
    'c',
    'cpp',
}
vim.opt.conceallevel = 1

vim.g.lazyvim_rust_diagnostics = 'bacon-ls'

-- Install package manager
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system {
        'git',
        'clone',
        '--filter=blob:none',
        'https://github.com/folke/lazy.nvim.git',
        '--branch=stable', -- latest stable release
        lazypath,
    }
end
vim.opt.rtp:prepend(lazypath)
vim.opt.relativenumber = true

local local_config = vim.fn.expand '~/.config/nvim/init-local.lua'
if vim.fn.filereadable(local_config) == 1 then
    vim.cmd('source ' .. local_config)
end

require('lazy').setup 'plugins'

-- [[ Setting options ]]
-- See `:help vim.o`

-- Set highlight on search
vim.o.hlsearch = false

-- Make line numbers default
vim.wo.number = true

-- Enable mouse mode
vim.o.mouse = 'a'

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.o.clipboard = 'unnamedplus'

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case insensitive searching UNLESS /C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeout = true
vim.o.timeoutlen = 500

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

vim.g.astro_typescript = 'enable'

-- [[ Basic Keymaps ]]

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true, desc = 'Move up with line wrapping' })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true, desc = 'Move down with line wrapping' })

vim.keymap.set('n', '<leader>b', require('dap').toggle_breakpoint, { desc = 'Toggle breakpoint' })

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
    callback = function()
        vim.highlight.on_yank()
    end,
    group = highlight_group,
    pattern = '*',
    desc = 'Briefly highlight yanked text',
})

local format_on_save_ts = vim.api.nvim_create_augroup('fmt-ts', {})
vim.api.nvim_create_autocmd('BufWritePre', {
    pattern = { '*.tsx', '*.ts', '*.jsx', '*.js' },
    command = 'silent! EslintFixAll',
    group = format_on_save_ts,
    desc = 'Run ESLint fix on TypeScript/JavaScript files before save',
})
vim.lsp.inlay_hint.enable()

-- LuaSnip keymaps using vim.keymap.set for better integration
vim.keymap.set({'i', 's'}, '<Tab>', function()
    local luasnip = require('luasnip')
    if luasnip.expand_or_jumpable() then
        return '<Plug>luasnip-expand-or-jump'
    else
        return '<Tab>'
    end
end, { expr = true, silent = true, desc = 'Expand or jump to next snippet position' })

vim.keymap.set({'i', 's'}, '<S-Tab>', function()
    local luasnip = require('luasnip')
    if luasnip.jumpable(-1) then
        return '<Plug>luasnip-jump-prev'
    else
        return '<S-Tab>'
    end
end, { expr = true, silent = true, desc = 'Jump to previous snippet position' })
-- Load snippets
require('luasnip.loaders.from_lua').load { paths = '~/.config/nvim/lua/snippets/' }

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
