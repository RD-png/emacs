(setq-default lexical-binding t)

;; GC Config
(setq gc-cons-threshold 16777216
      gc-cons-percentage 0.1)
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6)
(setq read-process-output-max 1048576)


(defun my/defer-garbage-collection ()
  (setq gc-cons-threshold most-positive-fixnum))

(defun my/restore-garbage-collection ()
  (run-at-time 1 nil (lambda () (setq gc-cons-threshold 16777216))))

(add-hook 'minibuffer-setup-hook 'my/defer-garbage-collection)
(add-hook 'minibuffer-exit-hook 'my/restore-garbage-collection)
(add-hook 'emacs-startup-hook #'emacs-init-time)

;; Native Comp
(when (and (fboundp 'native-comp-available-p)
           (native-comp-available-p))
  (progn
    (setq native-comp-async-report-warnings-errors nil)
    (setq comp-deferred-compilation t)
    (setq warning-minimum-level :error)
    (setq package-native-compile t)
    (add-to-list 'native-comp-eln-load-path (expand-file-name "eln-cache/" user-emacs-directory))))
(setq load-prefer-newer t)

;; Paths
(push "node_modules/" completion-ignored-extensions)
(push "__pycache__/" completion-ignored-extensions)
(add-to-list 'exec-path "~/.npm/bin")

;; Defaults
(setq undo-limit 80000000
      delete-old-versions t
      delete-by-moving-to-trash t
      enable-recursive-minibuffers t
      scroll-conservatively 100
      scroll-preserve-screen-position t
      system-uses-terminfo nil
      kill-do-not-save-duplicates t
      sentence-end-double-spacev nil
      make-backup-files nil
      backup-inhibited t
      auto-save-default nil
      create-lockfiles nil
      initial-scratch-message ""
      uniquify-buffer-name-style 'forward)
(when (window-system)
  (setq confirm-kill-emacs 'yes-or-no-p))

;; Interface
(global-font-lock-mode t)
(blink-cursor-mode -1)
(global-subword-mode 1)
(scroll-bar-mode -1)
(tool-bar-mode -1)
(tooltip-mode -1)
(set-fringe-mode 10)
(menu-bar-mode -1)
(column-number-mode)
(global-display-line-numbers-mode t)

(dolist (mode '(org-mode-hook
                term-mode-hook
                shell-mode-hook
                eshell-mode-hook
                dired-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

;; Alias
(defalias 'yes-or-no-p 'y-or-n-p)

;; Buffers / Frames
(set-frame-parameter (selected-frame) 'fullscreen 'maximized)
(add-to-list 'default-frame-alist '(fullscreen . maximized))
(setq ediff-split-window-function 'split-window-horizontally
      ediff-window-setup-function 'ediff-setup-windows-plain)

;; Straight
(setq ediff-split-window-function 'split-window-horizontally
      ediff-window-setup-function 'ediff-setup-windows-plain)

(setq straight-check-for-modifications '(check-on-save find-when-checking))
(setq package-enable-at-startup nil
      straight-use-package-by-default t
      straight-disable-native-compile nil
      straight-check-for-modifications nil
      straight-vc-git-default-clone-depth 1
      autoload-compute-prefixes nil)

(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))
(straight-use-package 'use-package)

(setq package-archives '(("elpa" . "https://elpa.gnu.org/packages/")
			                   ("melpa" . "https://melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")))
(require 'use-package)
(require 'straight-x)

;; Remove Messages
(advice-add 'display-startup-echo-area-message :override #'ignore)
(setq inhibit-message nil)

;; Font
(defvar default-font-size 140)
(defvar default-variable-font-size 140)
(set-face-attribute 'default nil :font "Fantasque Sans Mono" :foundry "PfEd" :slant 'normal :weight 'normal :width 'normal :height 140)
(set-face-attribute 'fixed-pitch nil :font "Fantasque Sans Mono" :height default-font-size)
(set-face-attribute 'variable-pitch nil :font "Fantasque Sans Mono" :height default-variable-font-size :weight 'regular)

;; Faces / Theme
;; (set-foreground-color "#c5c8c6")
;; (set-background-color "#1d1f21")

(setq custom-safe-themes t)
(custom-set-faces
 '(cursor ((t (:background "IndianRed3"))))
 '(mode-line ((t (:underline (:line-width 1)))))
 '(vertico-current ((t (:background "light blue")))))
(setq x-underline-at-descent-line t)

;;;; Packages
(require 'server nil t)
(use-package server
  :straight t
  :demand t
  :if window-system
  :init
  (when (not (server-running-p server-name))
    (server-start)))

(use-package dashboard
  :straight t
  :config
  (dashboard-setup-startup-hook)
  (setq dashboard-startup-banner 'official)
  (setq dashboard-items '((recents  . 10)
                          (bookmarks . 5)))
  (setq dashboard-banner-logo-title "")
  (setq dashboard-set-file-icons t))

(use-package tree-sitter-langs
  :straight t)

(use-package tree-sitter
  :straight t
  :config
  (global-tree-sitter-mode)
  (add-hook 'tree-sitter-after-on-hook #'tree-sitter-hl-mode))

(use-package popper
  :straight t
  :after project
  :bind (("C-c C-." . popper-toggle-latest)
         ("C-c M-." . popper-kill-latest-popup)
         ("C-c C-/" . popper-cycle)
         ("C-c C-;" . popper-toggle-type))
  :init
  (setq popper-window-height 10)
  (setq even-window-sizes nil)
  (setq display-buffer-base-action
        '(display-buffer-reuse-mode-window
          display-buffer-reuse-window
          display-buffer-same-window))
  (setq popper-reference-buffers
        (append
         '("\\*Messages\\*"
           "^\\*Warnings\\*$"
           "Output\\*$"
           "^\\*Backtrace\\*"
           "\\*Async Shell Command\\*"
           "\\*Completions\\*"
           "\\*devdocs\\*"
           "[Oo]utput\\*"
           "*helpful command: *.*$"
           "*helpful function: *.*$"
           "*helpful variable: *.*$"
           help-mode
           compilation-mode)))
  (popper-mode +1)
  (popper-echo-mode +1))

(use-package all-the-icons
  :straight t)

(use-package smart-mode-line
  :straight t
  :commands sml/setup
  :init
  (setq sml/no-confirm-load-theme t)
  (setq sml/theme nil)
  (sml/setup))

(defvar mode-line-cleaner-alist
  `((subword-mode . "")
    (yas-minor-mode . "")
    (smartparens-mode . "")
    (tree-sitter-mode . "")
    (eldoc-mode . "")
    (abbrev-mode . "")
    (ivy-mode . "")
    (counsel-mode . "")
    (wrap-region-mode . "")
    (rainbow-mode . "")
    (which-key-mode . "")
    (undo-tree-mode . "")
    (auto-revert-mode . "")
    (lisp-interaction-mode . "λ")
    (buffer-face-mode . "")
    (hi-lock-mode . "")
    (python-mode . "Py")
    (emacs-lisp-mode . "Eλ")
    (dot-mode . " .")
    (scheme-mode . " SCM")
    (matlab-mode . "M")
    (org-mode . "Org")
    (valign-mode . "")
    (eldoc-mode . "")
    (org-cdlatex-mode . "")
    (org-indent-mode . "")
    (org-roam-mode . "")
    (visual-line-mode . "")
    (all-the-icons-dired-mode . "")
    (latex-mode . "TeX")
    (outline-minor-mode . " [o]";; " ֍"
                        )
    (strokes-mode . "")
    (flymake-mode . "")
    (flyspell-mode . "")
    ))

(defun clean-mode-line ()
  (cl-loop for cleaner in mode-line-cleaner-alist
           do (let* ((mode (car cleaner))
                     (mode-str (cdr cleaner))
                     (old-mode-str (cdr (assq mode minor-mode-alist))))
                (when old-mode-str
                  (setcar old-mode-str mode-str))
                (when (eq mode major-mode)
                  (setq mode-name mode-str)))))

(add-hook 'after-change-major-mode-hook 'clean-mode-line)

(use-package vertico
  :straight (vertico :repo "minad/vertico"
                     :branch "main")
  :config
  (setq
   vertico-count 7
   vertico-cycle t
   vertico-resize nil)
  (setq read-file-name-completion-ignore-case t
        read-buffer-completion-ignore-case t
        completion-ignore-case t)
  :custom-face
  (vertico-current ((t (:background "light blue"))))
  :init
  (vertico-mode))

(use-package corfu
  :straight (corfu :repo "minad/corfu" :branch "main")
  :bind (:map corfu-map
              ("<tab>" . corfu-insert))
  :config
  (setq corfu-cycle t
        corfu-auto t
        corfu-count 10
        corfu-preview-current nil
        corfu-auto-prefix 3
        corfu-auto-delay 0.01
        corfu-quit-at-boundary t
        corfu-quit-no-match t)
  :init
  (corfu-global-mode))

(use-package orderless
  :straight t
  :init
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides '((file (styles partial-completion)))))

(use-package prescient
  :straight t
  :custom
  (prescient-history-length 1000)
  :init
  (setq prescient-persist-mode t))

(use-package emacs
  :straight (emacs :type built-in)
  :init
  (defun crm-indicator (args)
    (cons (concat "[CRM] " (car args)) (cdr args)))
  (advice-add #'completing-read-multiple :filter-args #'crm-indicator)

  (setq minibuffer-prompt-properties
        '(read-only t cursor-intangible t face minibuffer-prompt))
  (add-hook 'minibuffer-setup-hook #'cursor-intangible-mode)

  (setq enable-recursive-minibuffers t))

(use-package embark
  :straight t
  :after minibuffer
  :init
  (setq prefix-help-command #'embark-prefix-help-command)
  :config
  (define-key embark-file-map (kbd "o") (my/embark-ace-action find-file))
  (define-key embark-buffer-map   (kbd "o") (my/embark-ace-action switch-to-buffer))
  (define-key embark-bookmark-map (kbd "o") (my/embark-ace-action bookmark-jump))
  (define-key embark-file-map (kbd "S") 'sudo-find-file)
  :bind (:map minibuffer-local-map
              ("C-c C-o" . embark-export))
  :bind*
  ("C-o" . embark-act)
  ("C-h h" . embark-bindings))

(eval-when-compile
  (defmacro my/embark-ace-action (fn)
    `(defun ,(intern (concat "my/embark-ace-" (symbol-name fn))) ()
       (interactive)
       (with-demoted-errors "%s"
         (require 'ace-window)
         (let ((aw-dispatch-always t))
           (aw-switch-to-window (aw-select nil))
           (call-interactively (symbol-function ',fn)))))))

(defun sudo-find-file (file)
  "Open FILE as root."
  (interactive "FOpen file as root: ")
  (when (file-writable-p file)
    (user-error "File is user writeable, aborting sudo"))
  (find-file (if (file-remote-p file)
                 (concat "/" (file-remote-p file 'method) ":"
                         (file-remote-p file 'user) "@" (file-remote-p file 'host)
                         "|sudo:root@"
                         (file-remote-p file 'host) ":" (file-remote-p file 'localname))
               (concat "/sudo:root@localhost:" (file-truename file)))))

(use-package embark-consult
  :straight '(embark-consult :host github
                             :repo "oantolin/embark"
                             :files ("embark-consult.el"))
  :after (embark consult)
  :demand t
  :hook
  (embark-collect-mode . embark-consult-preview-minor-mode))

(use-package consult
  :straight t
  :after project
  :bind (("C-s" . consult-line)
         ("C-M-m" . consult-imenu)
         ("C-M-S-m" . consult-imenu-multi)
         ("C-M-s" . consult-multi-occur)
         ("C-M-l" . consult-outline)
         ("M-g M-g" . consult-goto-line)
         ("C-c f" . consult-flymake)
         ("C-x M-f" . consult-recent-file)
         ([remap popup-kill-ring] . consult-yank-from-kill-ring)
         :map minibuffer-local-map
         ("C-r" . consult-history))
  :config
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)
  (setq consult-project-root-function (lambda () "Return current project root"
                                        (project-root (project-current))))
  (setq consult-narrow-key "<")
  :custom
  (completion-in-region-function #'consult-completion-in-region)
  (consult-line-start-from-top nil)
  (consult-line-point-placement 'match-end)
  (fset 'multi-occur #'consult-multi-occur)
  :init
  (setq register-preview-delay 0
        register-preview-function #'consult-register-format)
  (advice-add #'completing-read-multiple :override #'consult-completing-read-multiple))

(use-package consult-dir
  :straight t
  :bind (("C-x C-d" . consult-dir)
         :map minibuffer-local-map
         ("C-x j" . consult-dir-jump-file)))

(use-package dogears
  :straight (dogears :host github :repo "alphapapa/dogears.el"
                     :files (:defaults (:exclude "helm-dogears.el")))
  :config
  (setq dogears-hooks '(imenu-after-jump-hook consult-after-jump-hook 'xref-after-jump-hook 'dumb-jump-after-jump-hook))
  :bind (:map global-map
              ("C-c h g" . dogears-go)
              ("C-c h r" . dogears-remember)
              ("C-c h f" . dogears-forward)
              ("C-c h b" . dogears-back))
  :init
  (dogears-mode))

(use-package affe
  :straight t
  :config
  (setq affe-regexp-function #'orderless-pattern-compiler
        affe-highlight-function #'orderless--highlight))

(use-package marginalia
  :straight t
  :after vertico
  :init
  (marginalia-mode)
  :custom
  (marginalia-annotators '(marginalia-annotators-heavy marginalia-annotators-light nil))
  :config
  (add-hook 'marginalia-mode-hook #'all-the-icons-completion-marginalia-setup)
  (setq marginalia-command-categories
        (append '((persp-switch-to-buffer . buffer))
                marginalia-command-categories)))

(use-package cape
  :straight t
  :init
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-tex)
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-keyword))

(use-package lsp-mode
  :straight t
  :custom
  (lsp-completion-provider :none)
  :preface
  (defun my/lsp-format-buffer ()
    (interactive)
    (lsp-format-buffer)
    (delete-trailing-whitespace))
  :bind (:map lsp-mode-map
              ("C-c o d" . lsp-describe-thing-at-point)
              ("C-c o f" . my/lsp-format-buffer)
              ("C-c o a" . lsp-execute-code-action)
              ("C-c o r" . lsp-find-references)
              ("C-c o g" . lsp-find-definition))
  :custom
  (lsp-modeline-diagnostics-enable nil)
  (lsp-enable-folding nil)
  (lsp-enable-text-document-color nil)
  (lsp-enable-on-type-formatting nil)
  (lsp-signature-render-documentation nil)
  (lsp-completion-show-detail nil)
  (lsp-eldoc-render-all nil)
  (lsp-enable-snippet t)
  (lsp-eldoc-enable-hover nil)
  (lsp-document-sync-method nil)
  (lsp-signature-auto-activate nil)
  (lsp-print-performance t)
  (lsp-before-save-edits nil)
  (lsp-headerline-breadcrumb-enable nil)
  (lsp-signature-render-documentation t)
  :init
  (defun my/orderless-dispatch-flex-first (_pattern index _total)
    (and (eq index 0) 'orderless-flex))

  (defun my/lsp-mode-setup-completion ()
    (setf (alist-get 'styles (alist-get 'lsp-capf completion-category-defaults))
          '(orderless)))

  (add-hook 'orderless-style-dispatchers #'my/orderless-dispatch-flex-first nil 'local)

  (setq-local completion-at-point-functions (list (cape-capf-buster #'lsp-completion-at-point)))

  :hook
  (lsp-completion-mode . my/lsp-mode-setup-completion))

(use-package wgrep
  :defer 2
  :straight t
  :config
  (defun custom-wgrep-apply-save ()
    "Apply the edits and save the buffers"
    (interactive)
    (wgrep-finish-edit)
    (wgrep-save-all-buffers))

  (setq wgrep-change-readonly-file t)
  :bind (:map wgrep-mode-map
              ("C-x C-s" . custom-wgrep-apply-save)))

(use-package php-mode
  :straight t
  :mode "\\.php\\'"
  :hook (php-mode . lsp-deferred))

(use-package helpful
  :straight t
  :bind
  ([remap describe-function] . helpful-function)
  ([remap describe-symbol] . helpful-symbol)
  ([remap describe-variable] . helpful-variable)
  ([remap describe-command] . helpful-command)
  ([remap describe-key] . helpful-key))

(use-package info-colors
  :straight t
  :init
  (add-hook 'Info-selection-hook 'info-colors-fontify-node))

(use-package ace-window
  :straight t
  :config
  (setq aw-dispatch-always t)
  (setq aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l))
  :bind (("C-x o" . ace-window)
         ("M-o" . other-window)
         ("C-x 0" . ace-delete-window)
         ("C-x O" . ace-swap-window)
         ("C-x M-0" . delete-other-windows)))

(defun split-and-follow-horizontally ()
  (interactive)
  (split-window-below)
  (balance-windows)
  (other-window 1))
(global-set-key (kbd "C-x 2") 'split-and-follow-horizontally)

(defun split-and-follow-vertically ()
  (interactive)
  (split-window-right)
  (balance-windows)
  (other-window 1))
(global-set-key (kbd "C-x 3") 'split-and-follow-vertically)

(use-package perspective
  :straight t
  :bind (("C-c C-'" . persp-next)
         ("C-x M-b" . persp-switch))
  :custom
  (persp-initial-frame-name "Win1")
  :config
  (setq persp-modestring-dividers '("|" "|" "|"))
  (unless (equal persp-mode t)
    (persp-mode)))

;; Yoinked from karthinks blog
(use-package avy
  :straight t
  :config
  (setq avy-timeout-seconds 0.35)
  (setq avy-keys '(?a ?s ?d ?f ?g ?h ?j ?l ?\;
                      ?v ?b ?n ?. ?, ?/ ?u ?p ?e
                      ?c ?q ?2 ?3 ?'))
  (setq avy-dispatch-alist '((?k . avy-action-kill-move)
                             (?K . avy-action-kill-stay)
                             (?x . avy-action-copy-whole-line)
                             (?X . avy-action-kill-whole-line)
                             (?t . avy-action-teleport)

                             (?m . avy-action-mark)
                             (?M . avy-action-mark-to-char)
                             (?w . avy-action-copy)
                             (?y . avy-action-yank)
                             (?Y . avy-action-yank-line)
                             (?i . avy-action-ispell)
                             (?z . avy-action-zap-to-char)
                             (?o . avy-action-embark)))
  :custom
  (avy-single-candidate-jump nil)
  :bind*
  ("C-j" . avy-goto-char-timer)
  ("M-m" . avy-goto-word-0))

(defun avy-action-kill-whole-line (pt)
  (save-excursion
    (goto-char pt)
    (kill-whole-line))
  (select-window
   (cdr
    (ring-ref avy-ring 0)))
  t)

(defun avy-action-copy-whole-line (pt)
  (save-excursion
    (goto-char pt)
    (cl-destructuring-bind (start . end)
        (bounds-of-thing-at-point 'line)
      (copy-region-as-kill start end)))
  (select-window
   (cdr
    (ring-ref avy-ring 0)))
  t)

(defun avy-action-yank-whole-line (pt)
  (avy-action-copy-whole-line pt)
  (save-excursion (yank))
  t)

(defun avy-action-teleport-whole-line (pt)
  (avy-action-kill-whole-line pt)
  (save-excursion (yank)) t)

(defun avy-action-mark-to-char (pt)
  (activate-mark)
  (goto-char pt))

(defun avy-action-embark (pt)
  (save-excursion
    (goto-char pt)
    (embark-act))
  (select-window
   (cdr (ring-ref avy-ring 0)))
  t)

(use-package embrace
  :straight t
  :bind
  ("M-s a" . embrace-add)
  ("M-s c" . embrace-change)
  ("M-s d" . embrace-delete))

(use-package expand-region
  :straight t
  :bind (("C-}" . er/expand-region)
         ("C-M-}" . er/mark-outside-pairs)
         ("C-{" . er/mark-inside-pairs)))

(use-package no-littering
  :straight t)

(use-package devdocs
  :defer 2
  :straight t
  :config
  (defun my/devdocs-lookup ()
    (interactive)
    (devdocs-lookup nil (thing-at-point 'word 'no-properties)))
  :bind ("C-c o D" . my/devdocs-lookup))

(add-hook 'web-mode-hook
          (lambda () (setq-local devdocs-current-docs '("vue~3"))))
(add-hook 'python-mode-hook
          (lambda () (setq-local devdocs-current-docs '("django_rest_framework" "django~3.2"))))
(add-hook 'php-mode-hook
          (lambda () (setq-local devdocs-current-docs '("laravel~8"))))

(defun org-font-setup ()
  ;; Replace list hyphen with dot
  (font-lock-add-keywords 'org-mode
                          '(("^ *\\([-]\\) "
                             (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))


  (defun org-archive-done-tasks ()
    (interactive)
    (org-map-entries
     (lambda ()
       (org-archive-subtree)
       (setq org-map-continue-from (org-element-property :begin (org-element-at-point))))
     "/DONE" 'tree))

  ;; Set faces for heading levels
  (dolist (face '((org-level-1 . 1.2)
                  (org-level-2 . 1.1)
                  (org-level-3 . 1.05)
                  (org-level-4 . 1.0)
                  (org-level-5 . 1.1)
                  (org-level-6 . 1.1)
                  (org-level-7 . 1.1)
                  (org-level-8 . 1.1)))
    (set-face-attribute (car face) nil :font "Fantasque Sans Mono" :weight 'regular :height (cdr face)))

  ;; Ensure that anything that should be fixed-pitch in Org files appears that way
  (set-face-attribute 'org-block nil    :foreground nil :inherit 'fixed-pitch)
  (set-face-attribute 'org-table nil    :inherit 'fixed-pitch)
  (set-face-attribute 'org-formula nil  :inherit 'fixed-pitch)
  (set-face-attribute 'org-code nil     :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-table nil    :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-verbatim nil :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-special-keyword nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-meta-line nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-checkbox nil  :inherit 'fixed-pitch)
  (set-face-attribute 'line-number nil :inherit 'fixed-pitch)
  (set-face-attribute 'line-number-current-line nil :inherit 'fixed-pitch))

(defun org-mode-setup ()
  (org-indent-mode)
  (variable-pitch-mode 1)
  (visual-line-mode 1))

(use-package org
  :straight t
  :commands (org-capture org-agenda)
  :hook (org-mode . org-mode-setup)
  :config
  (setq org-ellipsis " ▾")
  (setq org-agenda-start-with-log-mode t)
  (setq org-log-done 'time)
  (setq org-log-into-drawer t)
  (setq org-format-latex-options (plist-put org-format-latex-options :scale 1.75))

  (setq org-agenda-files (directory-files-recursively "~/.config/emacs/org/" "\\.org$"))

  (require 'org-habit)
  (add-to-list 'org-modules 'org-habit)
  (setq org-habit-graph-column 60)

  (setq org-todo-keywords
        '((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d!)")
          (sequence "BACKLOG(b)" "PLAN(p)" "READY(r)" "ACTIVE(a)" "REVIEW(v)" "WAIT(w@/!)" "HOLD(h)" "|" "COMPLETED(c)" "CANC(k@)")))

  (setq org-refile-targets
        '(("Archive.org" :maxlevel . 1)
          ("Tasks.org" :maxlevel . 1)))

  ;; Save Org buffers after refiling!
  (advice-add 'org-refile :after 'org-save-all-org-buffers)

  (setq org-tag-alist
        '((:startgroup)
                                        ; Put mutually exclusive tags here
          (:endgroup)
          ("@errand" . ?E)
          ("@home" . ?H)
          ("@work" . ?W)
          ("agenda" . ?a)
          ("planning" . ?p)
          ("publish" . ?P)
          ("batch" . ?b)
          ("note" . ?n)
          ("idea" . ?i)))

  ;; Configure custom agenda views
  (setq org-agenda-custom-commands
        '(("d" "Dashboard"
           ((agenda "" ((org-deadline-warning-days 7)))
            (todo "NEXT"
                  ((org-agenda-overriding-header "Next Tasks")))
            (tags-todo "agenda/ACTIVE" ((org-agenda-overriding-header "Active Projects")))))

          ("n" "Next Tasks"
           ((todo "NEXT"
                  ((org-agenda-overriding-header "Next Tasks")))))

          ("W" "Work Tasks" tags-todo "+work-email")

          ;; Low-effort next actions
          ("e" tags-todo "+TODO=\"NEXT\"+Effort<15&+Effort>0"
           ((org-agenda-overriding-header "Low Effort Tasks")
            (org-agenda-max-todos 20)
            (org-agenda-files org-agenda-files)))

          ("w" "Workflow Status"
           ((todo "WAIT"
                  ((org-agenda-overriding-header "Waiting on External")
                   (org-agenda-files org-agenda-files)))
            (todo "REVIEW"
                  ((org-agenda-overriding-header "In Review")
                   (org-agenda-files org-agenda-files)))
            (todo "PLAN"
                  ((org-agenda-overriding-header "In Planning")
                   (org-agenda-todo-list-sublevels nil)
                   (org-agenda-files org-agenda-files)))
            (todo "BACKLOG"
                  ((org-agenda-overriding-header "Project Backlog")
                   (org-agenda-todo-list-sublevels nil)
                   (org-agenda-files org-agenda-files)))
            (todo "READY"
                  ((org-agenda-overriding-header "Ready for Work")
                   (org-agenda-files org-agenda-files)))
            (todo "ACTIVE"
                  ((org-agenda-overriding-header "Active Projects")
                   (org-agenda-files org-agenda-files)))
            (todo "COMPLETED"
                  ((org-agenda-overriding-header "Completed Projects")
                   (org-agenda-files org-agenda-files)))
            (todo "CANC"
                  ((org-agenda-overriding-header "Cancelled Projects")
                   (org-agenda-files org-agenda-files)))))))

  (setq org-capture-templates
        `(("t" "Tasks / Projects")
          ("tt" "Task" entry (file+olp "~/.config/emacs/OrgFiles/Tasks.org" "Inbox")
           "* TODO %?\n  %U\n  %a\n  %i" :empty-lines 1)

          ("j" "Journal Entries")
          ("jj" "Journal" entry
           (file+olp+datetree "~/.config/emacs/org/Journal.org")
           "\n* %<%I:%M %p> - Journal :journal:\n\n%?\n\n"
           :clock-in :clock-resume
           :empty-lines 1)
          ("jm" "Meeting" entry
           (file+olp+datetree "~/.config/emacs/org/Journal.org")
           "* %<%I:%M %p> - %a :meetings:\n\n%?\n\n"
           :clock-in :clock-resume
           :empty-lines 1)

          ("w" "Workflows")
          ("we" "Checking Email" entry (file+olp+datetree "~/.config/emacs/org/Journal.org")
           "* Checking Email :email:\n\n%?" :clock-in :clock-resume :empty-lines 1)))

  (define-key global-map (kbd "C-c j")
              (lambda () (interactive) (org-capture nil "jj")))

  (org-font-setup))

(use-package org-make-toc
  :defer 5
  :straight t
  :after org)

(use-package org-superstar
  :straight (org-superstar-mode :host github :repo "integral-dw/org-superstar-mode")
  :hook (org-mode . org-superstar-mode)
  :custom
  (org-superstar-todo-bullet-alist
   '(("TODO" . 9744)
     ("DONE" . 9745)))
  (org-superstar-cycle-headline-bullets t)
  (org-hide-leading-stars t)
  (org-superstar-special-todo-items t))

(defun org-mode-visual-fill ()
  (setq visual-fill-column-width 100
        visual-fill-column-center-text t)
  (visual-fill-column-mode 1))

(use-package visual-fill-column
  :straight t
  :hook (org-mode . org-mode-visual-fill))

(with-eval-after-load 'org
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t)
     (python . t)))

  (push '("conf-unix" . conf-unix) org-src-lang-modes))

(with-eval-after-load 'org
  ;; This is needed as of Org 9.2
  (require 'org-tempo)

  (add-to-list 'org-structure-template-alist '("sh" . "src shell"))
  (add-to-list 'org-structure-template-alist '("el" . "src emacs-lisp"))
  (add-to-list 'org-structure-template-alist '("py" . "src python")))

(use-package org-roam
  :defer 3
  :straight t
  :init
  (setq org-roam-v2-ack t)
  :custom
  (org-roam-directory "~/.config/emacs/org/Notes/Roam")
  (org-roam-completion-everywhere t)
  (org-roam-dailies-capture-templates
   '(("d" "default" entry "* %<%I:%M %p>: %?"
      :if-new (file+head "%<%Y-%m-%d>.org" "#+title: %<%Y-%m-%d>\n"))))
  :bind (("C-c n l" . org-roam-buffer-toggle)
         ("C-c n f" . org-roam-node-find)
         ("C-c n i" . org-roam-node-insert)
         ("C-c n t" . org-roam-dailies-capture-today)
         ("C-c n r" . org-roam-dailies-capture-tomorrow)
         ("C-c n y" . org-roam-dailies-capture-yesterday)
         ("C-c n g t" . org-roam-dailies-goto-today)
         ("C-c n g r" . org-roam-dailies-goto-tomorrow)
         ("C-c n g y" . org-roam-dailies-goto-yesterday))
  :bind-keymap
  ("C-c n d" . org-roam-dailies-map)
  :config
  (require 'org-roam-dailies) ;; Ensure the keymap is available
  (org-roam-db-autosync-mode))

(defun my/map-line-to-status-char (line)
  (cond ((string-match "^?\\? " line) "?")))

(defun my/get-prompt-path ()
  (let* ((current-path (eshell/pwd))
         (git-output (shell-command-to-string "git rev-parse --show-toplevel"))
         (has-path (not (string-match "^fatal" git-output))))
    (if (not has-path)
        (abbreviate-file-name current-path)
      (string-remove-prefix (file-name-directory git-output) current-path))))

(defun my/pwd-shorten-dirs (pwd)
  (let ((p-lst (split-string pwd "/")))
    (if (> (length p-lst) 2)
        (concat
         (mapconcat (lambda (elm) (if (zerop (length elm)) ""
                                    (substring elm 0 0)))
                    (butlast p-lst 2)
                    "/")
         "/"
         (mapconcat (lambda (elm) elm)
                    (last p-lst 2)
                    "/"))
      pwd)))

(defun my/eshell-prompt ()
  (concat
   "\n"
   (propertize (user-login-name) 'face `(:foreground "#8f0075"))
   (propertize " @ " 'face `(:foreground "#2544bb"))
   (propertize (my/pwd-shorten-dirs (my/get-prompt-path)) 'face `(:foreground "#145c33"))
   (propertize " #" 'face `(:foreground "#70480f"))
   (propertize " " 'face `(:foreground "white"))))



(defun eshell-configure ()
  (use-package xterm-color
    :straight t)

  (push 'eshell-tramp eshell-modules-list)
  (push 'xterm-color-filter eshell-preoutput-filter-functions)
  (delq 'eshell-handle-ansi-color eshell-output-filter-functions)

  ;; Save command history when commands are entered
  (add-hook 'eshell-pre-command-hook 'eshell-save-some-history)

  (add-hook 'eshell-before-prompt-hook
            (lambda ()
              (setq xterm-color-preserve-properties t)))

  ;; Truncate buffer for performance
  (add-to-list 'eshell-output-filter-functions 'eshell-truncate-buffer)

  (add-hook 'eshell-pre-command-hook
            (lambda () (setenv "TERM" "xterm-256color")))
  (add-hook 'eshell-post-command-hook
            (lambda () (setenv "TERM" "dumb")))

  (define-key eshell-mode-map (kbd "<tab>") 'capf-autosuggest-forward-word)
  (define-key eshell-mode-map (kbd "C-r") 'consult-history)
  (define-key eshell-mode-map (kbd "C-a") 'eshell-bol)
  (define-key eshell-mode-map (kbd "C-l") (lambda () (interactive) (eshell/clear 1) (eshell-send-input)))
  (eshell-hist-initialize)
  (setenv "PAGER" "cat")

  (setq eshell-prompt-function 'my/eshell-prompt
        eshell-prompt-regexp "[a-zA-z]+ @ [^#$\n]+ # "
        eshell-history-size 10000
        eshell-buffer-maximum-lines 10000
        eshell-hist-ignoredups t
        eshell-highlight-prompt t
        eshell-scroll-to-bottom-on-input t
        eshell-prefer-lisp-functions nil
        comint-prompt-read-only t)
  (setq eshell-buffer-name (concat (persp-current-name) " *eshell*"))
  (generate-new-buffer eshell-buffer-name))

(use-package eshell
  :straight (eshell :type built-in)
  :hook (eshell-first-time-mode . eshell-configure)
  :config

  (with-eval-after-load 'esh-opt
    (setq eshell-destroy-buffer-when-process-dies t)
    (setq eshell-visual-commands '("htop" "zsh" "vim"))))

(use-package capf-autosuggest
  :straight (capf-autosuggest :host github :repo "emacs-straight/capf-autosuggest")
  :hook ((eshell-mode comint-mode) . capf-autosuggest-mode))

(use-package eshell-syntax-highlighting
  :straight t
  :hook (eshell-mode . eshell-syntax-highlighting-mode))

(use-package tramp
  :defer 5
  :custom
  (tramp-default-method "ssh")
  :config
  (put 'temporary-file-directory 'standard-value '("/tmp"))
  (setq tramp-auto-save-directory "~/.cache/emacs/backups"
        tramp-persistency-file-name "~/.config/emacs/data/tramp"))

(use-package direnv
  :defer 2
  :straight t
  :config
  (advice-add 'lsp :before (lambda (&optional n) (direnv-update-environment)))
  (direnv-mode))

;; (use-package undo-tree
;;   :straight t
;;   :defer)

(use-package dumb-jump
  :straight t
  :init
  (add-hook 'xref-backend-functions #'dumb-jump-xref-activate))

(use-package eldoc
  :straight (eldoc :type built-in)
  :custom
  (eldoc-idle-delay 0)
  (eldoc-echo-area-prefer-doc-buffer t)
  (eldoc-echo-area-use-multiline-p nil)
  (eldoc-echo-area-display-truncation-message nil))

(use-package php-mode
  :straight t
  :mode "\\.php\\'"
  :hook (php-mode . lsp-deferred))

(use-package typescript-mode
  :straight t
  :mode
  ("\\.ts\\'"
   "\\.Js\\'")
  :hook (typescript-mode . lsp-deferred)
  :config
  (setq typescript-indent-level 2))

(use-package pip-requirements
  :straight t
  :config
  (add-hook 'pip-requirements-mode-hook #'pip-requirements-auto-complete-setup))

(use-package python-mode
  :straight t
  :hook (python-mode . lsp-deferred)
  :bind (:map python-mode-map
              ([remap lsp-format-buffer] . python-black-buffer))
  :config
  (setq python-shell-interpreter "python3"))

;; Elpy rebinds delete for some reason
(add-hook 'python-mode-hook
          (lambda()
            (local-unset-key (kbd "DEL"))))

(use-package pyimport
  :straight t
  :after python-mode)


(use-package pyvenv
  :straight t
  :after python
  :config
  (setq pyvenv-menu t)
  )

(use-package python-black
  :straight t
  :after python)

(use-package nix-mode
  :straight t
  :mode "\\.nix\\'"
  :hook (nix-mode . lsp-deferred))

(use-package web-mode
  :straight t
  :mode ("\\.vue\\'")
  :hook (web-mode . lsp-deferred)
  :config
  (setq web-mode-code-indent-offset 2)
  (setq web-mode-markup-indent-offset 2)
  (setq web-mode-css-indent-offset 2)
  (setq web-mode-style-padding 0)
  (setq web-mode-script-padding 0))

(use-package css-mode
  :straight t
  :mode ("\\.css\\'"))

(use-package haskell-mode
  :straight t
  :mode ("\\.hs\\'")
  :hook (haskell-mode . lsp-deferred)
  :config
  (setq haskell-process-type 'cabal-repl))

;; finds executable and some additional compiler settings
(use-package lsp-haskell
  :straight t
  :after lsp-mode
  :hook (haskell-mode . lsp-deferred)
  :custom
  (lsp-haskell-server-path "haskell-language-server"))

(add-hook 'haskell-mode-hook 'interactive-haskell-mode)

(use-package emacs-lisp-mode
  :straight (emacs-lisp-mode :type built-in)
  :hook (lisp-mode . emacs-lisp-mode))

(use-package scheme-mode
  :straight (scheme-mode :type built-in)
  :mode ("\\.sld\\'"))

(use-package racket-mode
  :straight t
  :mode ("\\.rkt\\'"))

(use-package rustic
  :straight t
  :mode ("\\.rs$" . rustic-mode)
  :config
  (setq rustic-lsp-server 'rls)
  (setq rustic-lsp-server 'rustfmt)
  (setq rustic-lsp-client 'lsp-mode)
  (setq rustic-indent-method-chain t))

(add-hook 'rustic-mode-hook #'rustic-lsp-mode-setup)

(use-package latex
  :defer 5
  :straight (latex :type built-in)
  :after tex
  :mode ("\\.tex\\'" . LaTeX-mode))

;; (use-package auctex
;;   :straight (auctex :type built-in))

(use-package cdlatex
  :straight (cdlatex :type built-in)
  :defer 5
  :after latex
  :hook (LaTeX-mode . turn-on-cdlatex))

(use-package project
  :straight (project :type built-in)
  :init
  (global-set-key (kbd "C-c p") project-prefix-map)
  (cl-defgeneric project-root (project) (car project))
  (setq project-switch-commands
        '((?f "Find file" project-find-file)
          (?g "Find regexp" project-find-regexp)
          (?d "Dired" project-dired)
          (?b "Buffer" project-switch-to-buffer)
          (?r "Query replace" project-query-replace-regexp)
          (?v "VC-Dir" project-vc-dir)
          (?k "Kill buffers" project-kill-buffers)
          (?! "Shell command" project-shell-command)
          (?e "Eshell" consult-recent-file)))
  :bind*
  ("C-c p s r" . consult-ripgrep))

(use-package rg
  :straight t)

(use-package magit
  :straight t
  :commands (magit-status magit-get-current-branch)
  :bind ("C-c g" . magit-status)
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

(use-package forge
  :straight t
  :after magit)

(use-package evil-nerd-commenter
  :straight t
  :bind ("C-;" . evilnc-comment-or-uncomment-lines))

(use-package rainbow-delimiters
  :straight t
  :hook (prog-mode . rainbow-delimiters-mode))

(show-paren-mode 1)

;; Colors for # colors
(use-package rainbow-mode
  :straight t
  :defer t
  :hook (org-mode
         emacs-lisp-mode
         typescript-mode))

;; (custom-set-faces
;;  '(rainbow-delimiters-depth-1-face ((t (:foreground "#f66d9b"))))
;;  '(rainbow-delimiters-depth-2-face ((t (:foreground "#66c1b7"))))
;;  '(rainbow-delimiters-depth-3-face ((t (:foreground "#6574cd"))))
;;  '(rainbow-delimiters-depth-4-face ((t (:foreground "#fa7b62"))))
;;  '(rainbow-delimiters-depth-5-face ((t (:foreground "#fdb900"))))
;;  '(rainbow-delimiters-depth-6-face ((t (:foreground "#ff70bf"))))
;;  '(rainbow-delimiters-depth-7-face ((t (:foreground "#fdae42"))))
;;  '(rainbow-delimiters-depth-8-face ((t (:foreground "#8f87de")))))

(use-package yasnippet
  :straight t
  :defer 2
  :init
  (yas-global-mode 1)
  :config
  (defun do-yas-expand ()
    (let ((yas/fallback-behavior 'return-nil))
      (yas/expand)))

  (defun tab-complete-or-next-field ()
    (interactive)
    (if (or (not yas/minor-mode)
            (null (do-yas-expand)))
        (if corfu--candidates
            (progn
              (corfu-insert)
              (yas-next-field))  
          (yas-next-field))))
  (yas-reload-all)
  :bind (:map yas-keymap
              ("<tab>" . tab-complete-or-next-field)))

(use-package flymake
  :straight (flymake :type built-in)
  :init
  (setq-default flymake-diagnostic-functions nil)
  (with-eval-after-load 'flymake-proc
    (remove-hook 'flymake-diagnostic-functions 'flymake-proc-legacy-flymake))
  :config
  (setq flymake-start-on-flymake-mode t
        flymake-start-on-save-buffer t))

(use-package flyspell
  :straight (flyspell :type built-in)
  :hook (text-mode . flyspell-mode))

(use-package smartparens
  :straight t
  :hook (prog-mode . smartparens-mode)
  (text-mode . smartparens-mode)
  :config
  (sp-local-pair '(emacs-lisp-mode scheme-mode) "'" "'" :actions nil))

(use-package paren
  :straight t
  :config
  (set-face-attribute 'show-paren-match-expression nil :background "#363e4a")
  (show-paren-mode 1))

(use-package dired
  :straight (dired :type built-in)
  :hook ((dired-mode . hl-line-mode)
         (dired-mode . toggle-truncate-lines))
  :commands (dired dired-jump)
  :bind (("C-x C-j" . dired-jump)
         :map dired-mode-map
         ("q" . dired-up-directory))
  :custom
  ((dired-listing-switches "-AGFhlv --group-directories-first")
   (dired-recursive-copies t))
  :config
  (setf dired-kill-when-opening-new-dired-buffer t)
  (setq dired-recursive-copies 'always
        dired-recursive-deletes 'always
        delete-by-moving-to-trash t))

(use-package all-the-icons-dired
  :straight t
  :hook (dired-mode . all-the-icons-dired-mode))

(use-package diredfl
  :straight t
  :hook (dired-mode . diredfl-mode)
  :init
  (setq diredfl-ignore-compressed-flag nil)
  (diredfl-global-mode 1))

(setq-default tab-width 2
              indent-tabs-mode nil)

(use-package multiple-cursors
  :straight t
  :bind (("C-S-c C-S-c" . mc/edit-lines)
         ("C-<" . mc/mark-next-like-this)
         ("C->" . mc/mark-previous-like-this)
         ("C-c m a" . mc/mark-all-like-this)))

(defun copy-word ()
  (interactive)
  (save-excursion
    (forward-char 1)
    (backward-word)
    (kill-word 1)
    (yank)))

(defun my/beginning-of-line ()
  (interactive)
	(if (= (point) (progn (back-to-indentation) (point)))
			(beginning-of-line)))

(defun shift-text (distance)
  (if (use-region-p)
      (let ((mark (mark)))
        (save-excursion
          (indent-rigidly (region-beginning)
                          (region-end)
                          distance)
          (push-mark mark t t)
          (setq deactivate-mark nil)))
    (indent-rigidly (line-beginning-position)
                    (line-end-position)
                    distance)))

(defun shift-right (count)
  (interactive "p")
  (shift-text count))

(defun shift-left (count)
  (interactive "p")
  (shift-text (- count)))

;; Smarter C-Backspace control
(defun my/backward-kill-word ()
  (interactive)
  (let* ((cp (point))
         (backword)
         (end)
         (space-pos)
         (backword-char (if (bobp)
                            ""
                          (buffer-substring cp (- cp 1)))))
    (if (equal (length backword-char) (string-width backword-char))
        (progn
          (save-excursion
            (setq backword (buffer-substring (point) (progn (forward-word -1) (point)))))
          (save-excursion
            (message (thing-at-point 'no-properties))
            (when (and backword
                       (string-match-p " " backword))
              (setq space-pos (ignore-errors (search-backward " ")))))
          (save-excursion
            (let* ((pos (ignore-errors (search-backward-regexp "\n")))
                   (substr (when pos (buffer-substring pos cp))))
              (when (or (and substr (string-blank-p (string-trim substr)))
                        (string-match-p "\n" backword))
                (setq end pos))))
          (if end
              (kill-region cp end)
            (if space-pos
                (kill-region cp space-pos)
              (backward-kill-word 1))))
      (kill-region cp (- cp 1)))))

(defun my/kill-thing-at-point (thing)
  "Get the start and end bounds of a type of thing at point."
  (let ((bounds (bounds-of-thing-at-point thing)))
    (if bounds
        (kill-region (car bounds) (cdr bounds))
      (error "No %s at point" thing))))

;; General binds
(global-set-key (kbd "C-c w") #'copy-word)
(global-set-key (kbd "C-x C-b") #'switch-to-buffer)
(global-set-key (kbd "C-a") #'my/beginning-of-line)
(global-set-key (kbd "M-]") #'shift-right)
(global-set-key (kbd "M-[") #'shift-left)
(global-set-key (kbd "M-n") 'forward-paragraph)
(global-set-key (kbd "M-p") 'backward-paragraph)
(global-set-key (kbd "M-d") (lambda () (interactive) (my/kill-thing-at-point 'word)))
(global-set-key (kbd "C-M-<backspace>") #'backward-kill-sexp)
(global-set-key (kbd "C-M-<return>") #'eshell)
(global-set-key (kbd "C-S-k") #'kill-whole-line)
(global-set-key (kbd "C-x c f") (lambda () (interactive) (find-file "~/.config/emacs/init.el")))
(global-set-key (kbd "C-x c e")  #'dashboard-refresh-buffer)
(global-set-key (kbd "C-c o g")  #'xref-find-definitions)
(global-set-key (kbd "C-/")  #'undo-only)
(global-set-key (kbd "C-?")  #'undo-redo)
(global-set-key [remap eval-last-sexp] 'pp-eval-last-sexp)

(bind-key* "C-<backspace>" #'my/backward-kill-word)

;; unbind annoying keybinds
(global-unset-key  (kbd "C-x C-n"))
(global-unset-key  (kbd "M-`"))
(global-unset-key  (kbd "C-z"))
(global-unset-key  (kbd "C-x C-z"))

;; Advice
(defadvice kill-ring-save (before slick-copy activate compile)
  "When called interactively with no active region, copy a single line instead."
  (interactive
   (if mark-active (list (region-beginning) (region-end))
     (message "Single line killed")
     (list (line-beginning-position)
	   (line-beginning-position 2)))))

(defadvice kill-region (before slick-cut activate compile)
  "When called interactively with no active region, kill a single line instead."
  (interactive
   (if mark-active (list (region-beginning) (region-end))
     (list (line-beginning-position)
	   (line-beginning-position 2)))))

;; Open my default persp layouts
(defun my/persp-setup-hook ()
  (interactive)
  (persp-switch "Win2")
  (persp-switch "Win1"))

(add-hook 'after-init-hook #'my/persp-setup-hook)

;; Load theme
(use-package modus-themes
  :straight (modus-themes :host github :repo "protesilaos/modus-themes")
  :init
  (setq  modus-themes-intense-hl-line t
         modus-themes-org-blocks 'grayscale
         modus-themes-scale-headings t
         modus-themes-section-headings nil
         modus-themes-variable-pitch-headings nil
         modus-themes-intense-paren-match t
         modus-themes-diffs 'desaturated
         modus-themes-syntax '(alt-syntax-other green-strings yellow-comments)
         modus-themes-links '(faint neutral-underline)
         modus-themes-hl-line '(intense)
         modus-themes-prompts '(bold background)
         modus-themes-mode-line '(accented borderless)
         modus-themes-subtle-line-numbers t
         modus-themes-tabs-accented t
         modus-themes-inhibit-reload t
         modus-themes-paren-match '(underline)
         modus-themes-region '(no-extend accented bg-only)
         modus-themes-org-agenda
         '((header-block . (variable-pitch scale-title))
           (header-date . (bold-today grayscale scale))
           (scheduled . rainbow)
           (habit . traffic-light-deuteranopia))
         modus-themes-headings  '((t . (background overline rainbow)))
         modus-themes-variable-pitch-ui nil
         modus-themes-scale-vheadings t
         modus-themes-scale-1 1.1
         modus-themes-scale-2 1.15
         modus-themes-scale-3 1.20
         modus-themes-scale-4 1.25
         modus-themes-scale-title 1.30)
  (load-theme 'modus-operandi))


;; Create a new org todo file for a project
(defun my-mark-as-project ()
  "This function makes sure that the current heading has
(1) the tag :project:
(2) has property COOKIE_DATA set to \"todo recursive\"
(3) has any TODO keyword and
(4) a leading progress indicator"
  (interactive)
  (org-toggle-tag "project" 'on)
  (org-set-property "COOKIE_DATA" "todo recursive")
  (org-back-to-heading t)
  (let* ((title (nth 4 (org-heading-components)))
         (keyword (nth 2 (org-heading-components))))
    (when (and (bound-and-true-p keyword) (string-prefix-p "[" title))
      (message "TODO keyword and progress indicator found")
      )
    (when (and (not (bound-and-true-p keyword)) (string-prefix-p "[" title))
      (message "no TODO keyword but progress indicator found")
      (forward-whitespace 1)
      (insert "NEXT ")
      )
    (when (and (not (bound-and-true-p keyword)) (not (string-prefix-p "[" title)))
      (message "no TODO keyword and no progress indicator found")
      (forward-whitespace 1)
      (insert "NEXT [/] ")
      )
    (when (and (bound-and-true-p keyword) (not (string-prefix-p "[" title)))
      (message "TODO keyword but no progress indicator found")
      (forward-whitespace 2)
      (insert "[/] ")
      )
    )
  )


;; Need a way to create projects ?

;; This allows me to mark something with a tag which can be picked up by org view by tag, and gives a sort of progress of the project using the percentage complete tag
(defun org-new-project ()
  (interactive)
  (insert "* [/] ")
  (save-excursion
    (insert (format (concat "\n"
                            ":project:\n"
                            ":COOKIE_DATA: todo recursive\n"
                            ":ID:       %s\n"
                            ":CREATED:  %s\n")
                    (substring (shell-command-to-string "uuidgen") 0 -1)
                    (format-time-string (org-time-stamp-format t t))))))

;; This should add a task at the level below the :project: tag
(defun org-new-todo ()
  (interactive)
  (insert "TODO ")
  (save-excursion
    (insert (format (concat "\n"
                            ":ID:       %s\n"
                            ":CREATED:  %s\n")
                    (substring (shell-command-to-string "uuidgen") 0 -1)
                    (format-time-string (org-time-stamp-format t t)))))
  (save-excursion
    (forward-line)
    (org-cycle)))

;; This should add a task under the current level, basically function the same as a sub heading
;; (defun org-new-sub-todo ()

(use-package savehist
  :defer 2
  :hook (after-init . savehist-mode)
  :config
  (setq history-length 1000)
  (setq history-delete-duplicates t)
  (setq savehist-save-minibuffer-history t))
