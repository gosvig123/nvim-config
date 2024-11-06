-- Specify the Python 3 host program for Neovim
vim.g.python3_host_prog = '/Users/k.gosvig/miniconda3/bin/python'

-- Leader Key
vim.g.mapleader = ' '

-- Basic Options
vim.opt.clipboard = "unnamedplus"
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.number = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.tabstop = 2
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.undofile = true
vim.opt.incsearch = true
vim.opt.termguicolors = true
vim.opt.scrolloff = 12
vim.opt.sidescrolloff = 12
vim.opt.signcolumn = "yes"
vim.opt.completeopt = {'menu', 'menuone', 'noselect'}
vim.opt.cursorline = true
vim.opt.cursorlineopt = "both"
vim.opt.guifont = "IBM Plex Mono:h16"

-- Highlight Groups for Active Line
vim.cmd([[
highlight CursorLine guibg=#1a3a1a
highlight CursorLineNr guifg=#00ff00 guibg=#1a3a1a
]])

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Plugin Specifications
local plugins = {
  -- LSP and Completion
  { "neovim/nvim-lspconfig" },
  { "hrsh7th/nvim-cmp" },
  { "hrsh7th/cmp-nvim-lsp" },
  { "L3MON4D3/LuaSnip" },
  { "saadparwaiz1/cmp_luasnip" },
  { "rafamadriz/friendly-snippets" },
  { "onsails/lspkind.nvim" },

  -- Syntax Highlighting
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },

  -- File Explorer
  { "kyazdani42/nvim-tree.lua" },

  -- Status Line
  { "nvim-lualine/lualine.nvim" },

  -- Commenting
  { "numToStr/Comment.nvim" },

  -- Auto Pairs
  { "windwp/nvim-autopairs" },

  -- Surround Text
  { "kylechui/nvim-surround" },

  -- Which Key
  { "folke/which-key.nvim" },

  -- Telescope
  { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" }, event = "BufEnter" },

  -- Theme
  { "folke/tokyonight.nvim" },

  -- Null LS for Formatting and Linting
  { "jose-elias-alvarez/null-ls.nvim" },

  -- LSP Saga for Enhanced UI
  { "glepnir/lspsaga.nvim", branch = "main" },
}

-- Setup lazy.nvim
require("lazy").setup(plugins)

-- Plugin Configurations

-- Comment.nvim
require('Comment').setup()

-- nvim-autopairs
require('nvim-autopairs').setup()

-- nvim-surround
require("nvim-surround").setup({})

-- which-key.nvim
require("which-key").setup {}

-- nvim-tree.lua
require('nvim-tree').setup {}

-- lualine.nvim
require('lualine').setup {
  options = { theme = 'tokyonight' },
}

-- null-ls.nvim
local null_ls = require("null-ls")
null_ls.setup({
  sources = {
    null_ls.builtins.formatting.prettier,
    null_ls.builtins.diagnostics.eslint,
  },
})

-- lspsaga.nvim
require('lspsaga').setup({
  -- Customize lspsaga settings if needed
})

-- Theme Configuration
require("tokyonight").setup({
  style = "storm",
  transparent = false,
  styles = {
    sidebars = "dark",
    floats = "dark",
  },
})
vim.cmd([[colorscheme tokyonight]])

-- LSP Configurations
local lspconfig = require('lspconfig')
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Consolidated on_attach function
local on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- LSP Mappings
  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', '<leader>f', function() vim.lsp.buf.format { async = true } end, bufopts)

  -- Telescope Integration
  local telescope = require('telescope.builtin')
  vim.keymap.set('n', '<leader>ff', telescope.find_files, bufopts)
  vim.keymap.set('n', '<leader>fg', telescope.live_grep, bufopts)
  vim.keymap.set('n', '<leader>fb', telescope.buffers, bufopts)
  vim.keymap.set('n', '<leader>/', function()
    telescope.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
      winblend = 10,
      previewer = false,
    })
  end, { desc = '[/] Fuzzily search in current buffer' })

  -- [Option 1] Remove or comment out goto-preview keybindings
  -- vim.keymap.set('n', '<leader>gd', "<cmd>lua require('goto-preview').goto_preview_definition()<CR>", bufopts)
  -- vim.keymap.set('n', '<leader>gt', "<cmd>lua require('goto-preview').goto_preview_type_definition()<CR>", bufopts)

  -- [Option 2] If using goto-preview, ensure the plugin is installed and configured
end

-- TypeScript Server
lspconfig.ts_ls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  root_dir = lspconfig.util.root_pattern("package.json", "tsconfig.json", "jsconfig.json", ".git"),
  settings = {
    typescript = {
      inlayHints = {
        includeInlayParameterNameHints = 'all',
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      }
    },
    javascript = {
      inlayHints = {
        includeInlayParameterNameHints = 'all',
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      }
    }
  }
}

-- Python Server
lspconfig.pyright.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = "workspace"
      }
    }
  }
}

-- Autocompletion Configuration
local cmp = require('cmp')
local luasnip = require('luasnip')
local lspkind = require('lspkind')

-- Load friendly-snippets
require("luasnip.loaders.from_vscode").lazy_load()

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'buffer' },
    { name = 'path' },
  }),
  formatting = {
    format = lspkind.cmp_format({
      mode = "symbol_text",
      max_width = 50,
    })
  },
})

-- Telescope Keybindings are already set in on_attach

-- nvim-tree.lua Keybindings (optional)
vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', { noremap = true, silent = true, desc = "Toggle File Explorer" })

-- Additional Keybindings

-- Copy and Paste
vim.keymap.set({'n', 'v'}, '<C-c>', '"+y', { noremap = true, silent = true })
vim.keymap.set('n', '<C-v>', '"+p', { noremap = true, silent = true })
vim.keymap.set('i', '<C-v>', '<C-r>+', { noremap = true, silent = true })

-- Move to Start/End of Line
vim.keymap.set({'n', 'i', 'v'}, '<A-Left>', '0', { noremap = true, silent = true })
vim.keymap.set({'n', 'i', 'v'}, '<A-Right>', '$', { noremap = true, silent = true })

-- Undo/Redo
vim.keymap.set('n', 'Z', 'u', { desc = 'Undo by Shift+Z' })
vim.keymap.set('i', '<S-Z>', '<C-o>u', { desc = 'Undo by Shift+Z' })
vim.keymap.set('n', 'X', '<C-r>', { desc = 'Redo by Shift+X' })
vim.keymap.set('i', '<S-X>', '<C-o><C-r>', { desc = 'Redo by Shift+X' })

