-- =========================
-- Neovim Configuration File
-- Author: Robson Mobarack
-- =========================

-- Set colorscheme
vim.cmd.colorscheme("elflord")

-- Indentation settings
vim.opt.expandtab = true        -- Use spaces instead of tabs
vim.opt.tabstop = 2             -- Number of spaces a tab counts for
vim.opt.softtabstop = 2         -- Number of spaces inserted when pressing <Tab>
vim.opt.smarttab = true         -- Smart handling of tabs
vim.opt.shiftwidth = 2          -- Indentation width
vim.opt.autoindent = true       -- Maintain indentation from previous line
vim.opt.smartindent = true      -- Smart automatic indentation

-- UI settings
vim.opt.number = true           -- Show absolute line numbers
vim.opt.relativenumber = true   -- Show relative line numbers
vim.opt.mouse = 'a'             -- Enable mouse support
vim.opt.completeopt = "menuone,noselect" -- Better completion menu behavior
vim.opt.termguicolors = true    -- Enable 24-bit RGB colors
vim.opt.signcolumn = "yes"      -- Always show sign column to avoid flicker
vim.opt.updatetime = 250        -- Faster diagnostics update
vim.opt.timeoutlen = 300        -- Shorter mapped sequence timeout

-- Persistent undo settings
vim.opt.undofile = true                               -- Enable persistent undo
vim.opt.undodir = vim.fn.stdpath('data') .. '/undodir'     -- Set undo directory (Windows)
-- vim.opt.undodir = vim.fn.expand('~/.vim/undodir')     -- Set undo directory (Linux)

-- =========================
-- Lazy.nvim Bootstrap
-- =========================
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

-- Leader keys
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- =========================
-- Plugin Setup with lazy.nvim
-- =========================
require("lazy").setup({
  spec = {
    -- LSP Configuration
    {
      "neovim/nvim-lspconfig",
      dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "WhoIsSethDaniel/mason-tool-installer.nvim",
      },
      config = function()
        -- Function executed when LSP attaches to buffer
        local on_attach = function(client, bufnr)
          vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
          local opts = { noremap = true, silent = true, buffer = bufnr }

          -- Keymaps for LSP features
          vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
          vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
          vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts)
          vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts)
          vim.keymap.set("n", "<leader>wl", function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
          end, opts)
          vim.keymap.set("n", "<leader>D", vim.lsp.buf.type_definition, opts)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
          vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
          vim.keymap.set("n", "<leader>f", function()
            vim.lsp.buf.format { async = true }
          end, opts)
        end

        -- Mason setup
        require("mason").setup()

        -- Mason-LSPConfig setup
        require("mason-lspconfig").setup({
          ensure_installed = {
            "lua_ls",
            "ts_ls",
            "pyright",
            "gopls",
            "html",
            "cssls",
            "angularls",
            "bashls",
            "clangd",
          },
          handlers = {
            function(server_name)
              require("lspconfig")[server_name].setup({ on_attach = on_attach })
            end,
            ["lua_ls"] = function()
              require("lspconfig").lua_ls.setup({
                on_attach = on_attach,
                settings = {
                  Lua = {
                    diagnostics = { globals = { "vim" } },
                  },
                },
              })
            end,
          },
        })

        -- Mason Tool Installer for linters/formatters/test tools
        require("mason-tool-installer").setup({
          ensure_installed = { "gotestsum", "eslint_d", "prettier" },
        })

        -- Disable virtual text for diagnostics (cleaner look)
        vim.diagnostic.config({ virtual_text = false })
      end,
    },

    -- Telescope Configuration (fuzzy finder)
    {
      'nvim-telescope/telescope.nvim',
      tag = '0.1.8',
      dependencies = { 'nvim-lua/plenary.nvim' },
      config = function()
        local builtin = require('telescope.builtin')
        require('telescope').setup({
          defaults = { file_ignore_patterns = { "node_modules", "%.git/" } }
        })
        vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
        vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
        vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
        vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
      end
    },

    -- Treesitter Configuration (syntax highlighting and parsing)
    {
      "nvim-treesitter/nvim-treesitter",
      build = ":TSUpdate",
      config = function()
        require('nvim-treesitter.configs').setup({
          ensure_installed = {
            "lua", "vim", "vimdoc", "bash", "html", "typescript", "javascript",
            "css", "json", "yaml", "go", "python", "cpp", "c", "sql", "markdown"
          },
          sync_install = false,
          auto_install = true,
          highlight = {
            enable = true,
            disable = function(lang, buf)
              local max_filesize = 100 * 1024 -- Disable for large files (>100KB)
              local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
              if ok and stats and stats.size > max_filesize then
                return true
              end
            end,
            additional_vim_regex_highlighting = false,
          },
          indent = { enable = true },
        })
      end
    }
  },

  -- Enable automatic plugin update check
  checker = { enabled = true },
})

