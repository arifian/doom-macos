# Doom Emacs Configuration - Agent Guidelines

## Build/Sync Commands
- **Sync after changes**: `doom sync` (run after modifying `init.el` or `packages.el`)
- **Reload config**: Restart Emacs or `M-x doom/reload`
- **Check health**: `doom doctor`
- **Byte-compile**: Automatic on sync; manual via `doom build`

## Code Style (Emacs Lisp)
- **File header**: Always include `;;; $DOOMDIR/filename.el -*- lexical-binding: t; -*-`
- **Lexical binding**: Required (set in file header)
- **Comments**: Use `;;` for inline, `;;;` for top-level/section headers
- **Indentation**: 2 spaces per level, align closing parens
- **Naming**: Use kebab-case (`my-function`, `doom-leader-key`)
- **Private functions**: Prefix with namespace (e.g., `my/treemacs-toggle-focus`)

## Imports & Package Management
- **Add packages**: Declare in `packages.el` using `(package! name)`, then run `doom sync`
- **Configure packages**: Wrap in `(after! PACKAGE ...)` or `(use-package! PACKAGE ...)` in `config.el`
- **Load order**: Critical macOS settings (modifier keys) must come first in `config.el`
- **External files**: Use `(require 'package)` for built-in or `load!` for local files

## Configuration Best Practices
- **macOS settings**: Place modifier key settings at top of `config.el` before other configs
- **Keybindings**: Use `ergoemacs-user-keymap` or `map!` macro; avoid conflicts with system shortcuts
- **Theme switching**: Use `circadian` package for automatic day/night themes based on location
