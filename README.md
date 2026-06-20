# doom-macos

A personal, **reproducible [Doom Emacs](https://github.com/doomemacs/doomemacs) configuration for
macOS** (built and tested on **macOS Tahoe 26** / Apple Silicon, using
[`emacs-plus`](https://github.com/d12frosted/homebrew-emacs-plus)).

The goal is a configuration I can drop onto any Mac and have my editor feel like *my* editor in a
few commands — no hunting for the tweaks that took an afternoon to discover the first time.

## What this is and why

Most Doom configs assume **evil** (vim-style modal editing). I don't think in modes — I think in
**CUA-style, non-modal keys** (the muscle memory of ⌘/Ctrl shortcuts), so this config:

- **Replaces evil with [`ergoemacs-mode`](https://github.com/ergoemacs/ergoemacs-mode)** — ergonomic,
  non-modal navigation and editing. On this Mac, **⌘ is remapped to Meta**, so navigation lives on
  **⌘ + J/K/L/I** (left/down/right/up) under the home row, where my thumb already rests.
- **Adds a [treemacs](https://github.com/Alexander-Miller/treemacs) file tree** as a persistent
  project sidebar, reachable like any other window.
- Is built in **deliberate phases** rather than copied wholesale, so every package earns its place
  and the config stays understandable. Phase 1 (this commit) is editing + file tree; later phases
  (fonts/theme, LSP, org) are listed in the [Roadmap](#roadmap).

If you also dislike modal editing and want a CUA-style Doom on macOS, this is a working starting
point. If you *like* vim/evil, this is probably the wrong config to copy.

## Requirements

- macOS (developed on Apple Silicon / Tahoe 26; Intel should work, adjust the Homebrew prefix).
- [Homebrew](https://brew.sh).
- ~1–2 GB disk and a few minutes for the first `doom sync` / native compilation.

## Install on a new machine

> Doom lives in `~/.config/emacs`; this config lives in `~/.config/doom`. The two are separate.

### 1. Install Emacs (emacs-plus)

```sh
brew tap d12frosted/emacs-plus
brew install emacs-plus@30 --with-native-comp
# Put the app where macOS can find it (icon + Spotlight/Dock):
ln -s /opt/homebrew/opt/emacs-plus@30/Emacs.app /Applications/Emacs.app
```

### 2. Install the icon font (do NOT skip — see [Troubleshooting](#troubleshooting))

```sh
brew install --cask font-symbols-only-nerd-font
```

Without a nerd-icons font the Doom UI is painfully slow on macOS. This one line prevents it.

### 3. Install Doom Emacs

```sh
git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs
# add Doom's bin to your PATH (zsh):
echo 'export PATH="$HOME/.config/emacs/bin:$PATH"' >> ~/.zshrc
exec zsh
```

### 4. Install this configuration

```sh
# back up any existing Doom config first
[ -d ~/.config/doom ] && mv ~/.config/doom ~/.config/doom.bak
git clone https://github.com/arifian/doom-macos ~/.config/doom
```

### 5. Sync and launch

```sh
doom install     # first-time: installs packages, env file, etc.
# (or `doom sync` if you've run doom install before)
open -a Emacs
```

That's it. Repeat steps 3–5 verbatim on the next machine.

## Keybindings (Phase 1)

Because **⌘ = Meta** here, "⌘" below is the Meta key. Doom's leader is `C-c` (there's no `SPC`
leader — evil is off).

| Keys | Action |
|------|--------|
| `⌘ + I / K / J / L` | Move up / down / left / right (ergoemacs nav) |
| `⌘ + U / O` | Move by word (back / forward) |
| `⌘ + S` | Switch window (`other-window`) — **also cycles into the treemacs tree** |
| `F8` *(or `fn`+`F8`)* | Toggle the treemacs sidebar |
| `Shift + F8` | Open treemacs **and** jump focus into it |
| `C-c ...` | Doom leader (e.g. `C-c o p` also toggles treemacs) |

> macOS often steals the top-row F-keys for media. Either press **`fn`+`F8`**, or enable
> *System Settings → Keyboard → "Use F1, F2, etc. as standard function keys."*

## How the config is organized

Doom splits config by purpose across three files — and the update workflow differs per file:

| File | Purpose | After editing |
|------|---------|---------------|
| `init.el` | Enable/disable Doom **modules** (`doom!` macro) | **`doom sync`** |
| `packages.el` | Declare extra packages (`package!`) | **`doom sync`** |
| `config.el` | Your settings, keybindings, package tweaks | `M-x doom/reload` (no sync) |

Quick reference:

```sh
doom sync       # reconcile installed packages with init.el + packages.el
doom doctor     # diagnose environment/config problems
doom upgrade    # update Doom + all packages
```

There's no test suite — verify changes by reloading (`M-x doom/reload`) or restarting Emacs.
See [`AGENTS.md`](AGENTS.md) for the deeper architecture notes and conventions.

## Troubleshooting

**Emacs is sluggish / beachballs, but `emacs -Q` is fast.**
You're missing the nerd-icons font. `doom-modeline`, treemacs and the dashboard render icon glyphs
on every redraw; with no font installed, macOS searches every font for each glyph and the UI crawls.
Fix: `brew install --cask font-symbols-only-nerd-font`, then **fully quit and reopen Emacs** (fonts
load at startup, not on `doom/reload`). The config also sets `inhibit-compacting-font-caches t`.

**⌘ shortcuts don't behave like macOS / navigation is on the wrong key.**
This config maps **⌘ → Meta** via the `ns-*` variables (emacs-plus is an NS build; the `mac-*`
variables from the emacs-mac port are ignored). In-Emacs `⌘C/⌘V/⌘Q` are therefore *not* macOS
copy/paste/quit. To change the mapping, edit the `ns-command-modifier` block at the top of
`config.el`. To get accented characters back on `⌥`, set `ns-option-modifier` to `'none`.

## Roadmap

Built in phases; cherry-picked as needed.

- [x] **Phase 1** — ergoemacs (non-modal) editing + treemacs tree + macOS modifiers + perf fixes
- [ ] Fonts & theme (incl. location-aware day/night switching)
- [ ] LSP + language servers (Rust, etc.), with GUI `PATH` wiring for emacs-plus
- [ ] Org-mode + completion (corfu/orderless) tuning
