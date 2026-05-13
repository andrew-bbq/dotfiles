--------------------------------------------------------------
--- Plugins
--------------------------------------------------------------
vim.call("plug#begin", "~/.config/nvim/plugged")
local Plug = vim.fn['plug#']

-- LSP
Plug 'neovim/nvim-lspconfig'
Plug 'williamboman/mason.nvim'
Plug 'williamboman/mason-lspconfig.nvim'

-- Treesitter
Plug 'nvim-treesitter/nvim-treesitter'

-- Telescope
Plug 'nvim-lua/plenary.nvim'
Plug('nvim-telescope/telescope.nvim', { ['tag'] = '0.1.4' })
Plug('nvim-telescope/telescope-fzf-native.nvim', { ['do'] = 'make' })

vim.call('plug#end')

--------------------------------------------------------------
--- LSP
--------------------------------------------------------------

require('mason').setup()
require('mason-lspconfig').setup {
    ensure_installed = { 'ts_ls', 'eslint', 'kotlin_language_server' },
}

vim.lsp.config('ts_ls', {
    filetypes = { 'typescript', 'typescriptreact', 'typescript.tsx' },
    root_dir = vim.fs.root(0, { 'package.json', 'tsconfig.json' }),
    settings = {
        typescript = {
            inlayHints = {
                includeInlayParameterNameHints = 'all',
                includeInlayVariableTypeHints = true,
            },
        },
    },
})

vim.lsp.config('eslint', {
    filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
    root_dir = vim.fs.root(0, { '.eslintrc', '.eslintrc.js', '.eslintrc.json', 'package.json' }),
})

vim.lsp.config('kotlin_language_server', {
    filetypes = { 'kotlin' },
    root_dir = vim.fs.root(0, { 'build.gradle', 'pom.xml' }),
})

vim.lsp.enable({'ts_ls', 'eslint', 'kotlin_language_server'})

--------------------------------------------------------------
--- Treesitter
--------------------------------------------------------------

require('nvim-treesitter').install { 'typescript', 'tsx', 'kotlin', 'rust' }

--------------------------------------------------------------
--- Telescope
--------------------------------------------------------------

require('telescope').setup {
    defaults = {
        file_ignore_patterns = { 'node_modules', 'dist' },
    },
}
require('telescope').load_extension('fzf')

--------------------------------------------------------------
--- Keymaps
--------------------------------------------------------------

local builtin = require('telescope.builtin')
vim.keymap.set('n', ';ff', builtin.find_files, {})
vim.keymap.set('n', ';g', builtin.live_grep, {})
vim.keymap.set('n', ';wg', builtin.grep_string, {})
vim.keymap.set('n', ';b', builtin.buffers, {})
vim.keymap.set('n', ';t', builtin.treesitter, {})

-- LSP jump to definition in another file
vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(ev)
        local opts = { buffer = ev.buf, silent = true }
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    end,
})

--------------------------------------------------------------
--- Options
--------------------------------------------------------------

vim.opt.number = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.softtabstop = 4
vim.opt.background = 'dark'

