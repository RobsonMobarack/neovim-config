# **Neovim Cheat Sheet**

**Author:** Robson Mobarack  
**Leader Key:** \<Space\> (Spacebar)

---

## **1. Custom Bindings (Editor & Compilation)**

Manual shortcuts configured for window management and code execution.

| Keymap | Action | Description |
| :--- | :--- | :--- |
| **\<Space\> s** | `:write` | Saves the current file. |
| **\<Space\> h** | `:noh` | Clears the highlight from the last search. |
| **\<F5\>** | Run C | **Cross-Platform:** Saves, compiles with `gcc`, and executes the binary (detects Windows/Linux automatically). |
| **\<C-h/j/k/l\>** | `wincmd` | Moves focus to the left/bottom/top/right window (Linux/Mac only). |

## **2. Java Development (JDTLS & DAP)**

Specific commands for Java development (active only in `.java` buffers).

| Keymap | Action (Lua) | Description |
| :--- | :--- | :--- |
| **\<Space\> jo** | `jdtls.organize_imports` | Organizes imports for the current class. |
| **\<Space\> jt** | `jdtls.test_class` | Runs unit tests for the current **class**. |
| **\<Space\> jn** | `jdtls.test_nearest_method` | Runs the test for the **method** closest to the cursor. |
| **\<Space\> dr** | `dap.continue` | **Run/Debug:** Starts or continues debugging the main class. |
| **\<Space\> dq** | `dap.terminate` | **Terminate the application** / Java debug session. |
| **\<Space\> jb** | `jdtls.compile` | **Forces incremental compilation** of the file (Generates `.class`). |
| **\<Space\> jh** | `session:request` | Injects Hot Code Replace directly into the JVM (**Live Reload**). |

> [!TIP]
> **Ideal Workflow:** Press `<leader>dr` to start the app. Make your edits, save, and press `<leader>jh` to apply HotSwap. When finished, press `<leader>dq` to properly close the application and free the JVM.

## **3. Advanced Debugging & UI (nvim-dap & dap-ui)**

Commands to inspect and control the step-by-step execution of your application.

| Keymap | Action | What it actually does |
| :--- | :--- | :--- |
| **\<Space\> dt** | **Toggle UI** | Manually opens or closes the Debugger visual panels (Variables, Stack, etc.). |
| **\<Space\> db** | **Toggle Breakpoint** | Toggles a red breakpoint on the line. When the app reaches here, execution freezes. |
| **\<Space\> dB** | **Cond. Breakpoint** | Same as above, but opens an input for you to type an expression (e.g., `i == 10`). It only pauses if true. |
| **\<Space\> dx** | **Clear Breakpoints** | Removes all breakpoints from the project at once. |
| **\<F10\> or \<Space\> do** | **Step Over** | Executes the current line and jumps to the next. If it's a method call, it executes it silently without entering. |
| **\<F11\> or \<Space\> di** | **Step Into** | If the line is a method call in your code, it "enters" that method so you can debug inside it. |
| **\<F12\> or \<Space\> du** | **Step Out (Up)** | If you entered a method by mistake, this instantly executes the rest of it and returns you to the caller. |
| **\<Space\> dl** | **Attach OSV** | Attaches to a running Neovim instance for Lua debugging (One Small Step for Vimkind). |

## **4. LSP (Language Server Protocol)**

Commands active when a language server is attached to the buffer.

| Keymap | Action | Description |
| :--- | :--- | :--- |
| **gd** | `buf.definition` | Go to the definition of the symbol under the cursor. |
| **\<C-o\>** | | Go back to the previous location (Navigates back in the jumplist). |
| **\<C-i\>** | | Jump forward to the definition again. |
| **K** | `buf.hover` | Displays floating documentation about the symbol. |
| **\<C-k\>** | `signature_help` | Displays signature help for functions/methods while typing parameters (Insert Mode). |
| **gr** | `buf.references` | Lists all references of the symbol in the project. |
| **\<Space\> rn** | `buf.rename` | Renames the symbol under the cursor across the entire project. |
| **\<Space\> ca** | `buf.code_action` | Shows code actions (Quick Fix, Refactor, Imports). |
| **\<Space\> f** | `buf.format` | Formats the current buffer (via LSP or `none-ls`). |
| **\<Space\> ih** | `inlay_hint` | Toggles the display of inlay hints in the current buffer. |

## **5. Generators & Autocompletion (Blink.cmp & Neogen)**

You migrated from `nvim-cmp` to `blink.cmp`. Your configuration ensures that `<Tab>` only navigates the list without accidentally inserting text.

| Keymap | Context | Description |
| :--- | :--- | :--- |
| **\<Enter\>** | Insert Mode | Confirms the selected suggestion in the Blink menu. |
| **\<Tab\>** | Insert Mode | Selects the next item in the list or advances in the Snippet. |
| **\<S-Tab\>** | Insert Mode | Selects the previous item or goes back in the Snippet. |
| **\<Space\> nf** | Normal Mode | Neogen: Automatically generates docstrings/Javadocs for the class or method under the cursor. |

## **6. File Explorer (Neo-tree)**

Management of the file and directory tree.

| Keymap (Global) | Description | | Key (Internal) | Description |
| :--- | :--- | :--- | :--- | :--- |
| **\<Space\> ee** | Toggles the explorer. | | **a** | Creates a new file/folder (end with `/` for folders). |
| **\<Space\> ef** | Focuses the current file in the tree. | | **d** | Deletes a file/folder. |
| **\<Space\> ec** | Explicitly closes the explorer window. | | **r** | Renames the file. |
| **\<Space\> er** | Refreshes the tree. | | **c / x / p** | Copies / Cuts / Pastes the file. |
| **\<Space\> ed** | Opens focused on the current directory. | | **\<Enter\> / l**| Opens file or expands folder. |
| **\<Space\> eo** | Opens as a floating window. | | **?** | Shows the list of shortcuts. |
| **\<Space\> eh** | Focuses the left window (where Neo-tree is).| | | |
| **\<Space\> el** | Focuses the right window (editor). | | | |

## **7. Search (Telescope)**

Advanced fuzzy search for files, text, and buffers.

| Keymap (Global) | Description | Key (Internal) | Description |
| :--- | :--- | :--- | :--- |
| **\<Space\> ff** | Search files by name. | **\<Enter\>** | Opens the selected file. |
| **\<Space\> fg** | Search for text occurrences. | **\<C-v\>** | Opens in a vertical split. |
| **\<Space\> fb** | List open buffers. | **\<C-s\>** | Opens in a horizontal split. |
| **\<Space\> fh** | Search in Neovim Help. | **\<Esc\>** | Closes the Telescope window. |
| **\<Space\> fs** | Search methods/variables in the current class. | | |

## **8. Diagnostics & Symbols (Trouble)**

Structured visualization of code errors and symbols.

| Keymap | Action | Description |
| :--- | :--- | :--- |
| **\<Space\> xx** | `diagnostics toggle` | Toggles project diagnostics (errors/warnings). |
| **\<Space\> xX** | `buffer diagnostics` | Toggles diagnostics for the current buffer. |
| **\<Space\> cs** | `symbols toggle` | Toggles the symbol structure (outline). |
| **\<Space\> cl** | `lsp toggle` | Toggles LSP definitions and references. |
| **\<Space\> xL** | `loclist toggle` | Opens the Location List. |
| **\<Space\> xQ** | `qflist toggle` | Opens the Quickfix List. |

## **9. Comments (Comment.nvim)**

Tools for code productivity and quick commenting.

| Keymap / Command | Description |
| :--- | :--- |
| **gcc** | Comments/Uncomments the current line. |
| **gc{motion}** | Comments the area defined by the motion (e.g., `gcG`). |
| **gc** (Visual) | Comments the visual selection. |
| **gbc** | Block comments the current line. |
| **gb{motion}** | Block comments the area defined by the motion. |
| **gb** (Visual) | Block comments the visual selection. |
| **gco** | Inserts a commented line **below** and enters Insert Mode. |
| **gcO** | Inserts a commented line **above** and enters Insert Mode. |
| **gcA** | Inserts a comment at the end of the current line and enters Insert Mode. |

## **10. Git (Neogit)**

Graphical Git interface inside Neovim.

**Access:** Type `:Neogit<CR>` (no global shortcut defined).

**Internal Commands (Neogit Window)**

| Key | Action | Description |
| :--- | :--- | :--- |
| **s** | Stage | Adds the selected file or hunk to the index. |
| **u** | Unstage | Removes the selected file or hunk from the index. |
| **c** | Commit | Opens the window to write the commit message. |
| **P (Shift+p)** | Push | Executes `git push` to the remote. |
| **F (Shift+f)** | Pull | Executes `git pull` from the remote. |
| **?** | Help | Shows all Neogit shortcuts. |
| **q** | Close | Closes the Neogit window. |

## **11. Artificial Intelligence (Avante.nvim)**

AI-assisted coding and chat directly in the editor using multiple providers (OpenRouter, Gemini, Groq).

| Keymap | Context | Description |
| :--- | :--- | :--- |
| **\<Space\> aa** | Normal / Visual | Shows the Avante chat sidebar (Ask). |
| **\<Space\> ae** | Normal / Visual | Edits the selected code via AI prompt. |
| **\<Space\> ar** | Normal | Refreshes the sidebar. |
| **\<Space\> af** | Normal | Switches the AI provider/model on the fly. |
| **\<Space\> a?** | Normal | Shows all available Avante keymaps. |

> [!NOTE]
> When the Avante sidebar is focused, you can use `<Tab>` and `<S-Tab>` to navigate between sections, and `<CR>` to submit your prompt.

## **12. Background Magic (Automatic Plugins)**

Tools that operate without direct shortcuts.

- **nvim-autopairs:** Automatically closes parentheses, brackets, and quotes.
- **none-ls:** Formatting on save and linters (Prettier, Eslint, Stylua).
- **nvim-treesitter:** Advanced syntax highlighting and indentation.
- **indent-blankline:** Visual indentation guides.
- **nvim-lsp-file-operations:** Updates imports in other files when renaming via Neo-tree.
- **nvim-window-picker:** When opening a file via Neo-tree with multiple splits, prompts you to type a letter over the target window.
- **lazydev.nvim:** Configures Lua LSP to understand the Neovim API, ensuring autocompletion while editing `init.lua`.

---

### **Ninja Tips (Native Hidden Powers)**

Since you are using the full ecosystem, here are native Vim commands combined with your extensions that **don't require new shortcuts** but speed up your editing:

- **Block Manipulation (Native Vim):** Vim understands your code structure by braces `{}` and parentheses `()`.
  - Place the cursor anywhere inside a method and type `vi{` (Visual Inside Braces). It perfectly selects the entire body of the method.
  - Type `di{` to delete the entire content of the method, leaving only the signature intact.
  - Type `yi{` to copy the entire content of the method.
- **Automatic Renaming (Neo-tree + LSP):** Thanks to `nvim-lsp-file-operations`, when you open Neo-tree (`<Space> ee`), focus on a Java file, and press `r` to rename it, Neovim automatically searches all other project files that imported this class and updates the import and names instantly.
- **Window Picker:** When you have 3 or more split windows and try to open a new file via Neo-tree, you will notice colored letters appearing over each window. Just type the corresponding letter to open the file exactly where you want, without messing up your current layout.
