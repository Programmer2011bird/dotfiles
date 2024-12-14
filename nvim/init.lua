--------------------------------------------- Comfy setups ---------------------------------------------
vim.g.mapleader = ' '
vim.opt.clipboard = "unnamedplus"
vim.cmd("set number")
vim.cmd("set tabstop=4")
vim.cmd("set shiftwidth=4")
vim.cmd("set expandtab")
--------------------------------------------- Lazy setup ---------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)
--------------------------------------------- Requires ---------------------------------------------
require("lazy").setup("Plugins")
require("gruvbox").setup({
    transparent_mode = true,
})
require('lualine').setup({
    options = { theme = "gruvbox-material" }
})
require("nvim-tree").setup({
  sort = {
    sorter = "case_sensitive",
  },
  view = {
    width = 25,
    side = "right"
  },
})
require("mason").setup()
require("luasnip.loaders.from_vscode").lazy_load()

local builtin = require("telescope.builtin")
local configs = require("nvim-treesitter.configs")
local cmp = require("cmp")
local capabilities = require('cmp_nvim_lsp').default_capabilities()

require('lspconfig')['lua_ls'].setup {
    capabilities = capabilities
}
require('lspconfig')['pyright'].setup {
    capabilities = capabilities
}
require("nvim-autopairs").setup({})
---------------------------------------------
vim.cmd("colorscheme gruvbox")
--------------------------------------------- Comfy keymaps ---------------------------------------------
vim.keymap.set('n', '<leader>x', ":bd<CR>", { desc = "close the current buffer" , noremap = true, silent = true })
vim.api.nvim_set_keymap('t', '<C-x>', [[<C-\><C-n>]], { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<Tab>', ':bnext<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<S-Tab>', ':bprevious<CR>', { noremap = true, silent = true })
--------------------------------------------- Telescope Nvim-Tree keymaps ---------------------------------------------
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>cm', builtin.git_commits, { desc = 'Telescope git commits' })
vim.keymap.set('n', '<C-n>', ":NvimTreeToggle<CR>" , { desc = 'Nvim-Tree toggle', noremap = true, silent = true})
--------------------------------------------- Lsp Keymaps ---------------------------------------------
vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, {})
vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, {})
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, {})
--------------------------------------------- Nvim Tree Config ---------------------------------------------
configs.setup({
    ensure_installed = { "lua", "python" },
    sync_install = false,
    highlight = { enable = true },
    indent = { enable = true },
})
--------------------------------------------- cmp config ---------------------------------------------
cmp.setup({
    snippet = {
        expand = function(args)
            require('luasnip').lsp_expand(args.body) 
        end,
    },
    window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
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
            elseif require('luasnip').expand_or_jumpable() then
                require('luasnip').expand_or_jump()  
            else
                fallback() 
            end
        end, { 'i', 's' }),
        ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item() 
            elseif require('luasnip').jumpable(-1) then
                require('luasnip').jump(-1)
            else
                fallback()  
            end
        end, { 'i', 's' }),
    }),
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'luasnip' }, 
    }, {
            { name = 'buffer' },
        })
})
cmp.setup.cmdline({ '/', '?' }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
        { name = 'buffer' }
    }
})

cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
        { name = 'path' }
    }, {
            { name = 'cmdline' }
        }),
    matching = { disallow_symbol_nonprefix_matching = false }
})

