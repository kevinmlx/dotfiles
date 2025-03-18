;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
 (setq user-full-name "Kevin Julian Martinez Lizarazo"
       user-mail-address "kmartinezlizarazo@gmail.com")

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

(setq doom-font (font-spec :family "Iosevka" :size 32))
(setq doom-variable-pitch-font (font-spec :family "Iosevka" :size 32))
(setq doom-big-font (font-spec :family "Iosevka" :size 32)) ;; Para cuando uses zoom en Doom
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
;;(setq doom-theme 'doom-plain-dark)
(setq doom-theme 'tao-yin)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type 'relative)
(setq straight-repository-branch "develop")


;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/notas/")


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
;;
(defun org-summary-todo (n-done n-not-done)
  "Switch entry to DONE when all subentries are done, to TODO otherwise."
  (let (org-log-done org-todo-log-states)   ; turn off logging
    (org-todo (if (= n-not-done 0) "DONE" "TODO"))))

(add-hook 'org-after-todo-statistics-hook #'org-summary-todo)

(setq gc-cons-threshold (* 100 1024 1024)) ;; 100MB antes de GC
(setq gc-cons-percentage 0.1)
(add-hook 'focus-out-hook #'garbage-collect)
(setq recentf-auto-cleanup 'never)

;; Habilitar compilación nativa
(setq comp-deferred-compilation t)
(setq native-comp-speed 3) ; Ajusta el nivel de optimización (0-3)
(setq native-comp-async-report-warnings-errors nil)

(setq fast-but-imprecise-scrolling t)
(setq jit-lock-defer-time 0) ;; No retrasar la actualización del texto

(setq key-chord-two-keys-delay 0.05) ;; Mejora la respuesta de combinaciones de teclas
(setq redisplay-skip-fontification-on-input t) ;; No recalcular fuentes en cada input

;;; Compilation

(setq compilation-always-kill t
      compilation-ask-about-save nil
      compilation-scroll-output 'first-error)

;;; Misc

(setq whitespace-line-column nil)  ; whitespace-mode

;; I reduced the default value of 9 to simplify the font-lock keyword,
;; aiming to improve performance. This package helps differentiate
;; nested delimiter pairs, particularly in languages with heavy use of
;; parentheses.
(setq rainbow-delimiters-max-face-count 5)


;; Increase how much is read from processes in a single chunk
(setq read-process-output-max (* 512 1024))


;; Collects and displays all available documentation immediately, even if
;; multiple sources provide it. It concatenates the results.
(setq eldoc-documentation-strategy 'eldoc-documentation-compose-eagerly)

;; For some reason, `abbrev_defs` is located in ~/.emacs.d/abbrev_defs, even
;; when `user-emacs-directory` is modified. This ensures the abbrev file is
;; correctly located based on the updated `user-emacs-directory`.
(setq abbrev-file-name (expand-file-name "abbrev_defs" user-emacs-directory))

;; Resolve symlinks when opening files, so that any operations are conducted
;; from the file's true directory (like `find-file').
(setq find-file-visit-truename t
      vc-follow-symlinks t)

;;; recentf

;; `recentf' is an Emacs package that maintains a list of recently
;; accessed files, making it easier to reopen files you have worked on
;; recently.
(setq recentf-max-saved-items 300) ; default is 20
(setq recentf-max-menu-items 15)
(setq recentf-auto-cleanup (if (daemonp) 300 'never))
(defun minimal-emacs--cleanup-hook ()
  "Run `recentf-cleanup' if `recentf' is loaded and `recentf-mode' is enabled."
  (when (and (featurep 'recentf)
             recentf-mode
             (fboundp 'recentf-cleanup))
    (recentf-cleanup)))
(add-hook 'kill-emacs-hook #'minimal-emacs--cleanup-hook)

(setq scroll-conservatively 10)

;; Enables smooth scrolling by making Emacs scroll the window by 1 line whenever
;; the cursor moves off the visible screen.
(setq scroll-step 1)

;; Reduce cursor lag by :
;; 1. Prevent automatic adjustments to `window-vscroll' for long lines.
;; 2. Resolve the issue of random half-screen jumps during scrolling.
(setq auto-window-vscroll nil)

;; Number of lines of margin at the top and bottom of a window.
(setq scroll-margin 0)

;; Horizontal scrolling
(setq hscroll-margin 2
      hscroll-step 1)

;;; Flymake

(setq flymake-fringe-indicator-position 'left-fringe)
(setq flymake-show-diagnostics-at-end-of-line nil)

;; Suppress the display of Flymake error counters when there are no errors.
(setq flymake-suppress-zero-counters t)

;; Disable wrapping around when navigating Flymake errors.
(setq flymake-wrap-around nil)


;;; Eglot

(setq eglot-sync-connect 1
      eglot-autoshutdown t)

;; Activate Eglot in cross-referenced non-project files
(setq eglot-extend-to-xref t)

;; Eglot optimization
(setq jsonrpc-event-hook nil)
(setq eglot-events-buffer-size 0)
(setq eglot-report-progress nil)  ; Prevent Eglot minibuffer spam

;; Eglot optimization: Disable `eglot-events-buffer' to maintain consistent
;; performance in long-running Emacs sessions. By default, it retains 2,000,000
;; lines, and each new event triggers pretty-printing of the entire buffer,
;; leading to a gradual performance decline.
(setq eglot-events-buffer-config '(:size 0 :format full))

(set-frame-parameter (selected-frame) 'alpha '(80 .80))
(add-to-list 'default-frame-alist '(alpha . (80 . 80)))

;; -- Doom modeline --
;;(use-package doom-modeline :ensure t
;;  :custom
;;  (doom-modeline-icon t)
;;  (doom-modeline-height 0)
;;  (doom-modeline-bar-width 10)
;;
;;  :custom-face
;;  (doom-modeline-bar ((nil)))
;;
;;  :init
;;  (doom-modeline-mode t))
;;

(setq column-number-mode t)
(setq mode-line-percent-position nil)
(setq mode-line-modes
      (mapcar (lambda (elem)
            (pcase elem
              (`(:propertize (,_ minor-mode-alist . ,_)
               . ,_)
               "")
              (t elem)))
          mode-line-modes))

(defvar mode-line-modes
  (let ((recursive-edit-help-echo "Recursive edit, type C-M-c to get out"))
    (list (propertize "%[" 'help-echo recursive-edit-help-echo)
      "("
      `(:propertize ("" mode-name)
            help-echo "Major mode\n\
mouse-1: Display major mode menu\n\
mouse-2: Show help for major mode\n\
mouse-3: Toggle minor modes"
            mouse-face mode-line-highlight
            local-map ,mode-line-major-mode-keymap)
      '("" mode-line-process)
      `(:propertize ("" minor-mode-alist)
            mouse-face mode-line-highlight
            help-echo "Minor mode\n\
mouse-1: Display minor mode menu\n\
mouse-2: Show help for minor mode\n\
mouse-3: Toggle minor modes"
            local-map ,mode-line-minor-mode-keymap)
      (propertize "%n" 'help-echo "mouse-2: Remove narrowing from buffer"
              'mouse-face 'mode-line-highlight
              'local-map (make-mode-line-mouse-map
                  'mouse-2 #'mode-line-widen))
      ")"
      (propertize "%]" 'help-echo recursive-edit-help-echo)
      " "))
  "Mode line construct for displaying major and minor modes.")

(defun my-weebery-is-always-greater ()
  (let* ((banner '(
                   ""
                   ""
                   ""
                   ""
                   ""
                   ""
                   " "))
         (longest-line (apply #'max (mapcar #'length banner))))
    (put-text-property
     (point)
     (dolist (line banner (point))
       (insert (+doom-dashboard--center
                +doom-dashboard--width
                (concat line (make-string (max 0 (- longest-line (length line))) 32)))
               "\n"))
     'face 'doom-dashboard-banner)))

(setq +doom-dashboard-ascii-banner-fn #'my-weebery-is-always-greater)

(after! eglot
  (setq eglot-ignored-server-capabilities '(:inlayHintProvider)))
