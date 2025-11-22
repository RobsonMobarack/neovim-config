-- ============================================================
-- Neovim Configuration File
-- Author: Robson Mobarack
-- GitHub: github.com/RobsonMobarack/neovim-config
-- ============================================================

---------------------------------------------------------------
-- =============== OS Detection ===============================
---------------------------------------------------------------
-- Detect operating system to handle paths and commands dynamically
local IS_WINDOWS = vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1
local IS_MAC = vim.fn.has("macunix") == 1
local IS_LINUX = not IS_WINDOWS and not IS_MAC

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

-- Persistent undo configuration based on OS
vim.opt.undofile = true
local undo_path = ""

if IS_WINDOWS then
	undo_path = vim.fn.stdpath("data") .. "/undodir"
else
	-- Linux/macOS standard: ~/.vim/undodir or XDG location
	undo_path = vim.fn.expand("~/.vim/undodir")
	-- If you prefer the XDG standard on Linux/Mac, uncomment below instead:
	-- vim.opt.undodir = vim.fn.stdpath("data") .. "/undodir"
end

-- Set the option using the string path
vim.opt.undodir = undo_path

-- Create undo directory if it doesn't exist to avoid errors
if vim.fn.isdirectory(undo_path) == 0 then
	vim.fn.mkdir(undo_path, "p")
end

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
if not IS_WINDOWS then
	vim.keymap.set("n", "<C-k>", ":wincmd k<CR>")
	vim.keymap.set("n", "<C-j>", ":wincmd j<CR>")
	vim.keymap.set("n", "<C-h>", ":wincmd h<CR>")
	vim.keymap.set("n", "<C-l>", ":wincmd l<CR>")
end

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
		-- Nvim-jdtls: Java LSP (nvim-jdtls) configuration with support for
		-- Debug (DAP) & Testing and Lombok
		-----------------------------------------------------------
		{
			"mfussenegger/nvim-jdtls",
			ft = "java",
			dependencies = {
				"mfussenegger/nvim-dap",
				"williamboman/mason.nvim",
			},
			config = function()
				-- 1. Function to locate JDTLS installation directory via PATH
				local function get_jdtls_home()
					-- Try native Neovim function first
					local executable = vim.fn.exepath("jdtls")

					-- Fallback: If exepath fails, try to force query the system (Windows specific)
					if executable == "" and IS_WINDOWS then
						executable = vim.fn.system("where.exe jdtls"):gsub("\n", ""):gsub("\r", "")
						if vim.fn.filereadable(executable) == 0 then
							executable = ""
						end
					end

					if executable == "" then
						return nil
					end

					-- Normalize slashes to forward slashes (/) to avoid Windows backslash hell
					executable = executable:gsub("\\", "/")

					-- Windows-specific logic
					if IS_WINDOWS then
						-- Scoop Installation Handling
						-- Convert: .../scoop/shims/jdtls.exe -> .../scoop/apps/jdtls/current
						if executable:match("/shims/") then
							return executable:gsub("/shims/.*", "/apps/jdtls/current")
						end
						-- Manual/Other Windows installs: Assume standard structure (bin/.. -> root)
						return vim.fn.fnamemodify(executable, ":h:h")
					end

					-- Linux/macOS logic
					local resolved_path = (vim.uv or vim.loop).fs_realpath(executable)
					if resolved_path then
						return vim.fn.fnamemodify(resolved_path, ":h:h")
					end

					return nil
				end

				local jdtls_home = get_jdtls_home()

				-- Safety check
				if not jdtls_home or vim.fn.isdirectory(jdtls_home) == 0 then
					vim.notify(
						"JDTLS not found in PATH. Location detected: " .. (jdtls_home or "nil"),
						vim.log.levels.ERROR
					)
					return
				end

				-- 2. Helper to retrieve extension paths DIRECTLY from filesystem
				local function get_mason_pkg_path(pkg_name)
					local mason_root = vim.fn.stdpath("data") .. "/mason/packages/" .. pkg_name
					if vim.fn.isdirectory(mason_root) == 1 then
						return mason_root
					end
					return nil
				end

				-- 3. Determine OS Configuration Directory Name
				local config_dir_name = ""
				if IS_MAC then
					config_dir_name = "config_mac"
				elseif IS_WINDOWS then
					config_dir_name = "config_win"
				else
					config_dir_name = "config_linux"
				end

				-- 4. Locate Launcher JAR and Lombok
				local launcher_jar = vim.fn.glob(jdtls_home .. "/plugins/org.eclipse.equinox.launcher_*.jar")
				if launcher_jar == "" then
					launcher_jar = vim.fn.glob(jdtls_home .. "/org.eclipse.equinox.launcher_*.jar")
				end

				if launcher_jar == "" then
					vim.notify("JDTLS Launcher JAR not found in detected path: " .. jdtls_home, vim.log.levels.ERROR)
					return
				end

				-- Lombok setup
				local lombok_path = get_mason_pkg_path("lombok-nightly")
				local lombok_arg = ""
				if lombok_path then
					lombok_arg = "-javaagent:" .. lombok_path .. "/lombok.jar"
				end

				-- 5. Workspace Directory Setup
				local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
				local workspace_dir = vim.fn.stdpath("data") .. "/site/java/workspace-root/" .. project_name
				if IS_WINDOWS then
					os.execute("mkdir " .. workspace_dir .. " > nul 2>&1")
				else
					os.execute("mkdir -p " .. workspace_dir)
				end

				-- 6. Load Debug and Test Bundles
				local bundles = {}
				local java_debug_path = get_mason_pkg_path("java-debug-adapter")
				if java_debug_path then
					local java_debug_bundle =
						vim.fn.glob(java_debug_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar", true)
					table.insert(bundles, java_debug_bundle)
				end
				local java_test_path = get_mason_pkg_path("java-test")
				if java_test_path then
					vim.list_extend(
						bundles,
						vim.split(vim.fn.glob(java_test_path .. "/extension/server/*.jar", true), "\n")
					)
				end

				-- 7. JDTLS Configuration Table
				local config = {
					cmd = {
						"java",
						"-Declipse.application=org.eclipse.jdt.ls.core.id1",
						"-Dosgi.bundles.defaultStartLevel=4",
						"-Declipse.product=org.eclipse.jdt.ls.core.product",
						"-Dlog.protocol=true",
						"-Dlog.level=ALL",
						"-Xmx1g",
						"--add-modules=ALL-SYSTEM",
						"--add-opens",
						"java.base/java.util=ALL-UNNAMED",
						"--add-opens",
						"java.base/java.lang=ALL-UNNAMED",
						lombok_arg,
						"-jar",
						launcher_jar,
						"-configuration",
						jdtls_home .. "/" .. config_dir_name,
						"-data",
						workspace_dir,
					},

					root_dir = require("jdtls.setup").find_root({
						".git",
						"mvnw",
						"gradlew",
						"pom.xml",
						"build.gradle",
					}),

					init_options = { bundles = bundles },

					settings = {
						java = {
							errors = { incompleteClasspath = { severity = "warning" } },
						},
					},

					on_attach = function(client, bufnr)
						if client.name == "jdtls" then
							require("jdtls").setup_dap({ hotcodereplace = "auto" })
							require("jdtls.dap").setup_dap_main_class_configs()
						end

						-- Java-specific Keymaps
						local opts = { noremap = true, silent = true, buffer = bufnr }
						vim.keymap.set("n", "<leader>jo", "<Cmd>lua require'jdtls'.organize_imports()<CR>", opts)
						vim.keymap.set("n", "<leader>jt", "<Cmd>lua require'jdtls'.test_class()<CR>", opts)
						vim.keymap.set("n", "<leader>jn", "<Cmd>lua require'jdtls'.test_nearest_method()<CR>", opts)
					end,
				}

				require("jdtls").start_or_attach(config)
			end,
		},

		-----------------------------------------------------------
		-- Autopairs: To close brackets, quotes, etc. automatically
		-----------------------------------------------------------
		{
			"windwp/nvim-autopairs",
			event = "InsertEnter",
			config = true,
		},

		-----------------------------------------------------------
		-- Colorscheme: Gruvbox
		-----------------------------------------------------------
		{
			"ellisonleao/gruvbox.nvim",
			priority = 1000,
			config = function()
				require("gruvbox").setup({
					terminal_colors = true, -- add neovim terminal colors
					undercurl = true,
					underline = true,
					bold = true,
					italic = {
						strings = true,
						emphasis = true,
						comments = true,
						operators = false,
						folds = true,
					},
					strikethrough = true,
					invert_selection = false,
					invert_signs = false,
					invert_tabline = false,
					inverse = true, -- invert background for search, diffs, statuslines and errors
					contrast = "", -- can be "hard", "soft" or empty string
				})
				vim.cmd.colorscheme("gruvbox")
			end,
		},

		-----------------------------------------------------------
		-- Colorscheme: Catppuccin
		-----------------------------------------------------------
		-- {
		-- 	"catppuccin/nvim",
		-- 	name = "catppuccin",
		-- 	priority = 1000,
		-- 	config = function()
		-- 		require("catppuccin").setup({ flavour = "macchiato" })
		-- 		vim.cmd.colorscheme("catppuccin")
		-- 	end,
		-- },

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
				require("neo-tree").setup({
					close_if_last_window = true,
					popup_border_style = "rounded",
					enable_git_status = true,
					enable_diagnostics = true,

					window = {
						position = "left",
						width = 35,
						mappings = {
							["<space>"] = "none",
						},
					},

					filesystem = {
						follow_current_file = { enabled = true },
						group_empty_dirs = true,
						hijack_netrw_behavior = "open_default",
					},
				})

				-- Neo-tree Keymaps
				vim.keymap.set("n", "<leader>ee", "<Cmd>Neotree show toggle<CR>", { desc = "Toggle Neo-tree" })
				vim.keymap.set(
					"n",
					"<leader>ef",
					"<Cmd>Neotree reveal toggle<CR>",
					{ desc = "Reveal current file in Neo-tree" }
				)
				vim.keymap.set("n", "<leader>ec", "<Cmd>Neotree close<CR>", { desc = "Close file explorer" })
				vim.keymap.set("n", "<leader>er", "<Cmd>Neotree refresh<CR>", { desc = "Refresh file explorer" })
				vim.keymap.set("n", "<leader>eh", "<Cmd>wincmd h<CR>", { desc = "Focus Neo-tree window" })
				vim.keymap.set("n", "<leader>el", "<Cmd>wincmd l<CR>", { desc = "Focus editor window" })
				vim.keymap.set(
					"n",
					"<leader>ed",
					"<Cmd>Neotree dir=%:p:h<CR>",
					{ desc = "Open Neo-tree in current directory" }
				)
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
				"nvim-neo-tree/neo-tree.nvim",
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
						bo = {
							filetype = { "neo-tree", "neo-tree-popup", "notify" },
							buftype = { "terminal", "quickfix" },
						},
					},
				})
			end,
		},

		-----------------------------------------------------------
		-- none-ls (null-ls) setup
		-----------------------------------------------------------
		{
			"nvimtools/none-ls.nvim",
			dependencies = {
				"nvim-lua/plenary.nvim",
				"nvimtools/none-ls-extras.nvim",
			},
			config = function()
				local ok, null_ls = pcall(require, "null-ls")
				if not ok then
					vim.notify("none-ls (null-ls) not found", vim.log.levels.ERROR)
					return
				end

				local function try_require(name)
					local ok_req, mod = pcall(require, name)
					return ok_req and mod or nil
				end

				local extras_eslint = try_require("none-ls.diagnostics.eslint_d")
				local extras_eslint_actions = try_require("none-ls.code_actions.eslint_d")
				local extras_prettier = try_require("none-ls.formatting.prettierd")

				local formatting = null_ls.builtins.formatting
				local diagnostics = null_ls.builtins.diagnostics

				local sources = {
					(extras_prettier or formatting.prettierd or formatting.prettier).with({
						disabled_filetypes = { "markdown", "md" },
					}),
					formatting.stylua,
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
					extras_eslint_actions,
				}

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
		-- Trouble.nvim setup
		-----------------------------------------------------------
		{
			"folke/trouble.nvim",
			opts = {},
			cmd = "Trouble",
			keys = {
				{ "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
				{
					"<leader>xX",
					"<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
					desc = "Buffer Diagnostics (Trouble)",
				},
				{ "<leader>cs", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Symbols (Trouble)" },
				{
					"<leader>cl",
					"<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
					desc = "LSP Definitions / references (Trouble)",
				},
				{ "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "Location List (Trouble)" },
				{ "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List (Trouble)" },
			},
		},

		-----------------------------------------------------------
		-- Indent-blankline.nvim setup
		-----------------------------------------------------------
		{
			"lukas-reineke/indent-blankline.nvim",
			main = "ibl",
			opts = {},
		},

		-----------------------------------------------------------
		-- Neogit setup
		-----------------------------------------------------------
		{
			"NeogitOrg/neogit",
			dependencies = {
				"nvim-lua/plenary.nvim",
				"sindrets/diffview.nvim",
				"nvim-telescope/telescope.nvim",
			},
		},

		-----------------------------------------------------------
		-- Comment-nvim setup
		-----------------------------------------------------------
		{
			"numToStr/Comment.nvim",
			opts = { padding = true },
			mappings = { basic = true, extra = true },
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

				local mason = safe_require("mason")
				if mason then
					mason.setup()
				end

				local mason_lspconfig = safe_require("mason-lspconfig")
				if not mason_lspconfig then
					vim.notify("mason-lspconfig not found", vim.log.levels.ERROR)
					return
				end

				local servers = {
					"lua_ls",
					"ts_ls",
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
					automatic_enable = { exclude = { "jdtls" } },
				})

				local mti = safe_require("mason-tool-installer")
				if mti then
					mti.setup({
						ensure_installed = { "gotestsum", "eslint_d", "prettier", "prettierd", "stylua", "cspell" },
					})
				end

				local capabilities = vim.lsp.protocol.make_client_capabilities()
				local ok_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
				if ok_cmp then
					capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
				end

				vim.lsp.config("*", {
					on_attach = on_attach,
					capabilities = capabilities,
					root_markers = { ".git", "package.json", "pyproject.toml", "go.mod" },
				})

				for _, server in ipairs(servers) do
					vim.lsp.enable(server)
				end

				vim.diagnostic.config({
					virtual_text = false,
					signs = true,
					underline = true,
					update_in_insert = false,
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
							local max_filesize = 100 * 1024
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
-- =============== Compile & Run C (Cross-Platform) ===========
---------------------------------------------------------------

vim.keymap.set("n", "<F5>", function()
	-- Save file
	vim.cmd("w")

	-- Get file name and output name (without extension)
	local file = vim.fn.expand("%")
	local output = vim.fn.expand("%:r")

	-- Build the command based on the OS
	local cmd = ""
	if IS_WINDOWS then
		-- Windows: using gcc and && for chaining, executing .exe
		cmd = string.format("!gcc %s -o %s && %s.exe", file, output, output)
	else
		-- Linux/macOS: using gcc and &&, executing ./output
		cmd = string.format("!gcc %s -o %s && ./%s", file, output, output)
	end

	-- Execute the command
	vim.cmd(cmd)
end, { noremap = true, silent = false, desc = "Compile & run C (Auto-detect OS)" })

-- ========================== End of File ========================
