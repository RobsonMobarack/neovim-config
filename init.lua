-- Para executar comandos como :colorscheme, vim.cmd ainda é a forma correta.
vim.cmd.colorscheme("elflord") -- Uma forma alternativa e mais "Lua" de chamar o comando.

-- Opções de Indentação
vim.opt.expandtab = true        -- Usar espaços em vez de tabs
vim.opt.tabstop = 2             -- Um tab equivale a 2 espaços
vim.opt.softtabstop = 2         -- Quantos espaços inserir ao apertar <Tab>
vim.opt.shiftwidth = 2          -- Quantos espaços usar para indentação automática
vim.opt.autoindent = true       -- Copiar a indentação da linha anterior

-- Interface do Editor
vim.opt.number = true           -- Mostrar número das linhas
vim.opt.relativenumber = true   -- Mostrar número relativo das linhas (ótimo para navegação)
vim.opt.mouse = 'a'             -- Habilitar o mouse em todos os modos

-- Bootstrap lazy.nvim
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

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    -- add your plugins here
    {
      'nvim-telescope/telescope.nvim',
      tag = '0.1.8',
      dependencies = { 'nvim-lua/plenary.nvim' },
      config = function()
        local builtin = require('telescope.builtin')
        vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
        vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
        vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
        vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
      end
    },
    {
      "nvim-treesitter/nvim-treesitter",
      branch = 'master', lazy = false,
      build = ":TSUpdate",
      config = function()
        require('nvim-treesitter.configs').setup({
          -- A list of parser names, or "all" (the listed parsers MUST always be installed)
          ensure_installed = { "c", "angular", "vim", "vimdoc", "query", "bash", "markdown_inline", "cmake", "comment", "cpp", "css", "disassembly", "dockerfile", "git_config", "git_rebase", "gitcommit", "gitignore", "go", "gomod", "gosum", "gotmpl", "gowork", "graphql", "html", "java", "javadoc", "javascript", "json", "json5", "lua", "make", "nginx", "powershell", "python", "regex", "robot", "robots", "scss", "sql", "tsx", "typescript", "xml", "yaml" },

          -- Install parsers synchronously (only applied to `ensure_installed`)
          sync_install = false,

          -- Automatically install missing parsers when entering buffer
          -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
          auto_install = true,

          -- List of parsers to ignore installing (or "all")
          ignore_install = { "javascript" },

          ---- If you need to change the installation directory of the parsers (see -> Advanced Setup)
          -- parser_install_dir = "/some/path/to/store/parsers", -- Remember to run vim.opt.runtimepath:append("/some/path/to/store/parsers")!

          highlight = {
            enable = true,

            -- NOTE: these are the names of the parsers and not the filetype. (for example if you want to
            -- disable highlighting for the `tex` filetype, you need to include `latex` in this list as this is
            -- the name of the parser)
            -- list of language that will be disabled
            -- disable = { "c", "rust" },
            -- Or use a function for more flexibility, e.g. to disable slow treesitter highlight for large files
            disable = function(lang, buf)
              local max_filesize = 100 * 1024 -- 100 KB
              local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
              if ok and stats and stats.size > max_filesize then
                return true
              end
            end,

            -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
            -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
            -- Using this option may slow down your editor, and you may see some duplicate highlights.
            -- Instead of true it can also be a list of languages
            additional_vim_regex_highlighting = false,
          },
          indent = { enable = true },
        })
      end
    }
  },
  -- Configure any other settings here. See the documentation for more details.

  -- automatically check for plugin updates
  checker = { enabled = true },
})

