vim.g.mapleader = ' '

vim.keymap.set('n','<leader>w', ':w<CR>', { desc = "guardar"})
vim.keymap.set('n','<leader>q', ':q<CR>', { desc = "salir"})
vim.keymap.set('n','<leader>cc', ':e ~/.config/nvim<CR>', { desc = "cambiar configuracion"})
vim.keymap.set('n','<leader>e', ':Yazi<CR>', { desc = "yazi"})
vim.keymap.set('n','<leader>l', ':Lazy<CR>', { desc = "Lazy"})
-- TIP: Disable arrow keys in normal mode
vim.keymap.set('n', '<left>', '<cmd>echo "Usa h para moverte!!"<CR>')
vim.keymap.set('n', '<right>', '<cmd>echo "Usa l para moverte!!"<CR>')
vim.keymap.set('n', '<up>', '<cmd>echo "Usa k para moverte!!"<CR>')
vim.keymap.set('n', '<down>', '<cmd>echo "Usa j para moverte!!"<CR>')
-- Set highlight on search, but clear on pressing <Esc> in normal mode
-- vim.opt.hlsearch = true
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
--busqueda
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
-- quickfix list
vim.keymap.set("n", "<A-j>", ":cnext<CR>")
vim.keymap.set("n", "<A-k>", ":cprevious<CR>")
--mover lineas
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
--saltar en el archivo
vim.keymap.set("n", "<C-j>", "<C-d>zz")
vim.keymap.set("n", "<C-k>", "<C-u>zz")
--reemplazar muchas palabras
vim.keymap.set("n", "<leader>r", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "reemplazar"})
--hacer que un archivo sea ejecutable
vim.keymap.set("n", "<leader>cx", "<cmd>!chmod +x %<CR>", { silent = true }, { desc = "chmod+x"})

vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]])

--ejecutar codigo
vim.keymap.set('n','<leader>co', ':Compile<CR>')

--tabs
vim.keymap.set('n','<A-.>', ':tabnext<CR>')
vim.keymap.set('n','<A-,>', ':tabnext<CR>')
vim.keymap.set('n','<leader>tc', ':tabclose<CR>')

--para copiar en el portapapeles de el sistema
vim.keymap.set({"n", "v"}, "<leader>y", [["+y]], { desc = "copiar al portapapeles"})
--telescope
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = "find files"})
vim.keymap.set('n', '<leader>.', builtin.find_files, { desc = "find files"})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = "grep"})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = "help"})
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = "buffers"})
vim.keymap.set('n','<leader>fk', builtin.keymaps, { desc = "keymaps"})


-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})
