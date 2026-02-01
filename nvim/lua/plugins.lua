local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
  lsp_zero.default_keymaps({buffer = bufnr})
end)

require('mason').setup({})
require('mason-lspconfig').setup({
  handlers = { lsp_zero.default_setup,
  },
})




-- require("mason-nvim-dap").setup()

require'nvim-treesitter.configs'.setup{
  sync_install = false,
  auto_install = true,
  ignore_install = {},
  highlight = {
    enable = true,
    -- disable = { "python" },
    additional_vim_regex_highlighting = true,
  },
}
local cmp = require('cmp')
local cmp_action = require('lsp-zero').cmp_action()

cmp.setup({
    mapping = cmp.mapping.preset.insert({
        ['<Tab>'] = cmp_action.tab_complete(),
        ['<S-Tab>'] = cmp_action.select_prev_or_fallback(),
        ['<CR>'] = cmp.mapping.confirm({select = false}),
    }),
    window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
    },
})
        local luasnip = require("luasnip")

        -- luasnip.add_snippets("markdown", require("snippets.notes"))
        -- luasnip.add_snippets("text", require("snippets.notes"))
        -- luasnip.add_snippets("tex", require("snippets.latex"))
        -- Set up nvim-cmp.
        -- local cmp_autopairs = require("nvim-autopairs.completion.cmp")
        --
        -- cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

        cmp.setup({
            preselect = cmp.PreselectMode.None,
            snippet = {
                -- REQUIRED - you must specify a snippet engine
                expand = function(args)
                    require("luasnip").lsp_expand(args.body)
                end,
            },
            window = {
                completion = cmp.config.window.bordered(),
                documentation = cmp.config.window.bordered(),
            },
            mapping = cmp.mapping.preset.insert({
                ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                ["<C-f>"] = cmp.mapping.scroll_docs(4),
                ["<C-Space>"] = cmp.mapping.complete(),
                ["<C-e>"] = cmp.mapping.abort(),
                -- ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
                ["<CR>"] = cmp.mapping.confirm({ select = false }),

                ["<Tab>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_next_item()
                    elseif luasnip.expand_or_jumpable() then
                        luasnip.expand_or_jump()
                    else
                        fallback()
                    end
                end, { "i", "s" }),

                ["<S-Tab>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_prev_item()
                    elseif luasnip.jumpable(-1) then
                        luasnip.jump(-1)
                    else
                        fallback()
                    end
                end, { "i", "s" }),
            }),
            sources = cmp.config.sources({
                { name = "nvim_lsp" },
                { name = "luasnip" }, -- For luasnip users.
                { name = "nvim_lsp_signature_help" }, -- function arg popups while typing
            }, {
                { name = "buffer" },
            }),
        })



require("ibl").setup()

require "telescope".setup { pickers = { colorscheme = { enable_preview = true } } }

require("nvim-autopairs").setup {}

require("tabout").setup({
    tabkey = "<Tab>", -- key to trigger tabout, set to an empty string to disable
    backwards_tabkey = "<S-Tab>", -- key to trigger backwards tabout, set to an empty string to disable
    act_as_tab = true, -- shift content if tab out is not possible
    act_as_shift_tab = false, -- reverse shift content if tab out is not possible (if your keyboard/terminal supports <S-Tab>)
    default_tab = "<C-t>", -- shift default action (only at the beginning of a line, otherwise <TAB> is used)
    default_shift_tab = "<C-d>", -- reverse shift default action,
    enable_backwards = true, -- well ...
    completion = false, -- if the tabkey is used in a completion pum
    tabouts = {
        { open = "'", close = "'" },
        { open = '"', close = '"' },
        { open = "`", close = "`" },
        { open = "(", close = ")" },
        { open = "[", close = "]" },
        -- { open = "{", close = "}" },
    },
    ignore_beginning = true, --[[ if the cursor is at the beginning of a filled element it will rather tab out than shift the content ]]
    exclude = {}, -- tabout will ignore these filetypes
})

require("which-key").setup{
    preset = "helix";
}

require('live-server').setup(opts)
