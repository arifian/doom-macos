#!/usr/bin/env bash
#
# install.sh — install the external requirements for this Doom config on macOS.
#
# Installs (via Homebrew): emacs-plus, the nerd-icons font, and ripgrep.
# Then clones Doom Emacs if it isn't already present and runs `doom sync`.
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

# --- 1. Emacs (emacs-plus) ----------------------------------------------------
if brew_installed "$EMACS_PLUS_FORMULA"; then
  info "$EMACS_PLUS_FORMULA already installed — skipping."
else
  info "Installing $EMACS_PLUS_FORMULA (with native-comp)…"
  brew tap d12frosted/emacs-plus
  brew install "$EMACS_PLUS_FORMULA" --with-native-comp
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

# --- 4. Doom Emacs ------------------------------------------------------------
if [ -d "$DOOM_DIR" ]; then
  info "Doom already present at $DOOM_DIR — skipping clone."
else
  info "Cloning Doom Emacs into $DOOM_DIR…"
  git clone --depth 1 https://github.com/doomemacs/doomemacs "$DOOM_DIR"
fi

# --- 5. Sync ------------------------------------------------------------------
DOOM_BIN="$DOOM_DIR/bin/doom"
if [ -x "$DOOM_BIN" ]; then
  info "Running doom sync…"
  "$DOOM_BIN" sync
else
  warn "doom binary not found at $DOOM_BIN — run 'doom install' manually."
fi

info "Done. Launch with: open -a Emacs"
