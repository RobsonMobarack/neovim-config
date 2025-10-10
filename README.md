# My Personal Neovim Configuration

This repository contains my personal and opinionated Neovim configuration. The goal is to create a tailored development environment that is optimized for my workflow across a wide variety of programming languages.

This setup is built from the ground up to be my own, reflecting the tools and settings I prefer for daily development tasks.

> **Note**: This configuration is currently under active development. Feel free to explore, but be aware that breaking changes may occur as I continue to refine it.

## ✨ Features

- **Plugin Management with `lazy.nvim`**: Fast, declarative, and easy to manage plugins.
- **Broad Language Support**: Pre-configured support for a wide array of languages using Neovim's native LSP and Tree-sitter.
- **Functional UI**: A clean and practical user interface, featuring `Nvim-tree` for file system navigation.
- **Personalized Experience**: Keymaps and settings are fine-tuned for my personal productivity.

## 🛠️ Supported Languages

This configuration is optimized to work with the following languages out of the box:

`c` `cpp` `csharp` `cmake` `css` `scss` `dockerfile` `go` `graphql` `html` `java` `javascript` `typescript` `tsx` `json` `lua` `make` `markdown` `python` `bash` `powershell` `query` `regex` `sql` `xml` `yaml` `vim` `vimdoc`

_...and more as my needs evolve._

## 🚀 Installation

**Prerequisites:**

- **Neovim v0.9.0+**
- **Git** (for cloning the repository and managing plugins)
- A **Nerd Font** (for icons to display correctly)
- Basic build tools (like `make`, `gcc`, etc.) for compiling some plugins.

### Steps

1.  **Backup your existing Neovim configuration (if any):**

    ```bash
    # Make a backup of your current nvim folder
    mv ~/.config/nvim ~/.config/nvim.bak
    ```

2.  **Clone this repository:**

    ```bash
    git clone https://github.com/RobsonMobarack/neovim-config.git ~/.config/nvim
    ```

3.  **Launch Neovim:**

    ```bash
    nvim
    ```

    On the first launch, `lazy.nvim` will automatically install all the plugins. Once it's done, restart Neovim to apply all settings.

Enjoy your new setup\!
