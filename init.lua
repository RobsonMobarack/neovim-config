-- ============================================================
-- Neovim Configuration File
-- Author: Robson Mobarack
-- GitHub: github.com/RobsonMobarack/neovim-config
-- ============================================================

---------------------------------------------------------------
-- =============== Basic Editor Settings =====================
---------------------------------------------------------------

-- Tabs & indentation behavior
vim.opt.expandtab = true -- Use spaces instead of tabs
vim.opt.tabstop = 2 -- How many spaces a tab counts for
vim.opt.softtabstop = 2 -- Spaces inserted when pressing <Tab>
vim.opt.shiftwidth = 2 -- Indentation width
vim.opt.smarttab = true -- Context-aware tab behavior
vim.opt.autoindent = true -- Maintain indent from previous line
vim.opt.smartindent = true -- Smarter automatic indentation

-- User interface
vim.opt.number = true -- Show line numbers
vim.opt.relativenumber = true -- Relative line numbers for easier movement
vim.opt.mouse = "a" -- Enable mouse support
vim.opt.termguicolors = true -- Enable 24-bit color
vim.opt.signcolumn = "yes" -- Keep the sign column always visible
vim.opt.completeopt = "menuone,noselect" -- Completion behavior
vim.opt.updatetime = 250 -- Faster updates (affects diagnostics)
vim.opt.timeoutlen = 300 -- Shorter keymap timeout for better UX

-- Persistent undo
vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath("data") .. "/undodir" -- set undodir directory (Windows)
-- vim.opt.undodir = vim.fn.expand('~/.vim/undodir')    -- set undodir directory (Linux)

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

-- Navigate between nvim and tmux
-- vim.keymap.set("n", "<C-k>", ":wincmd k<CR>")
-- vim.keymap.set("n", "<C-j>", ":wincmd j<CR>")
-- vim.keymap.set("n", "<C-h>", ":wincmd h<CR>")
-- vim.keymap.set("n", "<C-l>", ":wincmd l<CR>")

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
	if not ok then
		return nil
	end
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
				"hrsh7th/cmp-nvim-lsp", -- LSP completion source
				"hrsh7th/cmp-buffer", -- Buffer words source
				"hrsh7th/cmp-path", -- Filesystem paths
				"L3MON4D3/LuaSnip", -- Snippet engine
				"saadparwaiz1/cmp_luasnip", -- LuaSnip integration
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
		-- nvim-neo-tree setup
		-----------------------------------------------------------
		{
			"nvim-neo-tree/neo-tree.nvim",
			branch = "v3.x",
			dependencies = {
				"nvim-lua/plenary.nvim",
				"MunifTanjim/nui.nvim",
				"nvim-tree/nvim-web-devicons",
			},
			config = function()
				-----------------------------------------------------------
				-- Neo-tree Setup
				-----------------------------------------------------------
				require("neo-tree").setup({
					close_if_last_window = true, -- Close Neo-tree when it's the last window
					popup_border_style = "rounded", -- Rounded borders for floating windows
					enable_git_status = true, -- Show Git status next to files
					enable_diagnostics = true, -- Show LSP diagnostics in the tree

					window = {
						position = "left", -- Default position (can be "right" or "float")
						width = 35, -- Default width
						mappings = {
							["<space>"] = "none", -- Disable accidental open on <space>
						},
					},

					filesystem = {
						follow_current_file = { enabled = true }, -- Auto-focus on current file
						group_empty_dirs = true, -- Group empty folders for cleaner view
						hijack_netrw_behavior = "open_default", -- Replace default netrw
					},
				})

				-----------------------------------------------------------
				-- Neo-tree Keymaps
				-----------------------------------------------------------

				-- File explorer management
				vim.keymap.set("n", "<leader>ee", "<Cmd>Neotree show toggle<CR>", { desc = "Toggle Neo-tree" })
				vim.keymap.set(
					"n",
					"<leader>ef",
					"<Cmd>Neotree reveal toggle<CR>",
					{ desc = "Reveal current file in Neo-tree" }
				)
				vim.keymap.set("n", "<leader>ec", "<Cmd>Neotree close<CR>", { desc = "Close file explorer" })
				vim.keymap.set("n", "<leader>er", "<Cmd>Neotree refresh<CR>", { desc = "Refresh file explorer" })

				-- Navigation between Neo-tree and editor
				vim.keymap.set("n", "<leader>eh", "<Cmd>wincmd h<CR>", { desc = "Focus Neo-tree window" })
				vim.keymap.set("n", "<leader>el", "<Cmd>wincmd l<CR>", { desc = "Focus editor window" })

				-- Open Neo-tree in the current file's directory
				vim.keymap.set(
					"n",
					"<leader>ed",
					"<Cmd>Neotree dir=%:p:h<CR>",
					{ desc = "Open Neo-tree in current directory" }
				)

				-- Floating Neo-tree (useful for quick file browsing)
				vim.keymap.set(
					"n",
					"<leader>eo",
					"<Cmd>Neotree float toggle<CR>",
					{ desc = "Toggle floating Neo-tree window" }
				)
			end,
		},
		{
			"antosha417/nvim-lsp-file-operations",
			dependencies = {
				"nvim-lua/plenary.nvim",
				"nvim-neo-tree/neo-tree.nvim", -- makes sure that this loads after Neo-tree.
			},
			config = function()
				require("lsp-file-operations").setup()
			end,
		},
		{
			"s1n7ax/nvim-window-picker",
			version = "2.*",
			config = function()
				require("window-picker").setup({
					filter_rules = {
						include_current_win = false,
						autoselect_one = true,
						-- filter using buffer options
						bo = {
							-- if the file type is one of following, the window will be ignored
							filetype = { "neo-tree", "neo-tree-popup", "notify" },
							-- if the buffer type is one of following, the window will be ignored
							buftype = { "terminal", "quickfix" },
						},
					},
				})
			end,
		},

		-----------------------------------------------------------
		-- none-ls (null-ls) setup
		-- Provides formatting and diagnostics via external tools
		-----------------------------------------------------------
		{
			"nvimtools/none-ls.nvim",
			dependencies = {
				"nvim-lua/plenary.nvim",
				"nvimtools/none-ls-extras.nvim", -- optional but recommended for newer eslint_d/prettierd
			},
			config = function()
				-- Safe require (avoids breaking startup if plugin missing)
				local ok, null_ls = pcall(require, "null-ls")
				if not ok then
					vim.notify("none-ls (null-ls) not found", vim.log.levels.ERROR)
					return
				end

				-- Optional extras (used if available)
				local function try_require(name)
					local ok, mod = pcall(require, name)
					return ok and mod or nil
				end

				local extras_eslint = try_require("none-ls.diagnostics.eslint_d")
				local extras_eslint_actions = try_require("none-ls.code_actions.eslint_d")
				local extras_prettier = try_require("none-ls.formatting.prettierd")

				-- Builtins (fallbacks if extras are not present)
				local formatting = null_ls.builtins.formatting
				local diagnostics = null_ls.builtins.diagnostics

				-----------------------------------------------------------
				-- Sources registration
				-----------------------------------------------------------
				local sources = {
					-- Prettier / Prettierd
					(extras_prettier or formatting.prettierd or formatting.prettier).with({
						disabled_filetypes = { "markdown", "md" },
					}),

					-- Stylua (Lua formatter)
					formatting.stylua,

					-- ESLint_d diagnostics (optional)
					(extras_eslint or diagnostics.eslint_d).with({
						condition = function(utils)
							return utils.root_has_file({
								".eslintrc.js",
								".eslintrc.cjs",
								".eslintrc.json",
								"eslint.config.js",
								"package.json",
							})
						end,
					}),

					-- ESLint_d code actions (optional)
					extras_eslint_actions,
				}

				-----------------------------------------------------------
				-- Format on save (only use none-ls for formatting)
				-----------------------------------------------------------
				local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

				null_ls.setup({
					debug = false,
					sources = sources,
					on_attach = function(client, bufnr)
						if client.supports_method("textDocument/formatting") then
							vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
							vim.api.nvim_create_autocmd("BufWritePre", {
								group = augroup,
								buffer = bufnr,
								callback = function()
									vim.lsp.buf.format({
										filter = function(c)
											-- ensure only none-ls handles formatting
											return c.name == "null-ls" or c.name == "none-ls"
										end,
										bufnr = bufnr,
									})
								end,
							})
						end
					end,
				})
			end,
		},

		-----------------------------------------------------------
		-- Trouble.nvim setup:
		-----------------------------------------------------------
		{
			"folke/trouble.nvim",
			opts = {}, -- for default options, refer to the configuration section for custom setup.
			cmd = "Trouble",
			keys = {
				{
					"<leader>xx",
					"<cmd>Trouble diagnostics toggle<cr>",
					desc = "Diagnostics (Trouble)",
				},
				{
					"<leader>xX",
					"<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
					desc = "Buffer Diagnostics (Trouble)",
				},
				{
					"<leader>cs",
					"<cmd>Trouble symbols toggle focus=false<cr>",
					desc = "Symbols (Trouble)",
				},
				{
					"<leader>cl",
					"<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
					desc = "LSP Definitions / references / ... (Trouble)",
				},
				{
					"<leader>xL",
					"<cmd>Trouble loclist toggle<cr>",
					desc = "Location List (Trouble)",
				},
				{
					"<leader>xQ",
					"<cmd>Trouble qflist toggle<cr>",
					desc = "Quickfix List (Trouble)",
				},
			},
		},

		-----------------------------------------------------------
		-- Indent-blankline.nvim setup:
		-----------------------------------------------------------
		{
			"lukas-reineke/indent-blankline.nvim",
			main = "ibl",
			---@module "ibl"
			---@type ibl.config
			opts = {},
		},

		-----------------------------------------------------------
		-- Neogit setup:
		-----------------------------------------------------------
		{
			"NeogitOrg/neogit",
			dependencies = {
				"nvim-lua/plenary.nvim", -- required
				"sindrets/diffview.nvim", -- optional - Diff integration

				-- Only one of these is needed.
				"nvim-telescope/telescope.nvim", -- optional
			},
		},

		-----------------------------------------------------------
		-- Comment-nvim setup:
		-----------------------------------------------------------
		{
			"numToStr/Comment.nvim",
			opts = {
				padding = true,
			},
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
				if mason then
					mason.setup()
				end

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
						ensure_installed = { "gotestsum", "eslint_d", "prettier", "prettierd", "stylua", "cspell" },
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
					virtual_text = false, -- Disable inline text
					signs = true, -- Show signs on the left
					underline = true, -- Underline problematic text
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
						"lua",
						"vim",
						"vimdoc",
						"bash",
						"html",
						"typescript",
						"javascript",
						"css",
						"json",
						"yaml",
						"go",
						"python",
						"cpp",
						"c",
						"sql",
						"markdown",
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
	local cmd = string.format("!gcc %s -o %s && ./%s", vim.fn.expand("%"), vim.fn.expand("%:r"), vim.fn.expand("%:r"))
	vim.cmd(cmd)
end, { noremap = true, silent = false, desc = "Compile & run C (Linux)" })

-- ========================== End of File ==========================
