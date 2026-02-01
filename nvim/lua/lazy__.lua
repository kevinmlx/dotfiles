local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
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


require ("lazy").setup{
  {'VonHeikemen/lsp-zero.nvim', branch = 'v3.x'};

  --- Uncomment these if you want to manage LSP servers from neovim
  {'williamboman/mason.nvim'};
  {'williamboman/mason-lspconfig.nvim'};
  'shaunsingh/solarized.nvim',
  -- LSP Support
  {'neovim/nvim-lspconfig'};
  -- Autocompletion
  {'hrsh7th/nvim-cmp'};
  {'hrsh7th/cmp-nvim-lsp'};
  {'L3MON4D3/LuaSnip'};

'barrett-ruth/live-server.nvim',
  --treesitter
  { 'nvim-treesitter/nvim-treesitter'},
  --DAP
  {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = {
        "williamboman/mason.nvim",
        "mfussenegger/nvim-dap",
    },
    opts = {
        handlers = {},
        ensure_installed = {
            "codelldb"
        },
    },
  },
  'rcarriga/nvim-dap-ui',
  opts = {},
  --tema
  'kdheepak/monochrome.nvim',
  'slugbyte/lackluster.nvim',
  -- "xiyaowong/transparent.nvim",
  --telescope
  'nvim-tree/nvim-web-devicons',
  'nvim-telescope/telescope.nvim',
  'nvim-lua/plenary.nvim',
  --indentado
  "lukas-reineke/indent-blankline.nvim",

  "abecodes/tabout.nvim",
  'ray-x/lsp_signature.nvim',
  -- el mismo nombre lo dice bro
  "windwp/nvim-autopairs",

  -- saltar
  "folke/which-key.nvim",
  }
