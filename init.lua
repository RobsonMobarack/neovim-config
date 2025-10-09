-- =========================
-- Neovim Configuration File
-- Author: Robson Mobarack
-- =========================

-- Colorscheme (you can change to any modern theme you prefer)
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
vim.opt.signcolumn = "yes"     -- Always show sign column to avoid flicker
vim.opt.updatetime = 250        -- Faster diagnostics update
vim.opt.timeoutlen = 300        -- Shorter mapped sequence timeout

-- Persistent undo settings
vim.opt.undofile = true                               -- Enable persistent undo
-- vim.opt.undodir = vim.fn.expand('~/.vim/undodir')     -- Set undo directory (Linux)
vim.opt.undodir = vim.fn.stdpath('data') .. '/undodir'     -- Set undo directory (Windows)

-- =========================
-- Bootstrap lazy.nvim
-- =========================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim: ", "ErrorMsg" },
      { out, "WarningMsg" },
      { "Press any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Leader keys (set before plugins so mappings using leader are correct)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- =========================
-- Helper: safe require
-- =========================
local function safe_require(name)
  local ok, m = pcall(require, name)
  if not ok then
    return nil
  end
  return m
end

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
        -- on_attach runs when a server attaches to a buffer.
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

        -- Ensure Mason is available
        local mason = safe_require("mason")
        if not mason then
          vim.notify("mason.nvim not found", vim.log.levels.ERROR)
          return
        end
        mason.setup()

        local mason_lspconfig = safe_require("mason-lspconfig")
        if not mason_lspconfig then
          vim.notify("mason-lspconfig.nvim not found", vim.log.levels.ERROR)
          return
        end

        -- List of LSPs we want to ensure are available. These are the *lspconfig* server names
        -- (not necessarily the npm/package names in Mason registry). The setup below will
        -- attempt to configure each available server safely.
        local servers = {
          -- Core / common servers
          "lua_ls",        -- Lua (sumneko replacement)
          "ts_ls",         -- TypeScript/JavaScript (lspconfig uses ts_ls currently)
          "pyright",       -- Python
          "gopls",         -- Go
          "html",          -- HTML
          "cssls",         -- CSS
          "cssmodules_ls", -- CSS Modules (optional)
          "emmet_ls",      -- Emmet (useful for HTML/CSS)
          "bashls",        -- Bash
          "clangd",        -- C/C++
          "cmake",         -- CMake (cmake-language-server)
          "dockerls",      -- Dockerfile
          "docker_compose_language_service", -- docker-compose
          "jsonls",        -- JSON
          "yamlls",        -- YAML
          "eslint",        -- ESLint
          "angularls",     -- Angular
          "cspell_ls"
        }

        -- Ask mason-lspconfig to ensure the servers are installed and enable automatic activation
        mason_lspconfig.setup({
          ensure_installed = servers,
          -- automatic_enable will call `vim.lsp.enable()` for installed servers
          -- (this is the new behavior in mason-lspconfig v2+)
          automatic_enable = true,
        })

        -- Configure mason-tool-installer for non-LSP tools (formatters, linters, test tools)
        local mti = safe_require("mason-tool-installer")
        if mti then
          mti.setup({
            ensure_installed = { "gotestsum", "eslint_d", "prettier", "cspell" },
          })
        end

        -- Configure LSP servers via lspconfig directly.
        -- Since mason-lspconfig v2 removed setup_handlers, we configure servers ourselves.
        local lspconfig = safe_require("lspconfig")
        if not lspconfig then
          vim.notify("nvim-lspconfig not found", vim.log.levels.ERROR)
          return
        end

        -- Default capabilities (for completion plugins like nvim-cmp)
        local capabilities = vim.lsp.protocol.make_client_capabilities()
        local has_cmp_nvim_lsp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
        if has_cmp_nvim_lsp then
          capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
        end

        -- Helper to safely setup a server if it's provided by lspconfig
        local function try_setup(server_name, opts)
          local ok, server = pcall(function() return lspconfig[server_name] end)
          if not ok or server == nil then
            -- not supported by lspconfig in this Neovim version
            return false
          end
          local final_opts = vim.tbl_deep_extend("force", {
            on_attach = on_attach,
            capabilities = capabilities,
          }, opts or {})
          -- Protect the setup call
          local s_ok, s_err = pcall(server.setup, final_opts)
          if not s_ok then
            vim.notify(string.format("Failed to setup LSP '%s': %s", server_name, s_err), vim.log.levels.WARN)
            return false
          end
          return true
        end

        -- Example: special settings for some servers
        try_setup("lua_ls", {
          settings = {
            Lua = {
              runtime = { version = "LuaJIT" },
              diagnostics = { globals = { "vim" } },
              workspace = { library = vim.api.nvim_get_runtime_file("", true) },
              telemetry = { enable = false },
            },
          },
        })

        -- Typescript: prefer ts_ls if available in this lspconfig version
        if not try_setup("ts_ls") then
          -- Older lspconfig versions might still use 'tsserver'
          try_setup("tsserver")
        end

        -- clangd with a small example customization
        try_setup("clangd", { cmd = { "clangd" } })

        -- Fallback: attempt to setup the rest of the servers from the list
        for _, srv in ipairs(servers) do
          -- skip ones we've explicitly configured already
          if srv ~= "lua_ls" and srv ~= "ts_ls" and srv ~= "tsserver" and srv ~= "clangd" then
            try_setup(srv)
          end
        end

        -- Diagnostics UI: disable virtual_text by default for cleaner view
        vim.diagnostic.config({ virtual_text = false, signs = true, underline = true, update_in_insert = false })
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

-- EOF

