# AGENTS.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

This is a personal **Doom Emacs** private configuration directory (`$DOOMDIR`), living at
`~/.config/doom`. It is the user's `arifian/doom-macos` config, being rebuilt fresh for
**macOS Tahoe 26.5.1** on Apple Silicon.

The config is being rebuilt in **phases** on top of the pristine Doom template. The old elaborate
setup (circadian, rust-analyzer, `custom.el`) was wiped first; pieces are reintroduced
deliberately, not restored wholesale.

**Phase 1 (done):** non-modal editing via **ergoemacs-mode** (evil deliberately disabled) plus a
**treemacs** file tree, tuned for macOS. Concretely:
- `init.el` — `(evil +everywhere)` commented out, `treemacs` enabled.
- `packages.el` — declares `ergoemacs-mode` (treemacs comes from its Doom module).
- `config.el` — lazy-loads ergoemacs (US layout, `ergoemacs-theme nil`); maps **⌘ → Meta** so
  ergoemacs nav lands on ⌘+JKLI; sets `inhibit-compacting-font-caches t` (perf); configures treemacs
  (toggle `<f8>`, open+focus `S-<f8>`, kept in the `other-window` rotation).

**This config has no evil/vim modal editing** — do not assume `SPC` leader or vim motions. Doom's
leader is the alt key (`C-c`) here, and ergoemacs provides the day-to-day CUA-style bindings.

Remaining phases (fonts/theme, LSP + language servers, org/completion tuning) are tracked as BACKLOG
tasks and cherry-picked as needed.

## Hard-won gotchas (don't rediscover these)

- **Missing nerd-icons font = pervasive GUI slowness.** `doom-modeline`/treemacs/dashboard render
  icon glyphs every redraw; with no nerd font installed, macOS font-fallback search makes the whole
  UI crawl and beachball while `emacs -Q` stays fast. Fix: install `font-symbols-only-nerd-font` (see
  setup) + `inhibit-compacting-font-caches t`. **A full restart is required** (fonts load at startup,
  not on `doom/reload`).
- **emacs-plus reads `ns-*` modifier vars, not `mac-*`.** The `mac-command-modifier` lines in the
  old config were silently ignored (those belong to the *emacs-mac* port). Use `ns-command-modifier`
  etc. Doom's `:os macos` module sets **no** modifiers; the NS defaults are ⌘=super, ⌥=meta.
- **Doom's `init.el` is a CLI bootstrap, not a library** — never `emacs --batch -l init.el`, it errors.
  To sanity-check a config file, byte-balance it: `emacs --batch --eval '(... (check-parens))'`.

## Environment (do not assume Linux/Intel defaults)

- **Emacs 30.2** installed via `emacs-plus@30` from the `d12frosted/homebrew-emacs-plus` tap
  (`brew install emacs-plus@30`).
- **Apple Silicon**: Homebrew prefix is `/opt/homebrew` (not `/usr/local`). Binaries the GUI
  Emacs needs (`cargo`, `rustup`, language servers, etc.) must be made visible to Emacs, which
  does **not** inherit the shell `PATH` when launched from the Dock. Set `exec-path`/`PATH`
  explicitly in `config.el` for GUI launches (planned with the LSP phase, not done yet).
- **A nerd-icons font must be installed** (`brew install --cask font-symbols-only-nerd-font`) — see
  the slowness gotcha below.
- Doom core lives at `~/.config/emacs` (the `doom` binary is `~/.config/emacs/bin/doom`).
- `DOOMDIR` resolves to this repo (`~/.config/doom`).
- Repo remote: `https://github.com/arifian/doom-macos` (branch `main`).

## The three files and the load model

Doom's config is split by *purpose*, and the workflow differs per file — this is the single most
important thing to get right:

- **`init.el`** — enables/disables Doom **modules** via the `doom!` macro (e.g. `(corfu +orderless)`,
  `magit`, `(evil +everywhere)`). Editing this changes which packages Doom installs and how it
  boots. **Requires `doom sync` afterward.**
- **`packages.el`** — declares extra packages beyond what modules provide, via `(package! ...)`
  with optional `:recipe`/`:pin`. `no-byte-compile: t` is set on this file. **Requires `doom sync`
  afterward.**
- **`config.el`** — your actual settings, keybindings, and package customization. **No `doom sync`
  needed** — reload with `M-x doom/reload` or restart Emacs.

Load order in `config.el` matters: variables that packages read at load time (e.g. `org-directory`,
font specs) must be set before the package loads. macOS modifier-key settings should come first.

## Common commands

Run from a shell (the `doom` script is `~/.config/emacs/bin/doom`; add it to PATH or call it by path):

- `doom sync` — install/remove packages and rebuild to match `init.el` + `packages.el`. **Run after
  editing either file.**
- `doom doctor` — diagnose configuration/environment problems (missing fonts, servers, PATH issues).
- `doom upgrade` — update Doom itself and all packages.
- `doom build` — byte-compile packages (normally done as part of `sync`).
- There is **no test suite** — this is a personal config. Verify changes by reloading
  (`M-x doom/reload`) or restarting Emacs and exercising the affected feature manually.

## Conventions for Emacs Lisp here

- Every file starts with the Doom header form, e.g.
  `;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-`. Keep `lexical-binding: t`.
- Customize packages with `(after! PACKAGE ...)` or `(use-package! PACKAGE ...)` so Doom's own
  defaults don't clobber your settings, and to keep loading lazy. **Prefer this over bare
  `(require 'package)`**, which forces eager loading and has historically caused UI lockups on macOS
  fullscreen transitions in this config.
- Bind keys with Doom's `map!` macro; load relative `.el` files with `load!`; extend `load-path`
  with `add-load-path!`.
- Exceptions that may be set at top level (no `after!` wrapper): file/directory vars like
  `org-directory`, `doom-`/`+`-prefixed Doom vars, and vars documented as "set before load".
