;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;;; ===========================================================================
;;; macOS system settings (keep first)
;;; ===========================================================================
;; emacs-plus@30 is a pure NS build, so the EFFECTIVE modifier vars are `ns-*'
;; (the `mac-*' vars belong to the emacs-mac port and are ignored here, which is
;; why the old doom-macos `mac-command-modifier' settings silently did nothing).
;; Map ⌘ → Meta so ergoemacs navigation lands on ⌘+JKLI (ergonomic thumb), the
;; way I'm used to. ⌥ → Super (free for custom binds; note this means ⌥ no longer
;; types accented characters — set it to 'none if you want those back).
(when (eq system-type 'darwin)
  (setq ns-command-modifier 'meta          ; ⌘        → Meta  (ergoemacs nav: ⌘+JKLI)
        ns-right-command-modifier 'meta    ; right ⌘  → Meta
        ns-option-modifier 'super          ; ⌥        → Super
        ns-right-option-modifier 'super    ; right ⌥  → Super
        ns-control-modifier 'control       ; ⌃        → Control
        ns-function-modifier 'hyper))      ; fn       → Hyper

;; Performance: macOS re-compacts font caches aggressively, and icon-heavy UIs
;; (doom-modeline, treemacs, dashboard — all use nerd-icons) trigger it on every
;; redraw, causing sluggishness/beachballs. Disabling keeps the GUI snappy.
;; (Pairs with having the "Symbols Nerd Font" actually installed; without the
;; font, Emacs font-fallback searches every glyph and the UI crawls.)
(setq inhibit-compacting-font-caches t)


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


;;; ===========================================================================
;;; ergoemacs-mode — non-modal CUA-style keybindings (replaces evil)
;;; ===========================================================================
;; Loaded lazily via `use-package!'. Set layout/theme in :init (read before the
;; mode activates), then enable the global minor mode in :config.
(use-package! ergoemacs-mode
  :init
  (setq ergoemacs-theme nil                 ; nil = the standard ergoemacs theme
        ergoemacs-keyboard-layout "us")      ; QWERTY; e.g. "colemak" if you remap
  :config
  (ergoemacs-mode 1))


;;; ===========================================================================
;;; treemacs — file/project tree sidebar
;;; ===========================================================================
;; Provided by the `:ui treemacs' module. `treemacs' toggles the side window;
;; `treemacs-select-window' opens it and moves focus there.
(map! "<f8>"   #'treemacs
      "S-<f8>" #'treemacs-select-window)

(after! treemacs
  (setq treemacs-width 32
        treemacs-follow-after-init t
        ;; Keep the treemacs window in the normal `other-window' rotation, so it
        ;; is reachable with ⌘+S (ergoemacs-other-window → C-x o) like any window.
        treemacs-is-never-other-window nil)
  (treemacs-follow-mode 1)        ; highlight the current file in the tree
  (treemacs-filewatch-mode 1)     ; auto-refresh on filesystem changes
  (treemacs-git-mode 'deferred))  ; show git status (deferred = async, fast)


;;; ===========================================================================
;;; PATH — make GUI Emacs see the shell's PATH (nvm node, brew, etc.)
;;; ===========================================================================
;; macOS GUI Emacs (dock/Finder) does NOT inherit the login-shell PATH, so
;; binaries like `claude-agent-acp' (in the nvm node bin dir) go missing. Import
;; them once, only when running in a GUI; survives node version bumps.
(use-package! exec-path-from-shell
  :when (display-graphic-p)
  :config
  (exec-path-from-shell-initialize))


;;; ===========================================================================
;;; agent-shell — AI coding agents inside Emacs (Claude via ACP)
;;; ===========================================================================
;; Launch with `M-x agent-shell-anthropic-start-claude-code'. Requires the
;; `claude-agent-acp' binary on PATH (installed globally via npm; see PATH block
;; above). Auth :login t reuses an existing `claude` CLI login (no API key var).
(use-package! agent-shell
  :commands (agent-shell-anthropic-start-claude-code)
  :config
  ;; In :config (not :init) — `agent-shell-anthropic-make-authentication' only
  ;; exists once the package is loaded; runs before the start command fires.
  (setq agent-shell-anthropic-authentication
        (agent-shell-anthropic-make-authentication :login t)))


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `with-eval-after-load' block, otherwise Doom's defaults may override your
;; settings. E.g.
;;
;;   (with-eval-after-load 'PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look them up).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.
