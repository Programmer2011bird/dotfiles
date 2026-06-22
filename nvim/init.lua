--------------------------------------------- Comfy setups ---------------------------------------------
vim.g.mapleader = ' '
vim.opt.clipboard = "unnamedplus"
vim.g.clipboard = {
    name = "wl-clipboard",
    copy = {
        ["+"] = "wl-copy --foreground --type text/plain",
        ["*"] = "wl-copy --primary --foreground --type text/plain",
    },
    paste = {
        ["+"] = "wl-paste --no-newline",
        ["*"] = "wl-paste --primary --no-newline",
    },
    cache_enabled = true,
}

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

--------------------------------------------- Safe Transparency ---------------------------------------------
local function safe_transparency()
    local transparent_groups = {
        "Normal", "NormalNC", "NormalFloat",
        "LineNr", "SignColumn", "EndOfBuffer", "FoldColumn",
        "StatusLine", "StatusLineNC", "TabLine", "TabLineFill",
        "TelescopeNormal", "TelescopeBorder",
        "NvimTreeNormal", "NvimTreeWinSeparator"
    }
    
    for _, group in ipairs(transparent_groups) do
        pcall(function()
            local current = vim.api.nvim_get_hl(0, { name = group })
            if current then
                vim.api.nvim_set_hl(0, group, {
                    bg = "none",
                    fg = current.fg,
                    bold = current.bold,
                    italic = current.italic,
                    underline = current.underline,
                })
            end
        end)
    end
end

vim.api.nvim_create_autocmd("ColorScheme", {
    pattern = "*",
    callback = safe_transparency,
})
vim.api.nvim_exec_autocmds("ColorScheme", {})

--------------------------------------------- Plugin Configs ---------------------------------------------

-- Lualine
local ok, lualine = pcall(require, "lualine")
if ok then
    lualine.setup({
        options = {
            theme = {
                normal = {
                    a = { bg = '#222226', fg = '#DCD7BA' },
                    b = { bg = '#393836', fg = '#7E9CD8' },
                    c = { bg = '#393836', fg = '#DCD7BA' }
                },
                insert = { a = { bg = '#6A9589', fg = '#0D0C0A' } },
                visual = { a = { bg = '#E82424', fg = '#0D0C0A' } },
            }
        },
        sections = {
            lualine_a = {'mode'},
            lualine_b = {'branch', 'diff'},
            lualine_c = {'filename'},
            lualine_x = {'encoding', 'filetype'},
        }
    })
end

-- Nvim-tree
local ok, nvimtree = pcall(require, "nvim-tree")
if ok then
    nvimtree.setup({
        sort = { sorter = "case_sensitive" },
        view = { width = 25, side = "right" }
    })
end

-- Mason
local ok, mason = pcall(require, "mason")
if ok then
    mason.setup()
end

-- Luasnip snippets
pcall(require("luasnip.loaders.from_vscode").lazy_load)

-- Treesitter
-- local configs = require("nvim-treesitter.configs")
-- configs.setup({
    -- ensure_installed = { "lua", "python" },
    -- sync_install = false,
    -- highlight = { enable = true },
    -- indent = { enable = true },
-- })

-- Telescope
local ok, builtin = pcall(require, "telescope.builtin")
if not ok then
    builtin = nil
end

--------------------------------------------- LSP Configs - MODERN VERSION ---------------------------------------------
local ok, lspconfig = pcall(require, "lspconfig")
local ok_cap, capabilities = pcall(require, "cmp_nvim_lsp")

if ok and ok_cap and capabilities then
    capabilities = capabilities.default_capabilities()
    
    -- Helper function to setup LSP servers
    local function setup_lsp(server_name)
        local ok, server = pcall(require, "lspconfig." .. server_name)
        if ok and server and server.setup then
            server.setup { capabilities = capabilities }
            return true
        end
        return false
    end
    
    -- Setup your LSP servers
    setup_lsp("lua_ls")
    setup_lsp("pyright")
    setup_lsp("html")
    
    -- Note: rust-analyzer is handled by rustaceanvim plugin
else
    print("Warning: LSP or capabilities not loaded")
end

-- nvim-autopairs
local ok, autopairs = pcall(require, "nvim-autopairs")
if ok then
    autopairs.setup({})
end

--------------------------------------------- cmp config ---------------------------------------------
local ok, cmp = pcall(require, "cmp")
if ok then
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
        sources = { { name = 'buffer' } }
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
end

vim.diagnostic.config({
    signs = false,
})

-- Force enable Treesitter for Python
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    vim.bo.syntax = "on"
    pcall(vim.treesitter.start)
  end,
})

--------------------------------------------- Comfy keymaps ---------------------------------------------
vim.keymap.set('n', '<leader>x', ":bd<CR>", { desc = "close the current buffer" , noremap = true, silent = true })
vim.api.nvim_set_keymap('t', '<C-x>', [[<C-\><C-n>]], { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<Tab>', ':bnext<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<S-Tab>', ':bprevious<CR>', { noremap = true, silent = true })

--------------------------------------------- Telescope keymaps ---------------------------------------------
if builtin then
    vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
    vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
    vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
    vim.keymap.set('n', '<leader>cm', builtin.git_commits, { desc = 'Telescope git commits' })
end

vim.keymap.set('n', '<C-n>', ":NvimTreeToggle<CR>" , { desc = 'Nvim-Tree toggle', noremap = true, silent = true})

--------------------------------------------- Lsp Keymaps ---------------------------------------------
vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, {})
vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, {})
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, {})

