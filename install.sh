#!/usr/bin/env bash
#
# install.sh — install the external requirements for this Doom config on macOS.
#
# Installs (via Homebrew): emacs-plus, the nerd-icons font, and ripgrep, then
# the language servers / linters / formatters needed by the enabled :lang and
# (lsp +eglot) modules (brew + a few npm-only packages). Finally clones Doom
# Emacs if it isn't already present and runs `doom sync`.
#
# NOTE: this config uses (lsp +eglot). Unlike lsp-mode, eglot does NOT
# auto-install language servers — they must be present on PATH up front, which
# is why this script installs them.
#
# Safe to re-run: every step checks for an existing install before acting.
#
# Usage:
#   ./install.sh
#
set -euo pipefail

EMACS_PLUS_FORMULA="emacs-plus@30"
DOOM_DIR="${DOOM_DIR:-$HOME/.config/emacs}"

info()  { printf '\033[1;34m==>\033[0m %s\n' "$1"; }
warn()  { printf '\033[1;33mWARN:\033[0m %s\n' "$1" >&2; }

# --- Homebrew -----------------------------------------------------------------
if ! command -v brew >/dev/null 2>&1; then
  warn "Homebrew not found. Install it first: https://brew.sh"
  exit 1
fi

brew_installed() { brew list "$1" >/dev/null 2>&1; }
cask_installed() { brew list --cask "$1" >/dev/null 2>&1; }

# ensure_brew CHECK [INSTALL_SPEC] — install a formula unless already present.
# CHECK is the short formula name passed to `brew list`; INSTALL_SPEC is what
# `brew install` receives (defaults to CHECK; use the tap-qualified name when
# they differ, e.g. clojure-lsp-native lives in a custom tap).
ensure_brew() {
  local check="$1" spec="${2:-$1}"
  if brew_installed "$check"; then
    info "$check already installed — skipping."
  else
    info "Installing ${check}…"
    # Tolerate a single failed formula (e.g. renamed/removed) without aborting
    # the whole run under `set -e`.
    brew install "$spec" || warn "Failed to install ${check} — continuing."
  fi
}

# ensure_npm BIN [PKG] — global-install an npm package unless its binary is
# already on PATH. BIN is the command the package provides; PKG is the npm
# package name (defaults to BIN).
ensure_npm() {
  local bin="$1" pkg="${2:-$1}"
  if command -v "$bin" >/dev/null 2>&1; then
    info "$pkg (npm) already present — skipping."
  else
    info "Installing $pkg (npm global)…"
    npm install -g "$pkg" || warn "Failed to install $pkg (npm) — continuing."
  fi
}

# --- 1. Emacs (emacs-plus) ----------------------------------------------------
if brew_installed "$EMACS_PLUS_FORMULA"; then
  info "$EMACS_PLUS_FORMULA already installed — skipping."
else
  info "Installing $EMACS_PLUS_FORMULA (native-comp is on by default)…"
  brew tap d12frosted/emacs-plus
  brew install "$EMACS_PLUS_FORMULA"
  info "Creating Spotlight-indexable alias in /Applications…"
  osascript -e 'tell application "Finder" to make alias file to POSIX file "/opt/homebrew/opt/'"$EMACS_PLUS_FORMULA"'/Emacs.app" at POSIX file "/Applications"' || \
    warn "Could not create /Applications alias — create it manually if you want Spotlight to find Emacs."
fi

# --- 2. Nerd-icons font (prevents UI slowness — see README) -------------------
if cask_installed font-symbols-only-nerd-font; then
  info "font-symbols-only-nerd-font already installed — skipping."
else
  info "Installing nerd-icons font (prevents pervasive GUI slowness)…"
  brew install --cask font-symbols-only-nerd-font
fi

# --- 3. ripgrep (required by the ivy/counsel + projectile search) -------------
if brew_installed ripgrep; then
  info "ripgrep already installed — skipping."
else
  info "Installing ripgrep (search backend for ivy/counsel)…"
  brew install ripgrep
fi

# --- 4. Language tooling via Homebrew -----------------------------------------
# Servers / linters / formatters for the enabled :lang + (lsp +eglot) modules.
info "Installing language tooling (Homebrew)…"

# Shared bases: openjdk backs jdtls/clojure-lsp/plantuml/languagetool; node
# backs every npm-packaged server installed in step 5.
ensure_brew openjdk

# node backs the npm servers in step 5. Reuse an existing node+npm if both are
# already on PATH (e.g. nvm — source it before running to have it picked up);
# otherwise install a stable Homebrew node. NOTE: an nvm node is invisible to a
# Dock-launched (non-login) Emacs, so a brew node is the more reliable choice
# for the eglot server toolchain.
if command -v node >/dev/null 2>&1 && command -v npm >/dev/null 2>&1; then
  info "node already on PATH ($(command -v node)) — skipping brew node."
else
  ensure_brew node
fi

# go (+lsp)
ensure_brew gopls
ensure_brew gofumpt
ensure_brew golangci-lint
# goimports has no Homebrew formula — fetch via `go install` if Go is present.
if command -v go >/dev/null 2>&1 && ! command -v goimports >/dev/null 2>&1; then
  info "Installing goimports (go install)…"
  go install golang.org/x/tools/cmd/goimports@latest || warn "goimports install failed — continuing."
fi

# java (+lsp)
ensure_brew jdtls

# clojure (+lsp) — the homebrew-core `clojure-lsp` formula is deprecated; use
# the official tap's native build.
ensure_brew clojure
ensure_brew leiningen
ensure_brew clojure-lsp-native clojure-lsp/brew/clojure-lsp-native

# python
ensure_brew pyright
ensure_brew black
ensure_brew isort

# sh
ensure_brew shellcheck
ensure_brew shfmt

# nix — the nixd LSP server isn't on Homebrew (nixd/nil ship via nixpkgs). If the
# nix package manager is present, install nixd into the user profile
# (~/.nix-profile/bin — global + on PATH). Formatter (nixfmt) still comes from brew.
if command -v nixd >/dev/null 2>&1; then
  info "nixd already on PATH ($(command -v nixd)) — skipping."
elif command -v nix >/dev/null 2>&1; then
  info "Installing nixd via nix profile…"
  nix profile install nixpkgs#nixd \
    || nix-env -iA nixpkgs.nixd \
    || warn "Could not install nixd via nix — install it manually if you want Nix LSP."
else
  warn "No nix and no brew formula for nixd — Nix LSP server skipped (nix-mode still works)."
fi
ensure_brew nixfmt

# php
ensure_brew php
ensure_brew php-cs-fixer

# markdown (preview compiler + lint comes from npm in step 5)
ensure_brew marksman
ensure_brew pandoc

# plantuml (needs the JDK above; graphviz/dot for several diagram types)
ensure_brew plantuml
ensure_brew graphviz

# checkers: spell + grammar
ensure_brew aspell
ensure_brew languagetool

# tools/pdf — pdf-tools compiles its epdfinfo server against poppler
ensure_brew poppler

# completion: faster file finding for projectile/consult (ripgrep done above)
ensure_brew fd

# --- 5. Language tooling via npm (no Homebrew formula) ------------------------
if command -v npm >/dev/null 2>&1; then
  info "Installing npm-only language servers / tools…"
  ensure_npm typescript-language-server                       # javascript
  ensure_npm tsc typescript                                   # javascript
  ensure_npm bash-language-server                             # sh
  ensure_npm yaml-language-server                             # yaml
  ensure_npm vscode-json-language-server vscode-langservers-extracted  # json/web (html/css/json)
  ensure_npm intelephense                                     # php (npm-only)
  ensure_npm prettier                                         # javascript/web format
  ensure_npm eslint                                           # javascript lint
  ensure_npm stylelint                                        # web CSS lint
  ensure_npm js-beautify                                      # web JS/CSS/HTML format
  ensure_npm markdownlint markdownlint-cli                    # markdown lint
else
  warn "npm not found — skipping npm-based servers. Install Node (step 4 brews it) and re-run."
fi

# --- 6. Doom Emacs ------------------------------------------------------------
if [ -d "$DOOM_DIR" ]; then
  info "Doom already present at $DOOM_DIR — skipping clone."
else
  info "Cloning Doom Emacs into ${DOOM_DIR}…"
  git clone --depth 1 https://github.com/doomemacs/doomemacs "$DOOM_DIR"
fi

# --- 7. Sync ------------------------------------------------------------------
DOOM_BIN="$DOOM_DIR/bin/doom"
if [ -x "$DOOM_BIN" ]; then
  info "Running doom sync…"
  "$DOOM_BIN" sync
else
  warn "doom binary not found at $DOOM_BIN — run 'doom install' manually."
fi

info "Done. Launch with: open -a Emacs"
