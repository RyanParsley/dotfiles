package.path = package.path .. ';' .. vim.fn.expand '$HOME' .. '/.luarocks/share/lua/5.1/?/init.lua'
package.path = package.path .. ';' .. vim.fn.expand '$HOME' .. '/.luarocks/share/lua/5.1/?.lua'
package.cpath = package.cpath .. ';' .. vim.fn.expand '$HOME' .. '/.luarocks/lib/lua/5.1/?.so'
-- tell neovim to use mise version of java
vim.g.java_home = '/Users/ryan/.local/share/mise/installs/java/22.0.2/bin/java'
vim.cmd 'set expandtab'
vim.cmd 'set tabstop=2'
vim.cmd 'set softtabstop=2'
vim.cmd 'set shiftwidth=2'
vim.cmd 'set textwidth=80'
vim.cmd 'set colorcolumn=+1'
-- I almost like this next line. It auto wraps text as you write. It's nice for
-- markdown, but bad for yaml and other things with tags. Perhaps theres a
-- subtly different way to use it?
--vim.cmd 'set fo+=a'
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
vim.opt.rnu = true

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
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

vim.keymap.set('n', '<leader>b', require('dap').toggle_breakpoint)

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
    callback = function()
        vim.highlight.on_yank()
    end,
    group = highlight_group,
    pattern = '*',
})

local format_on_save_ts = vim.api.nvim_create_augroup('fmt-ts', {})
vim.api.nvim_create_autocmd('BufWritePre', {
    pattern = { '*.tsx', '*.ts', '*.jsx', '*.js' },
    command = 'silent! EslintFixAll',
    group = format_on_save_ts,
})
vim.lsp.inlay_hint.enable()

-- Yes, we're just executing a bunch of Vimscript, but this is the officially
-- endorsed method; see https://github.com/L3MON4D3/LuaSnip#keymaps
vim.cmd [[
" Use Tab to expand and jump through snippets
imap <silent><expr> <Tab> luasnip#expand_or_jumpable() ? '<Plug>luasnip-expand-or-jump' : '<Tab>' 
smap <silent><expr> <Tab> luasnip#jumpable(1) ? '<Plug>luasnip-jump-next' : '<Tab>'

" Use Shift-Tab to jump backwards through snippets
imap <silent><expr> <S-Tab> luasnip#jumpable(-1) ? '<Plug>luasnip-jump-prev' : '<S-Tab>'
smap <silent><expr> <S-Tab> luasnip#jumpable(-1) ? '<Plug>luasnip-jump-prev' : '<S-Tab>'
]]
-- Load snippets
require('luasnip.loaders.from_lua').load { paths = '~/.config/nvim/lua/snippets/' }

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
