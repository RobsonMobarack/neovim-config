# My Personal Neovim Configuration

This repository contains my personal and opinionated Neovim configuration. The goal is to create a tailored development environment that is optimized for my workflow across a wide variety of programming languages, with a strong focus on stability and performance.

This setup is built from the ground up to be my own, reflecting the tools and settings I prefer for daily development tasks.

> **Note**: This configuration is currently under active development. Feel free to explore, but be aware that breaking changes may occur as I continue to refine it.

## ✨ Features

- **🤖 AI-Powered Development**: Integrated with **Avante.nvim** to provide intelligent code generation, refactoring, and chat, supporting multiple providers out of the box (OpenRouter, Gemini, Groq).
- **🚀 Blazing Fast Autocompletion**: Powered by **Blink.cmp** for lag-free, snippet-rich autocompletion without the overhead of older plugins.
- **🛠️ Robust LSP & Formatting Setup**:
  - Native LSP (`nvim-lspconfig`) leveraging the **new Neovim 0.11 API**.
  - `Mason` for effortless auto-installation of language servers, linters, and formatters.
  - Automatic formatting on save using `none-ls` (Prettier, Stylua).
- **☕ Java Specialist**: Advanced `nvim-jdtls` configuration with automatic path detection, Hot Code Replace (HCR), debugging (DAP), testing support, and Lombok integration.
- **🐛 Advanced Debugging (DAP)**: Full debug adapter protocol integration with UI panels (`nvim-dap-ui`) for:
  - **Java**
  - **C/C++** (`codelldb`)
  - **Lua** (`one-small-step-for-vimkind` for OSV Neovim plugin debugging)
- **🌐 Web Dev Ready**: Optimized for Angular/Ionic (custom workspace injection), React, and generic TypeScript/JavaScript workflows.
- **🔍 Git & Navigation**:
  - **Telescope**: Powerful fuzzy finder for files, live grep, buffers, and LSP symbols.
  - **Neogit**: A Magit-like integrated Git interface.
  - **Neo-tree**: A feature-rich file explorer with git and diagnostic integration.
  - **nvim-window-picker**: Easily jump between complex split layouts.
- **🎨 Modern UI/UX**:
  - **Visuals**: `Gruvbox` theme with consistent rounded borders for all floating windows (Hover, Diagnostics, Completion).
  - **Trouble.nvim**: A beautiful panel for listing diagnostics, references, and quickfixes.
  - Native **Inlay Hints** and **Signature Help**.
- **⚡ Productivity**:
  - **Auto-Compile C**: Quick save, build, and run for C files with `<F5>`.
  - **Neogen**: Automated docstring and Javadoc generation.

## 🛠️ Supported Languages & Tools

This configuration is optimized to work with the following languages out of the box:

**Primary Support (LSP + Treesitter + Formatting):**
`lua` `typescript` `javascript` `angular` `java` `python` `go` `c` `cpp` `html` `css/scss` `json` `yaml` `bash` `sql` `dockerfile`

**Tools:**
`eslint_d` `prettierd` `gotestsum` `cspell` `clangd`

## 🚀 Installation

**Prerequisites:**

- **Neovim v0.11+** (This configuration utilizes the latest native LSP APIs from 0.11. *Note: 0.12 may present instabilities at the moment*).
- **Git**
- A **Nerd Font** (e.g., JetBrainsMono Nerd Font)
- **Build Tools**: `gcc` (or `clang`), `make`, `unzip`, `npm`, `pip` (needed for Mason to build servers).
- **Java**: JDK 17+ or 21+ (required for `jdtls`).

### Steps

1.  **Backup your existing Neovim configuration (if any):**

    ```bash
    # Make a backup of your current nvim folder
    # Linux/Mac
    mv ~/.config/nvim ~/.config/nvim.bak
    
    # Windows (PowerShell)
    mv $env:LOCALAPPDATA\nvim $env:LOCALAPPDATA\nvim.bak
    ```

2.  **Clone this repository:**

    **Linux/Mac:**
    ```bash
    git clone https://github.com/RobsonMobarack/neovim-config.git ~/.config/nvim
    ```

    **Windows:**
    ```powershell
    git clone https://github.com/RobsonMobarack/neovim-config.git $env:LOCALAPPDATA\nvim
    ```

3.  **Launch Neovim:**

    ```bash
    nvim
    ```

    On the first launch, `lazy.nvim` will automatically install all the plugins, and `Mason` will begin installing the LSP servers. Once it's done, restart Neovim to ensure everything is loaded correctly.

Enjoy your new setup!
