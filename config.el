;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!

;; macOS modifier keys - MUST come FIRST
(setq mac-command-modifier 'meta)     ; ⌘ as Meta (ergonomic thumb position)
(setq mac-option-modifier 'super)     ; ⌥ as Super
(setq mac-control-modifier 'control)  ; ^ stays Control
(setq mac-right-command-modifier 'meta)
(setq mac-right-option-modifier 'super)
(setq mac-function-modifier 'hyper)   ; Fn as Hyper (if needed)

;; Load ergoemacs with Mac-friendly settings
(setq ergoemacs-theme nil)
(setq ergoemacs-keyboard-layout "us")
(require 'ergoemacs-mode)
(ergoemacs-mode 1)

;; Remap Cmd+Space from Spotlight conflict
(define-key ergoemacs-user-keymap (kbd "s-SPC") 'set-mark-command)

;; Change Doom leader to avoid conflicts
(setq doom-leader-key "C-c SPC"      ; Ctrl+c Space
      doom-leader-alt-key "C-c SPC"
      doom-localleader-key "C-c m"
      doom-localleader-alt-key "C-c m")

;; Treemacs integration - toggle in/out of treemacs with Cmd+0
(defun my/treemacs-toggle-focus ()
  "Toggle focus between treemacs and other windows.
If currently in treemacs, switch to the most recently used non-treemacs window.
If not in treemacs, switch to treemacs window."
  (interactive)
  (if (treemacs-is-treemacs-window? (selected-window))
      ;; If in treemacs, go to last used window
      (other-window 1)
    ;; If not in treemacs, go to treemacs
    (treemacs-select-window)))

(after! treemacs
  ;; Cmd+0 to toggle in and out of treemacs
  (define-key ergoemacs-user-keymap (kbd "M-0") 'my/treemacs-toggle-focus))

(require 'cider)

(use-package! whisper
  :bind ("C-H-r" . whisper-run)
  :config
  (setq whisper-install-directory "/tmp/"
        whisper-model "small"
        whisper-language "en"
        whisper-translate nil))

(setq whisper--ffmpeg-input-device ":1")  ;; [AVFoundation indev @ 0x156e05720] [1] MacBook Pro Microphone

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

;; Circadian - automatic theme switching based on time of day
;; Set location to Jakarta, Indonesia
(setq calendar-latitude -6.2088)
(setq calendar-longitude 106.8456)

(use-package! circadian
  :config
  (setq circadian-themes '((:sunrise . doom-opera-light)
                           (:sunset  . doom-monokai-pro)))
  (circadian-setup))

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
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
