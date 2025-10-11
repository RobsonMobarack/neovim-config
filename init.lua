-- ============================================================
-- Neovim Configuration File
-- Author: Robson Mobarack
-- GitHub: github.com/RobsonMobarack/neovim-config
-- ============================================================

---------------------------------------------------------------
-- =============== Basic Editor Settings =====================
---------------------------------------------------------------

-- Tabs & indentation behavior
vim.opt.expandtab = true        -- Use spaces instead of tabs
vim.opt.tabstop = 2             -- How many spaces a tab counts for
vim.opt.softtabstop = 2         -- Spaces inserted when pressing <Tab>
vim.opt.shiftwidth = 2          -- Indentation width
vim.opt.smarttab = true         -- Context-aware tab behavior
vim.opt.autoindent = true       -- Maintain indent from previous line
vim.opt.smartindent = true      -- Smarter automatic indentation

-- User interface
vim.opt.number = true           -- Show line numbers
vim.opt.relativenumber = true   -- Relative line numbers for easier movement
vim.opt.mouse = "a"             -- Enable mouse support
vim.opt.termguicolors = true    -- Enable 24-bit color
vim.opt.signcolumn = "yes"      -- Keep the sign column always visible
vim.opt.completeopt = "menuone,noselect" -- Completion behavior
vim.opt.updatetime = 250        -- Faster updates (affects diagnostics)
vim.opt.timeoutlen = 300        -- Shorter keymap timeout for better UX

-- Persistent undo
vim.opt.undofile = true
-- vim.opt.undodir = vim.fn.stdpath("data") .. "/undodir"  -- set undodir directory (Windows)
vim.opt.undodir = vim.fn.expand('~/.vim/undodir')    -- set undodir directory (Linux)

-- Leader keys (for custom shortcuts)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

---------------------------------------------------------------
-- ============== Key Map Configuration =======================
---------------------------------------------------------------

-- space + s saves the file
vim.keymap.set("n", "<leader>s", ":write<CR>", { silent = true })

-- space + h to clear search highlight
vim.keymap.set("n", "<leader>h", ":noh<CR>", { silent = true })

---------------------------------------------------------------
-- =============== Lazy.nvim Bootstrap ========================
---------------------------------------------------------------

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", repo, lazypath })
end
vim.opt.rtp:prepend(lazypath)

---------------------------------------------------------------
-- =============== Helper: Safe Require =======================
---------------------------------------------------------------

--- Tries to require a Lua module safely.
--- Returns nil if it fails instead of throwing an error.
local function safe_require(name)
  local ok, mod = pcall(require, name)
  if not ok then return nil end
  return mod
end

---------------------------------------------------------------
-- =============== Lazy Plugin Setup ==========================
---------------------------------------------------------------

require("lazy").setup({
  spec = {

    -----------------------------------------------------------
    -- Colorscheme: Catppuccin
    -----------------------------------------------------------
    {
      "catppuccin/nvim",
      name = "catppuccin",
      priority = 1000,
      config = function()
        require("catppuccin").setup({ flavour = "macchiato" })
        vim.cmd.colorscheme("catppuccin")
      end,
    },

    -----------------------------------------------------------
    -- Autocompletion: nvim-cmp + LuaSnip
    -----------------------------------------------------------
    {
      "hrsh7th/nvim-cmp",
      dependencies = {
        "hrsh7th/cmp-nvim-lsp",      -- LSP completion source
        "hrsh7th/cmp-buffer",        -- Buffer words source
        "hrsh7th/cmp-path",          -- Filesystem paths
        "L3MON4D3/LuaSnip",          -- Snippet engine
        "saadparwaiz1/cmp_luasnip",  -- LuaSnip integration
      },
      config = function()
        local cmp = require("cmp")
        local luasnip = require("luasnip")

        cmp.setup({
          snippet = {
            expand = function(args)
              luasnip.lsp_expand(args.body)
            end,
          },
          mapping = cmp.mapping.preset.insert({
            ["<C-f>"] = cmp.mapping.scroll_docs(4),
            ["<C-e>"] = cmp.mapping.abort(),
            ["<CR>"] = cmp.mapping.confirm({ select = true }),
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
            { name = "luasnip" },
            { name = "buffer" },
            { name = "path" },
          }),
        })
      end,
    },

    -----------------------------------------------------------
    -- Neogit setup: 
    -----------------------------------------------------------
    {
      "NeogitOrg/neogit",
      dependencies = {
        "nvim-lua/plenary.nvim",         -- required
        "sindrets/diffview.nvim",        -- optional - Diff integration

        -- Only one of these is needed.
        "nvim-telescope/telescope.nvim", -- optional
      },
    },

    -----------------------------------------------------------
    -- Comment-nvim setup: 
    -----------------------------------------------------------
    {
     'numToStr/Comment.nvim',
      opts = {
        padding = true,
      },
      -- extra = {
      --   ---Add comment on the line above
      --   above = 'gcO',
      --   ---Add comment on the line below
      --   below = 'gco',
      --   ---Add comment at the end of line
      --   eol = 'gcA',
      -- },
      mappings = {
        ---Operator-pending mapping; `gcc` `gbc` `gc[count]{motion}` `gb[count]{motion}`
        basic = true,
        ---Extra mapping; `gco`, `gcO`, `gcA`
        extra = true,
      },
    },

    -----------------------------------------------------------
    -- LSP Setup: Mason + New Neovim 0.11 API
    -----------------------------------------------------------
    {
      "neovim/nvim-lspconfig",
      dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "WhoIsSethDaniel/mason-tool-installer.nvim",
      },
      config = function()
        -- Called whenever an LSP client attaches to a buffer
        local function on_attach(client, bufnr)
          local opts = { noremap = true, silent = true, buffer = bufnr }
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
          vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
          vim.keymap.set("n", "<leader>f", function()
            vim.lsp.buf.format({ async = true })
          end, opts)
        end

        -- Mason setup (package manager for LSP servers and tools)
        local mason = safe_require("mason")
        if mason then mason.setup() end

        local mason_lspconfig = safe_require("mason-lspconfig")
        if not mason_lspconfig then
          vim.notify("mason-lspconfig not found", vim.log.levels.ERROR)
          return
        end

        -- List of language servers to ensure are installed and enabled
        local servers = {
          "lua_ls",
          "ts_ls", -- TypeScript/JavaScript
          "pyright",
          "gopls",
          "html",
          "cssls",
          "cssmodules_ls",
          "emmet_ls",
          "bashls",
          "clangd",
          "cmake",
          "dockerls",
          "docker_compose_language_service",
          "jsonls",
          "yamlls",
          "eslint",
          "angularls",
          "cspell_ls",
        }

        mason_lspconfig.setup({
          ensure_installed = servers,
        })

        -- Optional: install formatters/linters using Mason Tool Installer
        local mti = safe_require("mason-tool-installer")
        if mti then
          mti.setup({
            ensure_installed = { "gotestsum", "eslint_d", "prettier", "cspell" },
          })
        end

        -- Default capabilities (for nvim-cmp)
        local capabilities = vim.lsp.protocol.make_client_capabilities()
        local ok_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
        if ok_cmp then
          capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
        end

        -------------------------------------------------------
        -- Register default config for all servers
        -------------------------------------------------------
        vim.lsp.config("*", {
          on_attach = on_attach,
          capabilities = capabilities,
          root_markers = { ".git", "package.json", "pyproject.toml", "go.mod" },
        })

        -------------------------------------------------------
        -- Enable all configured servers
        -------------------------------------------------------
        for _, server in ipairs(servers) do
          vim.lsp.enable(server)
        end

        -------------------------------------------------------
        -- Diagnostics visualization preferences
        -------------------------------------------------------
        vim.diagnostic.config({
          virtual_text = false,     -- Disable inline text
          signs = true,             -- Show signs on the left
          underline = true,         -- Underline problematic text
          update_in_insert = false, -- Avoid updates while typing
        })
      end,
    },

    -----------------------------------------------------------
    -- Telescope: fuzzy finder for files and symbols
    -----------------------------------------------------------
    {
      "nvim-telescope/telescope.nvim",
      tag = "0.1.8",
      dependencies = { "nvim-lua/plenary.nvim" },
      config = function()
        local builtin = require("telescope.builtin")
        require("telescope").setup({
          defaults = { file_ignore_patterns = { "node_modules", "%.git/" } },
        })
        vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope: Find files" })
        vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope: Live grep" })
        vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope: List buffers" })
        vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope: Help tags" })
      end,
    },

    -----------------------------------------------------------
    -- Treesitter: syntax highlighting and parsing
    -----------------------------------------------------------
    {
      "nvim-treesitter/nvim-treesitter",
      build = ":TSUpdate",
      config = function()
        require("nvim-treesitter.configs").setup({
          ensure_installed = {
            "lua", "vim", "vimdoc", "bash", "html", "typescript", "javascript",
            "css", "json", "yaml", "go", "python", "cpp", "c", "sql", "markdown",
          },
          sync_install = false,
          auto_install = true,
          highlight = {
            enable = true,
            disable = function(lang, buf)
              local max_filesize = 100 * 1024 -- Skip highlight on files >100KB
              local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
              if ok and stats and stats.size > max_filesize then
                return true
              end
            end,
            additional_vim_regex_highlighting = false,
          },
          indent = { enable = true },
        })
      end,
    },
  },
  checker = { enabled = true },
})

---------------------------------------------------------------
-- =============== Optional: Compile & Run C ==================
---------------------------------------------------------------

-- Windows version: compiles and runs C files when pressing <F5>
-- vim.keymap.set("n", "<F5>", function()
--   vim.cmd("w")
--   local cmd = string.format("!gcc %s -o %s && %s.exe",
--     vim.fn.expand("%"), vim.fn.expand("%:r"), vim.fn.expand("%:r"))
--   vim.cmd(cmd)
-- end, { noremap = true, silent = false, desc = "Compile & run C (Windows)" })

-- Linux version: compiles and runs C files when pressing <F5>
vim.keymap.set("n", "<F5>", function()
  vim.cmd("w")
  local cmd = string.format("!gcc %s -o %s && ./%s",
    vim.fn.expand("%"), vim.fn.expand("%:r"), vim.fn.expand("%:r"))
  vim.cmd(cmd)
end, { noremap = true, silent = false, desc = "Compile & run C (Linux)" })

-- ========================== End of File ==========================
