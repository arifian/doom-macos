# Doom Emacs Configuration - Agent Guidelines

## Build/Sync Commands
- **Sync after changes**: `doom sync` (required after modifying `init.el` or `packages.el`)
- **Reload config**: `M-x doom/reload` or restart Emacs to apply `config.el` changes
- **Check health**: `doom doctor` to diagnose issues
- **Byte-compile**: `doom build` (automatic on sync)
- **No test framework**: This is a personal config; test manually in Emacs

## Code Style (Emacs Lisp)
- **File header**: Always include `;;; $DOOMDIR/filename.el -*- lexical-binding: t; -*-`
- **Lexical binding**: Required (declared in file header)
- **Comments**: Use `;;` for inline, `;;;` for section headers, separator lines with `=` for major sections
- **Indentation**: 2 spaces per level, align closing parens vertically
- **Naming**: kebab-case for all symbols (`my-function`, `doom-leader-key`)
- **Private functions**: Namespace with prefix (e.g., `my/treemacs-toggle-focus`)
- **Strings**: Use double quotes for strings, prefer `setq` over `setf`

## Config.el Organization
Follow this order to prevent loading issues and maintain readability:
1. **macOS System Settings** - Modifier keys (MUST BE FIRST)
2. **User Information** - Name, email (optional)
3. **Visual Settings** - Line numbers, fonts, UI preferences
4. **Location-aware Theme** - Circadian configuration
5. **Org Mode Settings** - Directory and org-specific configs
6. **Package Configurations** - All `use-package!` and `after!` blocks
7. **Custom Functions** - Helper functions and keybindings
8. **Default Doom Documentation** - Keep at bottom for reference

## Imports & Package Management
- **Add packages**: Declare in `packages.el` using `(package! name)`, then `doom sync`
- **Configure packages**: Wrap in `(after! PACKAGE ...)` or `(use-package! PACKAGE ...)` in `config.el`
- **External recipes**: Use `:recipe` for GitHub packages: `(package! name :recipe (:host github :repo "user/repo"))`
- **Load order**: macOS modifier keys MUST be set first in `config.el` (before any package loads)
- **Local files**: Use `(load! "file")` for relative loads or `(require 'package)` for installed packages

## Error Handling & Best Practices
- **Lazy loading**: ALWAYS use `(use-package! ...)` or `(after! PACKAGE ...)` instead of `(require 'package)`
  - Prevents fullscreen lockup issues and race conditions during UI transitions
  - Improves startup performance by deferring package initialization
  - Example: Use `(use-package! ergoemacs-mode :init ... :config ...)` NOT `(require 'ergoemacs-mode)`
- **Avoid duplicates**: Check existing keybindings before adding new ones to prevent conflicts
- **macOS keybindings**: Use `ergoemacs-user-keymap` for custom keys; avoid system shortcuts (Cmd+Space, etc.)
- **Interactive functions**: Mark with `(interactive)` and provide docstrings
- **Location-aware themes**: Use `circadian` with `calendar-latitude`/`calendar-longitude` for auto theme switching
- **Package declarations**: Check for duplicates in `packages.el` before adding new packages

## Known Issues & Solutions
- **Fullscreen lockup/frozen controls**: 
  - Cause: Synchronous package loading with `(require 'package)` during UI transitions
  - Solution: Use `(use-package! package ...)` or `(after! package ...)` for lazy loading
  - Affected packages: ergoemacs-mode, cider (now fixed)
- **Keybinding conflicts**: 
  - Use `ergoemacs-user-keymap` for custom keybindings
  - Avoid macOS system shortcuts (Cmd+Space, Cmd+Tab, etc.)
- **Theme not switching automatically**: 
  - Ensure `calendar-latitude` and `calendar-longitude` are set before `circadian` config
  - Check `circadian-themes` alist uses valid theme names
