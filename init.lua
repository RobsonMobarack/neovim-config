-- To execute commands like :colorscheme, vim.cmd is still the correct way.
vim.cmd.colorscheme("elflord") -- An alternative and more "Lua-like" way to call the command.

-- Indentation Options
vim.opt.expandtab = true        -- Use spaces instead of tabs
vim.opt.tabstop = 2             -- A tab is equivalent to 2 spaces
vim.opt.softtabstop = 2         -- How many spaces to insert when pressing <Tab>
vim.opt.shiftwidth = 2          -- How many spaces to use for automatic indentation
vim.opt.autoindent = true       -- Copy indentation from the previous line

-- Editor Interface
vim.opt.number = true           -- Show line numbers
vim.opt.relativenumber = true   -- Show relative line numbers (great for navigation)
vim.opt.mouse = 'a'             -- Enable the mouse in all modes

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
