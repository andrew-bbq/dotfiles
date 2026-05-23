--------------------------------------------------------------
--- Plugins
--------------------------------------------------------------
vim.call("plug#begin", "~/.config/nvim/plugged")
local Plug = vim.fn["plug#"]

-- LSP
Plug("neovim/nvim-lspconfig")
Plug("williamboman/mason.nvim")
Plug("williamboman/mason-lspconfig.nvim")

-- Treesitter
Plug("nvim-treesitter/nvim-treesitter")

-- Telescope
Plug("nvim-lua/plenary.nvim")
Plug("nvim-telescope/telescope.nvim")
Plug("nvim-telescope/telescope-fzf-native.nvim", { ["do"] = "make" })

-- Completion
Plug("hrsh7th/cmp-nvim-lsp")
Plug("hrsh7th/cmp-buffer")
Plug("hrsh7th/cmp-path")
Plug("hrsh7th/cmp-cmdline")
Plug("hrsh7th/nvim-cmp")

Plug("hrsh7th/cmp-vsnip")
Plug("hrsh7th/vim-vsnip")

-- Markdown
Plug("iamcco/markdown-preview.nvim", { ["do"] = "cd app && npx --yes yarn install" })

vim.call("plug#end")

--------------------------------------------------------------
--- Completion
--------------------------------------------------------------

local cmp = require("cmp")
cmp.setup({
	snippet = {
		expand = function(args)
			vim.fn["vsnip#anonymous"](args.body)
		end,
	},
	mapping = cmp.mapping.preset.insert({
		["<C-b>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
		["<C-Space>"] = cmp.mapping.complete(),
		["<C-e>"] = cmp.mapping.abort(),
		["<CR>"] = cmp.mapping.confirm({ select = true }),
		["<Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			else
				fallback()
			end
		end, { "i", "s" }),
		["<S-Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			else
				fallback()
			end
		end, { "i", "s" }),
	}),
	sources = cmp.config.sources({
		{ name = "nvim_lsp" },
		{ name = "vsnip" },
		{ name = "buffer" },
		{ name = "path" },
	}),
})

cmp.setup.cmdline({ "/", "?" }, {
	mapping = cmp.mapping.preset.cmdline(),
	sources = {
		{ name = "buffer" },
	},
})

cmp.setup.cmdline(":", {
	mapping = cmp.mapping.preset.cmdline(),
	sources = cmp.config.sources({
		{ name = "path" },
	}, {
		{ name = "cmdline" },
	}),
})

local capabilities = require("cmp_nvim_lsp").default_capabilities()

--------------------------------------------------------------
--- LSP
--------------------------------------------------------------

local servers = {
	ts_ls = {
		filetypes = { "typescript", "typescriptreact" },
		root_dir = vim.fs.root(0, { "package.json", "tsconfig.json" }),
		settings = {
			typescript = {
				inlayHints = {
					includeInlayParameterNameHints = "all",
					includeInlayVariableTypeHints = true,
				},
			},
		},
	},
	eslint = {
		filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
		root_dir = vim.fs.root(0, { ".eslintrc", ".eslintrc.js", ".eslintrc.json", "package.json" }),
	},
	kotlin_language_server = {
		filetypes = { "kotlin" },
		root_dir = vim.fs.root(0, { "build.gradle", "pom.xml" }),
	},
	rust_analyzer = {
		settings = {
			["rust-analyzer"] = {
				check = {
					command = "clippy",
				},
			},
		},
	},
	lua_ls = {
		settings = {
			Lua = {
				diagnostics = {
					globals = { "vim" },
				},
				format = { enable = false },
			},
		},
	},
	lemminx = {},
	yamlls = {},
}

vim.lsp.config("*", { capabilities = capabilities })

local ensure_installed = vim.tbl_keys(servers or {})
require("mason").setup()
require("mason-lspconfig").setup({
	ensure_installed = ensure_installed,
})
for server_name, server_config in pairs(servers) do
	vim.lsp.config(server_name, server_config)
	vim.lsp.enable(server_name)
end

--------------------------------------------------------------
--- Treesitter
--------------------------------------------------------------

require("nvim-treesitter").install({ "typescript", "tsx", "kotlin", "rust" })

--------------------------------------------------------------
--- Telescope
--------------------------------------------------------------

require("telescope").setup({
	pickers = {
		find_files = {
			hidden = true,
		},
	},
	defaults = {
        pickers = {
            find_files = {
                hidden = true
            }
        },
		file_ignore_patterns = { "node_modules", "dist", "%.git/" },
	},
})
require("telescope").load_extension("fzf")

--------------------------------------------------------------
--- Keymaps
--------------------------------------------------------------

local builtin = require("telescope.builtin")
vim.keymap.set("n", ";ff", builtin.find_files, {})
vim.keymap.set("n", ";g", builtin.live_grep, {})
vim.keymap.set("n", ";wg", builtin.grep_string, {})
vim.keymap.set("n", ";b", builtin.buffers, {})
vim.keymap.set("n", ";t", builtin.treesitter, {})

-- LSP jump to definition in another file
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(ev)
		local opts = { buffer = ev.buf, silent = true }
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
		vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
		vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
		vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
		vim.keymap.set("n", "<space>f", function()
			vim.lsp.buf.format({ async = true })
		end, opts)
	end,
})

--------------------------------------------------------------
--- Options
--------------------------------------------------------------
-- auto trim whitespace on save
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
	command = [[%s/\s\+$//e]],
})

-- auto format on save, too
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
	callback = function(args)
        local clients = vim.lsp.get_clients({ bufnr = args.buf })
        if #clients > 0 then
		    require("vim.lsp.buf").format({ bufnr = args.buf })
        end
	end,
})

-- diagnostic options
vim.diagnostic.config({
	virtual_text = true,
	signs = true,
	underline = true,
	update_in_insert = false,
	severity_sort = true,
})

vim.opt.number = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.softtabstop = 4
vim.opt.background = "dark"

vim.o.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
