vim.opt.guicursor = ""

vim.opt.nu = true
vim.opt.relativenumber = true

vim.loader.enable()
vim.opt.filetype = "on"

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.o.completeopt = 'menuone,noselect'

vim.opt.smartindent = true

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = true
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")
vim.wo.cursorline = true
vim.o.splitright = true
vim.o.splitbelow = true
vim.opt.lazyredraw = true
vim.opt.showmode = false
-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = "yes"
-- vim.opt.timeoutlen = 300
-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'

vim.o.updatetime = 250
--quitar ~
vim.opt.fillchars = { eob = " " }

--tema
vim.g.rasmus_bold_functions = true
vim.cmd([[colorscheme base16-black-metal]])

-- fix markdown indentation settings
vim.g.markdown_recommended_style = 0
-- disable some default providers
vim.g.loaded_node_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
