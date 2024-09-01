-- Check if running inside VSCode
if vim.g.vscode then
  -- VSCode-specific configuration
  vim.g.mapleader = " "
  vim.g.maplocalleader = " "

  -- Basic options
  vim.opt.clipboard = "unnamedplus"
  vim.opt.ignorecase = true
  vim.opt.smartcase = true

  -- Folding options
  vim.opt.foldmethod = "expr"
  vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
  vim.opt.foldlevelstart = 99 -- Start with all folds open

  -- VSCode-specific keymaps
  local vscode = require("vscode-neovim")
  local function vscode_keymap(mode, lhs, rhs, opts)
    opts = opts or {}
    opts.silent = opts.silent ~= false
    vim.keymap.set(mode, lhs, function()
      vscode.call(rhs)
    end, opts)
  end

  -- Navigation
  vscode_keymap("n", "<C-j>", "workbench.action.navigateDown")
  vscode_keymap("n", "<C-k>", "workbench.action.navigateUp")
  vscode_keymap("n", "<C-h>", "workbench.action.navigateLeft")
  vscode_keymap("n", "<C-l>", "workbench.action.navigateRight")

  -- File and symbol search
  vscode_keymap("n", "<leader>sf", "workbench.action.quickOpen")
  vscode_keymap("n", "<leader>sg", "workbench.action.findInFiles")

  -- Code actions
  vscode_keymap("n", "<leader>ca", "editor.action.quickFix")
  vscode_keymap("n", "<leader>rn", "editor.action.rename")

  -- Comments
  vscode_keymap("n", "gcc", "editor.action.commentLine")
  vscode_keymap("v", "gc", "editor.action.commentLine")

  -- Formatting
  vscode_keymap("n", "<leader>f", "editor.action.formatDocument")

  -- Which-key integration
  vscode_keymap("n", "<leader>", "whichkey.show")

  -- LSP-like functionality
  vscode_keymap("n", "gd", "editor.action.revealDefinition")
  vscode_keymap("n", "gr", "editor.action.goToReferences")
  vscode_keymap("n", "gi", "editor.action.goToImplementation")
  vscode_keymap("n", "K", "editor.action.showHover")

  -- Folding keymaps
  vscode_keymap("n", "za", "editor.toggleFold")
  vscode_keymap("n", "zR", "editor.unfoldAll")
  vscode_keymap("n", "zM", "editor.foldAll")
  vscode_keymap("n", "zo", "editor.unfold")
  vscode_keymap("n", "zc", "editor.fold")

  -- Additional VSCode-specific keymaps
  vscode_keymap("n", "<leader>e", "workbench.action.toggleSidebarVisibility")
  vscode_keymap("n", "<leader>x", "workbench.action.closeActiveEditor")
  vscode_keymap("n", "<leader>w", "workbench.action.files.save")
  vscode_keymap("n", "<leader>q", "workbench.action.closeWindow")
  vscode_keymap("n", "<leader>b", "workbench.action.toggleActivityBarVisibility")
  vscode_keymap("n", "<leader>z", "workbench.action.toggleZenMode")

  -- Plugins
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

  require("lazy").setup({
    -- Existing plugins
    { "tpope/vim-surround" },
    { "gcmt/wildfire.vim" },
    {
      "folke/which-key.nvim",
      event = "VeryLazy",
      init = function()
        vim.o.timeout = true
        vim.o.timeoutlen = 300
      end,
      opts = {}
    },
    -- Tree-sitter
    {
      "nvim-treesitter/nvim-treesitter",
      build = ":TSUpdate",
      config = function()
        require("nvim-treesitter.configs").setup({
          ensure_installed = { "lua", "vim", "vimdoc", "javascript", "typescript", "python", "html", "css" },
          highlight = {
            enable = true,
            additional_vim_regex_highlighting = false,
          },
          indent = { enable = true },
          incremental_selection = { enable = true },
          -- Folding
          fold = { enable = true },
        })
      end,
    },
    -- Additional syntax highlighting plugins
    { "sheerun/vim-polyglot" },
    {
      "norcalli/nvim-colorizer.lua",
      config = function()
        require("colorizer").setup()
      end,
    },
    {
      "lukas-reineke/indent-blankline.nvim",
      main = "ibl",
      opts = {},
    },
    -- Folding preview
    {
      "anuvyklack/pretty-fold.nvim",
      config = function()
        require("pretty-fold").setup()
      end
    },
    {
      "anuvyklack/fold-preview.nvim",
      dependencies = "anuvyklack/keymap-amend.nvim",
      config = function()
        require("fold-preview").setup()
      end
    },
    -- LSP Support
    {'neovim/nvim-lspconfig'},
    {'williamboman/mason.nvim'},
    {'williamboman/mason-lspconfig.nvim'},
    -- Autocompletion
    {'hrsh7th/nvim-cmp'},
    {'hrsh7th/cmp-nvim-lsp'},
    {'L3MON4D3/LuaSnip'},
  }, {
    performance = {
      rtp = {
        disabled_plugins = {
          "gzip",
          "matchit",
          "matchparen",
          "netrwPlugin",
          "tarPlugin",
          "tohtml",
          "tutor",
          "zipPlugin",
        },
      },
    },
  })

  -- LSP Configuration
  local servers = {
    -- Python LSP
    pyright = {},
    
    -- JavaScript/TypeScript LSP
    tsserver = {},

    -- Optional: Add more LSPs as needed
    -- eslint = {},
    -- pylsp = {}, -- An alternative to pyright
  }

  -- Ensure the servers above are installed
  require('mason').setup()
  require('mason-lspconfig').setup {
    ensure_installed = vim.tbl_keys(servers),
    handlers = {
      function(server_name)
        local server = servers[server_name] or {}
        -- This sets up the LSP with default configurations
        require('lspconfig')[server_name].setup(server)
      end,
    },
  }

  -- Set up LSP keybindings
  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function(ev)
      local opts = { buffer = ev.buf }
      vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
      vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
      vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
      vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
      vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
      vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
      vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    end,
  })

  -- Autocompletion setup
  local cmp = require('cmp')
  cmp.setup({
    snippet = {
      expand = function(args)
        require('luasnip').lsp_expand(args.body)
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
    }, {
      { name = 'buffer' },
    })
  })

  -- Additional VSCode-specific settings
  vim.g.vscode_snippets_enabled = true
  vim.g.vscode_completion_enabled = true
  vim.g.vscode_format_on_save = true

  -- Defer loading of some functionality
  vim.defer_fn(function()
    -- Add any deferred loading here
  end, 100)
end
