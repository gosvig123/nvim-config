-- Specify the Python 3 host program for Neovim
vim.g.python3_host_prog = '/Users/k.gosvig/miniconda3/bin/python'

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
-- Basic options
vim.opt.clipboard = "unnamedplus"
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.number = true
vim.opt.expandtab = true      -- Use spaces instead of tabs
vim.opt.shiftwidth = 2        -- Size of an indent
vim.opt.softtabstop = 2       -- Number of spaces tabs count for in insert mode
vim.opt.tabstop = 2           -- Number of spaces tabs count for
vim.opt.smartindent = true    -- Insert indents automatically
vim.opt.wrap = false          -- Disable line wrap
vim.opt.undofile = true       -- Enable persistent undo
vim.opt.incsearch = true      -- Show search matches as you type
vim.opt.termguicolors = true  -- Enable 24-bit RGB colors
vim.opt.scrolloff = 8         -- Keep 8 lines above/below cursor when scrolling
vim.opt.sidescrolloff = 8     -- Keep 8 columns left/right of cursor when scrolling horizontally
vim.opt.signcolumn = "yes"    -- Always show the signcolumne

-- Add 12-line jumps and enhanced syntax highlighting when not in VSCode
if not vim.g.vscode then
  -- 12-line jumps
  vim.keymap.set('n', '<C-S-Up>', '12k', { noremap = true, silent = true })
  vim.keymap.set('n', '<C-S-Down>', '12j', { noremap = true, silent = true })

  -- Enhanced syntax highlighting
  vim.opt.syntax = "on"
  vim.opt.synmaxcol = 200
  vim.cmd([[
    augroup enhanced_syntax
      autocmd!
      autocmd BufEnter * :syntax sync fromstart
    augroup END
  ]])

  -- Add Treesitter for even better syntax highlighting
  local status_ok, treesitter_config = pcall(require, 'nvim-treesitter.configs')
  if status_ok then
    treesitter_config.setup {
      ensure_installed = { "lua", "vim", "vimdoc", "query", "javascript", "typescript", "python" },
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
    }
  else
    print("Treesitter not found. Some features may be limited.")
  end
end

if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Plugin specifications
local plugins = {
  -- LSP
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
    },
  },
  -- Autocompletion
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-vsnip",
      "hrsh7th/vim-vsnip",
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      local configs = require("nvim-treesitter.configs")
      configs.setup({
          ensure_installed = { "lua", "vim", "vimdoc", "query" },
          sync_install = false,
          highlight = { enable = true },
          indent = { enable = true },
          autotag = { enable = true },
          context_commentstring = { enable = true, enable_autocmd = true },
      })
    end
  },
  {
    "onsails/lspkind.nvim",
    config = function()
      require('lspkind').init()
    end
  },
  {
    "rafamadriz/friendly-snippets",
  },
  {
    "L3MON4D3/LuaSnip",
    dependencies = {
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
    },
  },
  {
    "saadparwaiz1/cmp_luasnip",
  },
  -- Add Telescope to your plugins list
  { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },

  -- Add SuperMaven only when not in VSCode
  {
    "MunifTanjim/nui.nvim",
    cond = not vim.g.vscode,
  },
  {
    "supermaven-inc/supermaven-nvim",
    cond = not vim.g.vscode,
    config = function()
      require("supermaven-nvim").setup({})
    end
  },
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
  },
}

-- Setup lazy.nvim
require("lazy").setup(plugins)

-- Basic VS Code configuration for TypeScript and Python development

-- Autocompletion
vim.opt.completeopt = {'menu', 'menuone', 'noselect'}

-- Configure nvim-cmp
local cmp = require('cmp')
local lspkind = require('lspkind')
local luasnip = require('luasnip')

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
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'vsnip' },
  }, {
    { name = 'buffer' },
  }),
  formatting = {
    format = lspkind.cmp_format({
      mode = "symbol",
      max_width = 50,
    })
  }
})

-- Set up lspconfig with cmp
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Enable native LSP
local lspconfig = require('lspconfig')

-- TypeScript
local status, lspconfig = pcall(require, 'lspconfig')
if not status then
  print("Failed to load lspconfig")
  return
end

-- Apply the fix for TypeScript server
local server_name = "tsserver"
if server_name == "tsserver" then
  server_name = "ts_ls"
end

if lspconfig[server_name] then
  local ts_status, _ = pcall(lspconfig[server_name].setup, {
    capabilities = capabilities,
    on_attach = on_attach,
    root_dir = lspconfig.util.root_pattern("package.json", "tsconfig.json", "jsconfig.json", ".git"),
    init_options = {
      preferences = {
        importModuleSpecifierPreference = "relative",
      },
    },
    single_file_support = false,
    settings = {
      typescript = {
        inlayHints = {
          includeInlayParameterNameHints = 'all',
          includeInlayParameterNameHintsWhenArgumentMatchesName = true,
          includeInlayFunctionParameterTypeHints = true,
          includeInlayVariableTypeHints = true,
          includeInlayVariableTypeHintsWhenTypeMatchesName = true,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
          includeInlayEnumMemberValueHints = true,
        }
      },
      javascript = {
        inlayHints = {
          includeInlayParameterNameHints = 'all',
          includeInlayParameterNameHintsWhenArgumentMatchesName = true,
          includeInlayFunctionParameterTypeHints = true,
          includeInlayVariableTypeHints = true,
          includeInlayVariableTypeHintsWhenTypeMatchesName = true,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
          includeInlayEnumMemberValueHints = true,
        }
      }
    }
  })
  if not ts_status then
    print("Failed to set up " .. server_name)
  end
else
  print(server_name .. " not available in lspconfig")
end

-- Python
lspconfig.pyright.setup {
  capabilities = capabilities
}

-- Keybindings
local opts = { noremap=true, silent=true }
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, bufopts)
  vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, bufopts)
end

-- Add on_attach to both language servers
lspconfig.pyright.setup {
  on_attach = on_attach,
  capabilities = capabilities
}

if vim.g.vscode then
  -- VSCode extension
  local vscode = require('vscode-neovim')

  -- Autocompletion
  vim.opt.completeopt = {'menu', 'menuone', 'noselect'}

  -- Configure nvim-cmp
  local cmp = require('cmp')
  local luasnip = require('luasnip')

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
      ['<Tab>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        elseif luasnip.expand_or_jumpable() then
          luasnip.expand_or_jump()
        else
          fallback()
        end
      end, { 'i', 's' }),
      ['<S-Tab>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        elseif luasnip.jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback()
        end
      end, { 'i', 's' }),
    }),
    sources = cmp.config.sources({
      { name = 'vscode-neovim' },
      { name = 'nvim_lsp' },
      { name = 'luasnip' },
      { name = 'buffer' },
    })
  })

  -- Set up lspconfig
  local lspconfig = require('lspconfig')
  local capabilities = require('cmp_nvim_lsp').default_capabilities()

  -- Common on_attach function
  local on_attach = function(client, bufnr)
    -- Enable completion triggered by <c-x><c-o>
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

    -- Add any other common setup here
  end

  -- Configure tsserver
  lspconfig.tsserver.setup {
    capabilities = capabilities,
    on_attach = on_attach,
    root_dir = lspconfig.util.root_pattern("package.json", "tsconfig.json", "jsconfig.json", ".git"),
    init_options = {
      preferences = {
        importModuleSpecifierPreference = "relative",
      },
    },
    single_file_support = false,
    settings = {
      typescript = {
        inlayHints = {
          includeInlayParameterNameHints = 'all',
          includeInlayParameterNameHintsWhenArgumentMatchesName = true,
          includeInlayFunctionParameterTypeHints = true,
          includeInlayVariableTypeHints = true,
          includeInlayVariableTypeHintsWhenTypeMatchesName = true,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
          includeInlayEnumMemberValueHints = true,
        }
      },
      javascript = {
        inlayHints = {
          includeInlayParameterNameHints = 'all',
          includeInlayParameterNameHintsWhenArgumentMatchesName = true,
          includeInlayFunctionParameterTypeHints = true,
          includeInlayVariableTypeHints = true,
          includeInlayVariableTypeHintsWhenTypeMatchesName = true,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
          includeInlayEnumMemberValueHints = true,
        }
      }
    }
  }

  -- Configure pyright
  lspconfig.pyright.setup {
    capabilities = capabilities,
    on_attach = on_attach,
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

  -- ... rest of your existing VSCode-specific configuration ...
end

-- Set up Telescope
local telescope = require('telescope.builtin')
vim.keymap.set('n', '<space>f', telescope.find_files, {})
vim.keymap.set('n', '<space>/', telescope.live_grep, {})
vim.keymap.set('n', '<space>b', telescope.buffers, {})
-- Add this new keymapping for searching in the current buffer
vim.keymap.set('n', '<leader>/', function()
  telescope.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer' })

-- Add SuperMaven configuration (only when not in VSCode)
if not vim.g.vscode then
  local supermaven = require('supermaven-nvim')
  supermaven.setup({
    keymaps = {
      accept_suggestion = "<Tab>",
      clear_suggestion = "<C-]>",
      accept_word = "<C-j>",
    },
    ignore_filetypes = { cpp = true },
    color = {
      suggestion_color = "#ffffff",
      cterm = 244,
    },
  })
end

-- Set the colorscheme
vim.cmd[[colorscheme tokyonight]]

vim.g.tokyonight_style = "storm" -- Available options: night, storm, day
vim.g.tokyonight_italic_functions = true
vim.g.tokyonight_sidebars = { "qf", "vista_kind", "terminal", "packer" }

-- Add these keymappings after the existing keymappings section

-- Copy and paste
vim.keymap.set('n', '<C-c>', '"+y', { noremap = true, silent = true })
vim.keymap.set('v', '<C-c>', '"+y', { noremap = true, silent = true })
vim.keymap.set('n', '<C-v>', '"+p', { noremap = true, silent = true })
vim.keymap.set('i', '<C-v>', '<C-r>+', { noremap = true, silent = true })

-- Move to start/end of line (using Alt/Option key, which works in most terminals including Warp)
vim.keymap.set('n', '<A-Left>', '0', { noremap = true, silent = true })
vim.keymap.set('i', '<A-Left>', '<C-o>0', { noremap = true, silent = true })
vim.keymap.set('n', '<A-Right>', '$', { noremap = true, silent = true })
vim.keymap.set('i', '<A-Right>', '<C-o>$', { noremap = true, silent = true })

-- Add visual mode mappings as well
vim.keymap.set('v', '<A-Left>', '0', { noremap = true, silent = true })
vim.keymap.set('v', '<A-Right>', '$', { noremap = true, silent = true })

-- Set up line highlighting
vim.opt.cursorline = true  -- Highlight the current line
vim.opt.cursorlineopt = "both"  -- Highlight both the line and line number

-- Define highlight groups for active line
vim.cmd([[
  highlight CursorLine guibg=#1a3a1a
  highlight CursorLineNr guifg=#00ff00 guibg=#1a3a1a
]])

print("LSP configuration completed")
