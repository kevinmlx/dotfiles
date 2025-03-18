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
  -- LSP Support
  {'neovim/nvim-lspconfig'};
  -- Autocompletion
  {'hrsh7th/nvim-cmp'};
  {'hrsh7th/cmp-nvim-lsp'};
  {'L3MON4D3/LuaSnip'};
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
  "RRethy/nvim-base16",
  --telescope
  'nvim-tree/nvim-web-devicons',
  'nvim-telescope/telescope.nvim',
  'nvim-lua/plenary.nvim',
  --comentarios
  "terrortylor/nvim-comment",
  --indentado
  "lukas-reineke/indent-blankline.nvim",

  'windwp/nvim-autopairs',
  "abecodes/tabout.nvim",
  'ray-x/lsp_signature.nvim',
  -- saltar
  'ggandor/leap.nvim',
  -- compiile-mode
  "ej-shafran/compile-mode.nvim",
  ---@type LazySpec
{
  "mikavilpas/yazi.nvim",
  event = "VeryLazy",
  keys = {
    -- 👇 in this section, choose your own keymappings!
    {
      "<leader>-",
      mode = { "n", "v" },
      "<cmd>Yazi<cr>",
      desc = "Open yazi at the current file",
    },
    {
      -- Open in the current working directory
      "<leader>cw",
      "<cmd>Yazi cwd<cr>",
      desc = "Open the file manager in nvim's working directory",
    },
    {
      "<c-up>",
      "<cmd>Yazi toggle<cr>",
      desc = "Resume the last yazi session",
    },
  },
  ---@type YaziConfig | {}
  opts = {
    -- if you want to open yazi instead of netrw, see below for more info
    open_for_directories = false,
    keymaps = {
      show_help = "<f1>",
    },
  },
      "folke/which-key.nvim",
}
}
