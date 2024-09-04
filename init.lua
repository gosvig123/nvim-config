vim.g.python3_host_prog = "/usr/bin/python3"

-- disable perl
vim.g.loaded_perl_provider = 0

if vim.g.vscode then
  -- VSCode-specific configuration
  vim.g.mapleader = " "
  vim.g.maplocalleader = " "

  -- Basic options
  vim.opt.clipboard = "unnamedplus"
  vim.opt.ignorecase = true
  vim.opt.smartcase = true

  -- Increase timeoutlen
  vim.opt.timeoutlen = 1000

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

  -- Git integration keymaps
  vscode_keymap("n", "<leader>gb", "gitlens.toggleLineBlame")
  vscode_keymap("n", "<leader>gh", "gitlens.showQuickFileHistory")
  vscode_keymap("n", "<leader>gc", "git.commit")
  vscode_keymap("n", "<leader>gp", "git.push")

  -- Debugging keymaps
  vscode_keymap("n", "<leader>db", "editor.debug.action.toggleBreakpoint")
  vscode_keymap("n", "<leader>dc", "workbench.action.debug.continue")
  vscode_keymap("n", "<leader>di", "workbench.action.debug.stepInto")
  vscode_keymap("n", "<leader>do", "workbench.action.debug.stepOver")
  vscode_keymap("n", "<leader>dO", "workbench.action.debug.stepOut")
  vscode_keymap("n", "<leader>dr", "workbench.action.debug.restart")
  vscode_keymap("n", "<leader>dt", "workbench.action.debug.start")

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
        vim.o.timeoutlen = 1000
      end,
      opts = {}
    },
    -- Keep autocompletion plugins
    {'hrsh7th/nvim-cmp'},
    {'hrsh7th/cmp-nvim-lsp'},
    {'L3MON4D3/LuaSnip'},
    { "hrsh7th/cmp-buffer" },
    { "hrsh7th/cmp-path" },
    { "hrsh7th/cmp-cmdline" },
    { "onsails/lspkind-nvim" },
    { "tpope/vim-fugitive" },
    { "lewis6991/gitsigns.nvim" },
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

  -- Autocompletion setup
  local cmp = require('cmp')
  local lspkind = require('lspkind')

  cmp.setup({
    enabled = function()
      -- Disable completion in comments
      local context = require 'cmp.config.context'
      -- Keep command mode completion enabled when cursor is in a comment
      if vim.api.nvim_get_mode().mode == 'c' then
        return true
      else
        return not context.in_treesitter_capture("comment") 
          and not context.in_syntax_group("Comment")
      end
    end,
    snippet = {
      expand = function(args)
        require('luasnip').lsp_expand(args.body)
      end,
    },
    mapping = cmp.mapping.preset.insert({
    }),
    formatting = {
      format = lspkind.cmp_format({
        mode = 'symbol_text',
        maxwidth = 50,
      })
    },
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'luasnip' },
      { name = 'path' },
      { name = 'buffer', keyword_length = 5 },
    })
  })

  -- Git integration
  require('gitsigns').setup()

  -- VSCode-specific settings
  vim.g.vscode_snippets_enabled = false  -- Prefer VSCode snippets
  vim.g.vscode_completion_enabled = false  -- Prefer VSCode completion UI
  vim.g.vscode_format_on_save = false  -- Let VSCode handle formatting

  -- Defer loading of some functionality
  vim.defer_fn(function()
    -- Add any deferred loading here
  end, 100)
end
