---------------------------------------------------------------
-- =============== Command tracker ============================
---------------------------------------------------------------
require("command_tracker").setup()

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
-- ======================== ENV VARS ==========================
---------------------------------------------------------------

-- Forces ESLint 9 to use the old configuration (.eslintrc.json)
vim.env.ESLINT_USE_FLAT_CONFIG = "false"

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

-----------------------------------------------------------
-- Key Bind for One Small Step for Vimkind
-- Specific shortcut for connecting to the Lua debugger (OSV) ignoring the filetype.
-----------------------------------------------------------
vim.keymap.set("n", "<leader>dl", function()
	require("dap").run({
		type = "nlua",
		request = "attach",
		name = "Attach to running Neovim instance",
	})
end, { desc = "Lua: Attach to OSV" })

-- Global LSP Keymaps
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UseLspConfig", { clear = true }),
	callback = function(ev)
		local opts = { noremap = true, silent = true, buffer = ev.buf }
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
		vim.keymap.set("n", "K", function()
			vim.lsp.buf.hover({ border = "rounded" })
		end, opts)
		vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
		vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
		vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
		vim.keymap.set("n", "<leader>f", function()
			vim.lsp.buf.format({ async = true })
		end, opts)
		vim.keymap.set("i", "<C-k>", function()
			vim.lsp.buf.signature_help({ border = "rounded" })
		end, opts)
		vim.keymap.set("n", "<leader>ih", function()
			local is_enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf })
			vim.lsp.inlay_hint.enable(not is_enabled, { bufnr = ev.buf })
		end, { noremap = true, silent = true, buffer = ev.buf, desc = "Toggle Inlay Hints" })
	end,
})

-- space + s saves the file
vim.keymap.set("n", "<leader>s", ":write<CR>", { silent = true })

-- space + h to clear search highlight
vim.keymap.set("n", "<leader>h", ":noh<CR>", { silent = true })

-- Shortcut to run/debug the current Java class (requires nvim-dap configured in jdtls)
vim.keymap.set("n", "<leader>dr", function()
	local dap = require("dap")
	-- Attempts to continue an existing session or start a new one (runs the main method)
	dap.continue()
end, { desc = "Java: Run/Debug Main Class" })

-- Shortcut to terminate the Java debug session
vim.keymap.set("n", "<leader>dq", function()
	require("dap").terminate()
	require("dap").repl.close()
	require("dapui").close()
end, { desc = "Java: Terminate Debug/App" })

-- Forces the sending of the Hot Code Replace command to the JVM via DAP.
vim.keymap.set("n", "<leader>jh", function()
	local session = require("dap").session()
	if session then
		session:request("redefineClasses", nil, function(err)
			if err then
				vim.notify("Error in HCR: " .. vim.inspect(err), vim.log.levels.ERROR)
			else
				vim.notify("Hot Code Replace injected successfully!", vim.log.levels.INFO)
			end
		end)
	else
		vim.notify("No active debug sessions.", vim.log.levels.WARN)
	end
end, { desc = "Java: Force Hot Code Replace (HCR)" })

-- Força a compilação incremental do arquivo atual (Gatilho manual para o HotSwap)
vim.keymap.set(
	"n",
	"<leader>jb",
	"<Cmd>lua require('jdtls').compile('incremental')<CR>",
	{ desc = "Java: Build/Compile Incremental (Trigger HCR)" }
)

vim.keymap.set("n", "<leader>dt", function()
	require("dapui").toggle()
end, { desc = "Debug: Toggle UI" })

-- ==========================================
-- Navegação Avançada de Debug (nvim-dap)
-- ==========================================

-- Gerenciamento de Breakpoints
vim.keymap.set("n", "<leader>db", function()
	require("dap").toggle_breakpoint()
end, { desc = "Debug: Toggle Breakpoint" })
vim.keymap.set("n", "<leader>dB", function()
	require("dap").set_breakpoint(vim.fn.input("Condição do Breakpoint: "))
end, { desc = "Debug: Breakpoint Condicional" })
vim.keymap.set("n", "<leader>dx", function()
	require("dap").clear_breakpoints()
end, { desc = "Debug: Limpar todos os Breakpoints" })

-- Controles de Fluxo (Você pode usar as teclas F ou a Leader key)
vim.keymap.set("n", "<F10>", function()
	require("dap").step_over()
end, { desc = "Debug: Step Over" })
vim.keymap.set("n", "<leader>do", function()
	require("dap").step_over()
end, { desc = "Debug: Step Over" })

vim.keymap.set("n", "<F11>", function()
	require("dap").step_into()
end, { desc = "Debug: Step Into" })
vim.keymap.set("n", "<leader>di", function()
	require("dap").step_into()
end, { desc = "Debug: Step Into" })

vim.keymap.set("n", "<F12>", function()
	require("dap").step_out()
end, { desc = "Debug: Step Out" })
vim.keymap.set("n", "<leader>du", function()
	require("dap").step_out()
end, { desc = "Debug: Step Out (Up)" })

-- ==========================================
-- Tmux
-- ==========================================

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
-- =============== Native Treesitter (Nvim 0.12+) =============
---------------------------------------------------------------

-- Enables Treesitter-based highlighting and indentation globally
vim.opt.syntax = "off" -- Disables legacy regex-based syntax in Vim
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldenable = false -- Prevents files from opening completely collapsed

-- Autocommand to ensure that Treesitter starts in supported buffers
vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("NativeTreesitterStart", { clear = true }),
	callback = function(ev)
		local lang = vim.treesitter.language.get_lang(ev.match)
		if lang and vim.treesitter.language.add(lang) then
			pcall(vim.treesitter.start, ev.buf, lang)
		end
	end,
})

---------------------------------------------------------------
-- =============== Lazy Plugin Setup ==========================
---------------------------------------------------------------

require("lazy").setup({
	spec = {
		-----------------------------------------------------------
		-- One Small Step for Vimkind
		-----------------------------------------------------------
		{
			"jbyuki/one-small-step-for-vimkind",
			dependencies = { "mfussenegger/nvim-dap" },
			config = function()
				local dap = require("dap")

				-- Configura o adaptador para se conectar via socket
				dap.adapters.nlua = function(callback, config)
					callback({ type = "server", host = config.host or "127.0.0.1", port = config.port or 8086 })
				end

				-- Configura o perfil de inicialização no nvim-dap
				dap.configurations.lua = {
					{
						type = "nlua",
						request = "attach",
						name = "Attach to running Neovim instance",
					},
				}
			end,
		},

		-----------------------------------------------------------
		-- Avante.nvim
		-----------------------------------------------------------
		{
			"yetone/avante.nvim",
			-- "RobsonMobarack/avante.nvim",
			-- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
			-- ⚠️ must add this setting! ! !
			build = vim.fn.has("win32") ~= 0
					and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
				or "make",
			event = "VeryLazy",
			version = false, -- Never set this value to "*"! Never!
			---@module 'avante'
			---@type avante.Config
			opts = {
				-- add any opts here
				-- this file can contain specific instructions for your project
				instructions_file = "avante.md",
				provider = "openrouter",
				providers = {
					openrouter = {
						__inherited_from = "openai",
						endpoint = "https://openrouter.ai/api/v1",
						api_key_name = "OPENROUTER_API_KEY",
						model = "nvidia/nemotron-3-nano-30b-a3b:free",
					},
					gemini_pro = {
						api_key_name = "GEMINI_API_KEY",
						endpoint = "https://generativelanguage.googleapis.com/v1beta/models",
						model = "gemini-2.5-pro",
					},
					gemini_flash = {
						api_key_name = "GEMINI_API_KEY",
						endpoint = "https://generativelanguage.googleapis.com/v1beta/models",
						model = "gemini-2.5-flash",
					},
					groq_refactor = {
						__inherited_from = "openai",
						api_key_name = "GROQ_API_KEY",
						endpoint = "https://api.groq.com/openai/v1",
						model = "llama-3.3-70b-versatile",
						max_tokens = 4096,
					},
					groq_context = {
						__inherited_from = "openai",
						api_key_name = "GROQ_API_KEY",
						endpoint = "https://api.groq.com/openai/v1",
						model = "meta-llama/llama-4-scout-17b-16e-instruct",
						max_tokens = 4096,
					},
				},
			},
			dependencies = {
				"nvim-lua/plenary.nvim",
				"MunifTanjim/nui.nvim",
				--- The below dependencies are optional,
				"nvim-mini/mini.pick", -- for file_selector provider mini.pick
				"nvim-telescope/telescope.nvim", -- for file_selector provider telescope
				"hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
				"ibhagwan/fzf-lua", -- for file_selector provider fzf
				"stevearc/dressing.nvim", -- for input provider dressing
				"folke/snacks.nvim", -- for input provider snacks
				"nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
				{
					-- support for image pasting
					"HakonHarnes/img-clip.nvim",

					event = "VeryLazy",
					opts = {

						-- recommended settings
						default = {
							embed_image_as_base64 = false,

							prompt_for_file_name = false,
							drag_and_drop = {

								insert_mode = true,
							},
							-- required for Windows users
							use_absolute_path = true,
						},
					},
				},
				{
					-- Make sure to set this up properly if you have lazy=true
					"MeanderingProgrammer/render-markdown.nvim",
					opts = {

						file_types = { "markdown", "Avante" },
					},
					ft = { "markdown", "Avante" },
				},
			},
		},

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
				local function setup_jdtls()
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
						vim.notify(
							"JDTLS Launcher JAR not found in detected path: " .. jdtls_home,
							vim.log.levels.ERROR
						)
						return
					end

					-- =========================================================
					-- Lombok Setup (Cross-platform & Public Repo Friendly)
					-- =========================================================
					local function find_lombok_jar()
						-- 1. Tenta buscar no repositório Maven local (.m2) do usuário
						-- O '~' é resolvido corretamente para C:\Users\Usuario ou /home/usuario
						local m2_lombok_dir = vim.fn.expand("~/.m2/repository/org/projectlombok/lombok")
						-- Procura por arquivos .jar dentro das pastas de versão (ex: 1.18.44/lombok-1.18.44.jar)
						local m2_jars = vim.fn.glob(m2_lombok_dir .. "/*/*.jar", true, true)

						if m2_jars and #m2_jars > 0 then
							-- Retorna o último da lista (geralmente a versão mais recente caso haja múltiplas)
							return m2_jars[#m2_jars]
						end

						-- 2. Fallback: Verifica se o usuário que clonou o repo instalou via Mason
						local lombok_mason_path = get_mason_pkg_path("lombok-nightly")
						if lombok_mason_path and vim.fn.filereadable(lombok_mason_path .. "/lombok.jar") == 1 then
							return lombok_mason_path .. "/lombok.jar"
						end

						return nil
					end

					local lombok_jar_path = find_lombok_jar()
					local lombok_arg = ""
					if lombok_jar_path then
						lombok_arg = "-javaagent:" .. lombok_jar_path
					else
						-- Log opcional caso a pessoa não tenha o Lombok em nenhum dos locais
						vim.notify("JDTLS: Lombok JAR não encontrado no .m2 ou Mason.", vim.log.levels.WARN)
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
						local java_debug_bundle = vim.fn.glob(
							java_debug_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar",
							true
						)
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
								autobuild = { enabled = true },
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
				end

				setup_jdtls()

				vim.api.nvim_create_autocmd("FileType", {
					pattern = "java",
					callback = setup_jdtls,
				})
			end,
		},

		-----------------------------------------------------------
		-- Lazydev: Configures LuaLS for editing your Neovim config by lazily updating your workspace libraries
		-----------------------------------------------------------
		{
			"folke/lazydev.nvim",
			ft = "lua", -- only load on lua files
			opts = {
				library = {
					-- See the configuration section for more details
					-- Load luvit types when the `vim.uv` word is found
					{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
				},
			},
		},

		-----------------------------------------------------------
		-- Nvim-dap: Configuration to work with C and C++
		-----------------------------------------------------------
		{
			"mfussenegger/nvim-dap",
			config = function()
				local dap = require("dap")

				-- Identifies the path to the codelldb installed by Mason
				local codelldb_cmd = vim.fn.stdpath("data") .. "/mason/bin/codelldb"
				if vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1 then
					codelldb_cmd = codelldb_cmd .. ".cmd"
				end

				-- Register the adapter
				dap.adapters.codelldb = {
					type = "server",
					port = "${port}",
					executable = {
						command = codelldb_cmd,
						args = { "--port", "${port}" },
					},
				}

				-- Configures the attach/launch process for .c files
				dap.configurations.c = {
					{
						name = "Debug C file",
						type = "codelldb",
						request = "launch",
						program = function()
							-- Points to the executable that has just been compiled
							local file = vim.fn.expand("%:r")
							local extension = (vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1) and ".exe" or ""
							return vim.fn.getcwd() .. "/" .. file .. extension
						end,
						cwd = "${workspaceFolder}",
						stopOnEntry = false,
					},
				}

				-- Reuse the same configuration to work with C++
				dap.configurations.cpp = dap.configurations.c
			end,
		},

		-----------------------------------------------------------
		-- Nvim-dap-ui: UI for nvim-dap
		-----------------------------------------------------------
		{
			"rcarriga/nvim-dap-ui",
			dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
			config = function()
				local dap = require("dap")
				local dapui = require("dapui")

				-- 1. Initializes the interface with the default look
				dapui.setup()

				-- 2. Automation: Opens the interface when debugging begins
				dap.listeners.after.event_initialized["dapui_config"] = function()
					dapui.open()
				end

				-- 3. Automation: Closes the interface when debugging is complete
				dap.listeners.before.event_terminated["dapui_config"] = function()
					dapui.close()
				end
				dap.listeners.before.event_exited["dapui_config"] = function()
					dapui.close()
				end
			end,
		},

		-----------------------------------------------------------
		-- LuaSnip & Snippets
		-----------------------------------------------------------
		{
			"L3MON4D3/LuaSnip",
			version = "v2.*",
			build = "make install_jsregexp",
			dependencies = {
				"rafamadriz/friendly-snippets", -- O LuaSnip precisa dele para ler os arquivos JSON
			},
			config = function()
				-- O LuaSnip é responsável por carregar a si mesmo
				require("luasnip.loaders.from_vscode").lazy_load()
			end,
		},

		-----------------------------------------------------------
		-- Blink.cmp: Completion plugin with support for LSPs, cmdline, signature help, and snippets
		-----------------------------------------------------------
		{
			"saghen/blink.cmp",
			version = "v1.*",
			dependencies = {
				"L3MON4D3/LuaSnip",
			},
			opts = {
				-- Mapeamento manual para ter o comportamento do nvim-cmp
				keymap = {
					["<CR>"] = { "accept", "fallback" },
					["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
					["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
				},

				snippets = { preset = "luasnip" },

				completion = {
					-- preselect = false faz com que nada seja escolhido sozinho
					-- auto_insert = false garante que o Tab não mude o texto no arquivo enquanto tu navega
					list = { selection = { preselect = false, auto_insert = false } },
					menu = { border = "rounded" },
					documentation = { window = { border = "rounded" }, auto_show = true },
				},

				sources = {
					-- add lazydev to your completion providers
					default = { "lazydev", "lsp", "path", "snippets", "buffer" },
					providers = {
						lazydev = {
							name = "LazyDev",
							module = "lazydev.integrations.blink",
							-- make lazydev completions top priority (see `:h blink.cmp`)
							score_offset = 100,
						},
					},
				},
			},
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
		-- Neogen: Document generator via Treesitter
		-----------------------------------------------------------
		{
			"danymat/neogen",
			config = function()
				require("neogen").setup({
					enabled = true,
					languages = {
						-- Specific configuration for Java/JS/TS (Docstrings)
						java = { template = { annotation_convention = "javadoc" } },
						typescript = { template = { annotation_convention = "jsdoc" } },
						javascript = { template = { annotation_convention = "jsdoc" } },
					},
				})
			end,
			keys = {
				{
					"<leader>nf",
					function()
						require("neogen").generate()
					end,
					desc = "Generate Docstring (Function/Class)",
				},
			},
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

				local extras_prettier = try_require("none-ls.formatting.prettierd")
				local formatting = null_ls.builtins.formatting

				local sources = {
					(extras_prettier or formatting.prettierd or formatting.prettier).with({
						disabled_filetypes = { "markdown", "md" },
					}),
					formatting.stylua,
				}

				local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

				null_ls.setup({
					debug = false,
					sources = sources,
					on_attach = function(client, bufnr)
						if client:supports_method("textDocument/formatting") then
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
			event = { "BufReadPre", "BufNewFile" },
			dependencies = {
				"williamboman/mason.nvim",
				"williamboman/mason-lspconfig.nvim",
				"WhoIsSethDaniel/mason-tool-installer.nvim",
			},
			config = function()
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
					"cmake",
					"clangd",
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
						ensure_installed = {
							"gotestsum",
							"eslint_d",
							"prettier",
							"prettierd",
							"stylua",
							"cspell",
							"java-debug-adapter",
							"java-test",
							"codelldb",
						},
					})
				end

				local capabilities = vim.lsp.protocol.make_client_capabilities()

				local ok_blink, blink = pcall(require, "blink.cmp")
				if ok_blink then
					capabilities = blink.get_lsp_capabilities(capabilities)
				end

				vim.lsp.config("*", {
					capabilities = capabilities,
				})

				-- Inicialização simplificada dos servidores
				for _, server in ipairs(servers) do
					-- Se for ESLint, mantemos a sua lógica customizada
					if server == "eslint" then
						vim.lsp.config("eslint", {
							on_attach = function(client, bufnr)
								client.server_capabilities.documentFormattingProvider = true
								on_attach(client, bufnr)
							end,
							root_markers = {
								".git",
								"package.json",
								"tsconfig.json",
								"jsconfig.json",
								"pom.xml",
								"build.gradle",
								"mvnw",
								"gradlew",
								"pyproject.toml",
								"setup.py",
								"requirements.txt",
								"go.mod",
								"go.work",
								"compile_commands.json",
								"Makefile",
								"Cargo.toml",
								"composer.json",
								"angular.json",
								"nx.json",
								"turbo.json",
								"lerna.json",
							},
						})
					end

					-- Habilita o servidor (Neovim 0.11 gerencia o resto)
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
				vim.keymap.set("n", "<leader>fs", builtin.lsp_document_symbols, { desc = "Find Symbols" })
			end,
		},

		-----------------------------------------------------------
		-- Treesitter: syntax highlighting and parsing
		-----------------------------------------------------------
		{
			"nvim-treesitter/nvim-treesitter",
			branch = "master",
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
							local uv = vim.uv or vim.loop
							local ok, stats = pcall(uv.fs_stat, vim.api.nvim_buf_get_name(buf))
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
		cmd = string.format('!gcc -g %s -o %s && "./%s"', file, output, output)
	else
		-- Linux/macOS: using gcc and &&, executing ./output
		cmd = string.format("!gcc -g %s -o %s && ./%s", file, output, output)
	end

	-- Execute the command
	vim.cmd(cmd)
end, { noremap = true, silent = false, desc = "Compile & run C (Auto-detect OS)" })

---------------------------------------------------------------
-- =============== UI Overrides (Force Borders) ===============
---------------------------------------------------------------

-- Force edges on Hover (Shift+K) and Signature Help
local _border = "rounded"

-- 1. Force edges on floating diagnostic windows
vim.diagnostic.config({
	float = { border = _border },
})

-- 2. Hack to ensure borders in windows that use the standard open_floating_preview API
-- This addresses cases where plugins use the LSP utility function directly.
local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
	opts = opts or {}
	opts.border = opts.border or _border
	return orig_util_open_floating_preview(contents, syntax, opts, ...)
end

-- ========================== End of File ========================
