# My Personal Neovim Configuration

This repository contains my personal and opinionated Neovim configuration. The goal is to create a tailored development environment that is optimized for my workflow across a wide variety of programming languages, with a strong focus on stability and performance.

This setup is built from the ground up to be my own, reflecting the tools and settings I prefer for daily development tasks.

> **Note**: This configuration is currently under active development. Feel free to explore, but be aware that breaking changes may occur as I continue to refine it.

## ✨ Features

- **Plugin Management with `lazy.nvim`**: Fast, declarative, and easy to manage plugins.
- **Cross-Platform Engineering**: Logic specifically written to work seamlessly on **Windows, macOS, and Linux**, handling paths and binaries automatically.
- **Robust LSP Setup**:
  - Native LSP (`nvim-lspconfig`) with `Mason` for auto-installation.
  - **Java Specialist**: Advanced `nvim-jdtls` configuration with automatic path detection, debugging (DAP), and testing support.
  - **Web Dev Ready**: Optimized for Angular/Ionic (custom workspace injection) and React.
- **Modern UI/UX**:
  - **Neo-tree**: A feature-rich file explorer with git integration.
  - **Visuals**: `Gruvbox` theme, consistent rounded borders for all floating windows (Hover, Diagnostics, Completion).
  - **Trouble.nvim**: A pretty list for showing diagnostics, references, and quickfixes.
- **Productivity**:
  - **Auto-Compile C**: Quick run for C files with F5.
  - **Prettier & ESLint**: Automatic formatting and linting fix on save.

## 🛠️ Supported Languages & Tools

This configuration is optimized to work with the following languages out of the box:

**Primary Support (LSP + Treesitter + Formatting):**
`lua` `typescript` `javascript` `angular` `java` `python` `go` `c` `cpp` `html` `css/scss` `json` `yaml` `bash` `sql` `dockerfile`

**Tools:**
`eslint_d` `prettierd` `gotestsum` `cspell`

## 🚀 Installation

**Prerequisites:**

- **Neovim v0.10.0+** (Required for modern `vim.uv` API support)
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
    git clone [https://github.com/RobsonMobarack/neovim-config.git](https://github.com/RobsonMobarack/neovim-config.git) ~/.config/nvim
    ```

    **Windows:**
    ```powershell
    git clone [https://github.com/RobsonMobarack/neovim-config.git](https://github.com/RobsonMobarack/neovim-config.git) $env:LOCALAPPDATA\nvim
    ```

3.  **Launch Neovim:**

    ```bash
    nvim
    ```

    On the first launch, `lazy.nvim` will automatically install all the plugins and `Mason` will install the LSP servers. Once it's done, restart Neovim to ensure everything is loaded correctly.

Enjoy your new setup!
