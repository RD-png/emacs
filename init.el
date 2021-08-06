;; Function to automatically generate a .el for our .org configuration files
(defun org-babel-tangle-config ()
  (when (string-equal (file-name-directory (buffer-file-name))
                      (expand-file-name user-emacs-directory))
    (let ((org-confirm-babel-evaluate nil))
      (org-babel-tangle))))

(add-hook 'org-mode-hook (lambda () (add-hook 'after-save-hook #'org-babel-tangle-config)))

;; native comp
(setq comp-deferred-compilation t)
(setq comp-speed 3)
(setq comp-async-report-warnings-errors nil)
(setq warning-minimum-level :error)

;; Stop the native comp warnings
(defvar grep-find-ignored-directories nil)
(defvar grep-find-ignored-files nil)
(defvar ido-context-switch-command nil)
(defvar ido-cur-item nil)
(defvar ido-cur-list nil)
(defvar ido-default-item nil)
(defvar inherit-input-method nil)
(defvar oauth--token-data nil)
(defvar tls-checktrust nil)
(defvar tls-program nil)
(defvar url-callback-arguments nil)
(defvar url-callback-function nil)
(defvar url-http-extra-headers nil)

;; Set default font size values
(defvar default-font-size 150)
(defvar default-variable-font-size 150)

;; Set default transparency values
(defvar frame-transparency '(100 . 100))

;; Default to utf-8
(setq default-buffer-file-coding-system 'utf-8)

;; Syntax highlight for all buffers
(global-font-lock-mode t)

;; When using gui confirm before closing
(when (window-system)
  (setq confirm-kill-emacs 'yes-or-no-p))

;; Weird
(setq system-uses-terminfo nil)

;; Set exec paths for npm packages on nix
(add-to-list 'exec-path "/root/.config/.npm-global/bin")

(setq gc-cons-threshold (* 50 1000 1000))

(defun display-startup-time ()
  (message "Emacs loaded in %s with %d garbage collections."
           (format "%.2f seconds"
                   (float-time
                    (time-subtract after-init-time before-init-time)))
           gcs-done))

;; Call the function
(add-hook 'emacs-startup-hook #'display-startup-time)

;; Initialize package sources
(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;; Initialize use-package on non-Linux platforms (incase I ever use emacs on windows)
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

;; Bootstrap straight.el
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

;; Always use straight to install on systems other than Linux
(setq straight-use-package-by-default (not (eq system-type 'gnu/linux)))

;; Use straight.el for use-package expressions
(straight-use-package 'use-package)

;; Load the helper package for commands like `straight-x-clean-unused-repos'
(require 'straight-x)

(use-package auto-package-update
  :custom
  (auto-package-update-interval 7)
  (auto-package-update-prompt-before-update t)
  (auto-package-update-hide-results t)
  :config
  (auto-package-update-maybe)
  (auto-package-update-at-time "09:00"))

(use-package dashboard
  :ensure t
  :config
  (dashboard-setup-startup-hook)
  (setq dashboard-startup-banner 'official)
  (setq dashboard-items '((recents  . 10)
                          (projects . 5)
                          (bookmarks . 5)))
  (setq dashboard-banner-logo-title "")
  (setq dashboard-set-file-icons t))

(setq inhibit-startup-message t)

  (scroll-bar-mode -1)        ; Disable visible scrollbar
  (tool-bar-mode -1)          ; Disable the toolbar
  (tooltip-mode -1)           ; Disable tooltips
  (set-fringe-mode 10)

  (menu-bar-mode -1)            ; Disable the menu bar

  (column-number-mode)
  (global-display-line-numbers-mode t) ; Line numbers

  ;; y or n instead of yes or no
  (defalias 'yes-or-no-p 'y-or-n-p)

  ;; Set frame transparency
  (set-frame-parameter (selected-frame) 'alpha frame-transparency)
  (add-to-list 'default-frame-alist `(alpha . ,frame-transparency))
  (set-frame-parameter (selected-frame) 'fullscreen 'maximized)
  (add-to-list 'default-frame-alist '(fullscreen . maximized))

  ;; Disable line numbers for some modes
  (dolist (mode '(org-mode-hook
                  term-mode-hook
                  shell-mode-hook
                  eshell-mode-hook))
    (add-hook mode (lambda () (display-line-numbers-mode 0))))

  ;; Better scrolling
  (setq scroll-conservatively 100
        scroll-preserve-screen-position t)

;; Kill server if there is one and start fresh
  (require 'server nil t)
  (use-package server
    :if window-system
    :init
    (when (not (server-running-p server-name))
      (server-start)))

(set-face-attribute 'default nil :font "Source Code Pro" :height default-font-size)

;; Set the fixed pitch face
(set-face-attribute 'fixed-pitch nil :font "Source Code Pro" :height default-font-size)

;; Set the variable pitch face
(set-face-attribute 'variable-pitch nil :font "Source Code Pro" :height default-variable-font-size :weight 'regular)

(add-to-list 'custom-theme-load-path "~/.emacs.d/themes")

(load-theme 'desert2 t)

(set-foreground-color "#c5c8c6")
(set-background-color "#1d1f21")


;; For the default theme
(custom-set-faces
 '(company-preview
   ((t (:background "#1d1f21" :foreground "white" :underline t))))
 '(company-preview-common
   ((t (:inherit company-preview))))
 '(company-tooltip
   ((t (:background "#1d1f21" :foreground "white"))))
 '(company-tooltip-selection
   ((t (:background "steelblue" :foreground "white"))))
 )

(use-package all-the-icons)

(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :custom ((doom-modeline-height 15)))

(use-package ivy
  :diminish
  :bind (("C-s" . swiper)
         :map ivy-minibuffer-map
         ("TAB" . ivy-alt-done)
         :map ivy-switch-buffer-map
         ("C-l" . ivy-done)
         ("C-d" . ivy-switch-buffer-kill)
         :map ivy-reverse-i-search-map
         ("C-k" . ivy-previous-line)
         ("C-d" . ivy-reverse-i-search-kill))
  :config
  (ivy-mode 1))

(use-package ivy-rich
  :after ivy
  :init
  (ivy-rich-mode 1))

(use-package counsel
  :bind (("C-M-j" . 'counsel-switch-buffer)
         :map minibuffer-local-map
         ("C-r" . 'counsel-minibuffer-history))
  :custom
  (counsel-linux-app-format-function #'counsel-linux-app-format-function-name-only)
  :config
  (counsel-mode 1))

(use-package ivy-prescient
  :after counsel
  :custom
  (ivy-prescient-enable-filtering nil)
  :config
  ;; Uncomment the following line to have sorting remembered across sessions!
                                        ;(prescient-persist-mode 1)
  (ivy-prescient-mode 1))

(use-package wgrep
  :config
  (setq wgrep-change-readonly-file t)
  :bind (
         :map wgrep-mode-map
         ("C-x C-s" . custom-wgrep-apply-save)))


(defun custom-wgrep-apply-save ()
  "Apply the edits and save the buffers"
  (interactive)
  (wgrep-finish-edit)
  (wgrep-save-all-buffers))

(defun reb-query-replace (to-string)
  "Replace current RE from point with `query-replace-regexp'."
  (interactive
   (progn (barf-if-buffer-read-only)
          (list (query-replace-read-to (reb-target-binding reb-regexp)
                                       "Query replace"  t))))
  (with-current-buffer reb-target-buffer
    (query-replace-regexp (reb-target-binding reb-regexp) to-string)))

(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 1))

(use-package diminish
  :straight t)

(use-package helpful
  :commands (helpful-callable helpful-variable helpful-command helpful-key)
  :custom
  (counsel-describe-function-function #'helpful-callable)
  (counsel-describe-variable-function #'helpful-variable)
  :bind
  ([remap describe-function] . counsel-describe-function)
  ([remap describe-command] . helpful-command)
  ([remap describe-variable] . counsel-describe-variable)
  ([remap describe-key] . helpful-key))

(use-package switch-window
  :ensure t
  :config
  (setq switch-window-input-style 'minibuffer)
  (setq switch-window-increase 4)
  (setq switch-window-threshold 2)
  (setq switch-window-shortcut-style 'qwerty)
  (setq switch-window-qwerty-shortcuts
        '("a" "s" "d" "f" "j" "k" "l" "i" "o"))
  :bind
  ([remap other-window] . switch-window))

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

(use-package eyebrowse
  :init
  (progn
    (defun my/create-eyebrowse-setup ()
      (interactive)
      "Create a default window config, if none is present"
      (when (not (eyebrowse--window-config-present-p 2))
        (eyebrowse-switch-to-window-config-2)
        (eyebrowse-switch-to-window-config-1)))
    (setq eyebrowse-wrap-around t
          eyebrowse-new-workspace t)
    (eyebrowse-mode 1)
    (global-set-key (kbd "C-c C-'") 'eyebrowse-next-window-config)
    (global-set-key (kbd "C-c C-w C-k") 'eyebrowse-close-window-config)
    (add-hook 'after-init-hook #'my/create-eyebrowse-setup)))

(use-package avy
  :ensure t
  :bind
  ("M-s" . avy-goto-char)
  ("M-m" . avy-goto-word-0))

(use-package expand-region
  :bind ("C-}" . er/expand-region))

(use-package no-littering)

;; Disable auto saving and backups and symbolic link files
(setq make-backup-files nil)
(setq auto-save-default nil)
(setq create-lockfiles nil)

(defun org-font-setup ()
  ;; Replace list hyphen with dot
  (font-lock-add-keywords 'org-mode
                          '(("^ *\\([-]\\) "
                             (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))

  ;; Set faces for heading levels
  (dolist (face '((org-level-1 . 1.2)
                  (org-level-2 . 1.1)
                  (org-level-3 . 1.05)
                  (org-level-4 . 1.0)
                  (org-level-5 . 1.1)
                  (org-level-6 . 1.1)
                  (org-level-7 . 1.1)
                  (org-level-8 . 1.1)))
    (set-face-attribute (car face) nil :font "Source Code Pro" :weight 'regular :height (cdr face)))

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
  :pin org
  :commands (org-capture org-agenda)
  :hook (org-mode . org-mode-setup)
  :config
  (setq org-ellipsis " ▾")

  (setq org-agenda-start-with-log-mode t)
  (setq org-log-done 'time)
  (setq org-log-into-drawer t)

  (setq org-agenda-files
        '("~/.emacs.d/OrgFiles/Tasks.org"))

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
      ("tt" "Task" entry (file+olp "~/.emacs.d/OrgFiles/Tasks.org" "Inbox")
           "* TODO %?\n  %U\n  %a\n  %i" :empty-lines 1)

      ("j" "Journal Entries")
      ("jj" "Journal" entry
           (file+olp+datetree "~/.emacs.d/OrgFiles/Journal.org")
           "\n* %<%I:%M %p> - Journal :journal:\n\n%?\n\n"
           ;; ,(dw/read-file-as-string "~/Notes/Templates/Daily.org")
           :clock-in :clock-resume
           :empty-lines 1)
      ("jm" "Meeting" entry
           (file+olp+datetree "~/.emacs.d/OrgFiles/Journal.org")
           "* %<%I:%M %p> - %a :meetings:\n\n%?\n\n"
           :clock-in :clock-resume
           :empty-lines 1)

      ("w" "Workflows")
      ("we" "Checking Email" entry (file+olp+datetree "~/.emacs.d/OrgFiles/Journal.org")
           "* Checking Email :email:\n\n%?" :clock-in :clock-resume :empty-lines 1)

      ("m" "Metrics Capture")
      ("mw" "Weight" table-line (file+headline "~/.emacs.d/OrgFiles/Metrics.org" "Weight")
       "| %U | %^{Weight} | %^{Notes} |" :kill-buffer t)))

  (define-key global-map (kbd "C-c j")
    (lambda () (interactive) (org-capture nil "jj")))

  (org-font-setup))

(use-package org-bullets
  :hook (org-mode . org-bullets-mode)
  :custom
  (org-bullets-bullet-list '("◉" "○" "●" "○" "●" "○" "●")))

(defun org-mode-visual-fill ()
  (setq visual-fill-column-width 100
        visual-fill-column-center-text t)
  (visual-fill-column-mode 1))

(use-package visual-fill-column
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

(defun configure-eshell ()
  ;; Save command history when commands are entered
  (add-hook 'eshell-pre-command-hook 'eshell-save-some-history)

  ;; Truncate buffer for performance
  (add-to-list 'eshell-output-filter-functions 'eshell-truncate-buffer)

  (setq eshell-history-size         10000
        eshell-buffer-maximum-lines 10000
        eshell-hist-ignoredups t
        eshell-scroll-to-bottom-on-input t))

(use-package eshell-git-prompt
  :after eshell)

(use-package eshell
  :hook (eshell-first-time-mode . configure-eshell)
  :config

  (with-eval-after-load 'esh-opt
    (setq eshell-destroy-buffer-when-process-dies t)
    (setq eshell-visual-commands '("htop" "zsh" "vim")))

  (eshell-git-prompt-use-theme 'powerline))

(use-package company
  :defines company-backends
  :diminish company-mode
  :bind (:map company-active-map
              ("<tab>" . company-complete-selection))
  :straight t
  :custom
  (company-dabbrev-downcase nil)
  :config
  (add-hook 'after-init-hook 'global-company-mode)
      (setq company-idle-delay 0.0
          company-minimum-prefix-length 1)
      (global-company-mode 1))

(use-package lsp-mode
  :straight t
  :hook (lsp)
  :custom
  (lsp-signature-render-documentation nil)
  (lsp-enable-snippet t)
  (lsp-document-sync-method nil)
  (lsp-print-performance t)
  (lsp-before-save-edits nil)
  (lsp-signature-render-documentation t)
  :bind
  ("C-c o d" . lsp-describe-thing-at-point)
  ("C-c o f" . lsp-format-buffer)
  ("C-c o a" . lsp-execute-code-action))

(use-package lsp-ui
  :straight t
  :hook (lsp-mode . lsp-ui-mode)
  :config
  (setq lsp-ui-sideline-ignore-duplicate t)
  (add-hook 'lsp-mode-hook 'lsp-ui-mode)
  (setq lsp-ui-doc-enable nil)
  (setq lsp-eldoc-enable-hover nil)
  (setq lsp-modeline-diagnostics-enable nil)
  (setq lsp-ui-doc-show-with-cursor nil)
  (setq lsp-signature-auto-activate nil)
  (setq lsp-ui-doc-show-with-mouse nil)
  (setq lsp-headerline-breadcrumb-enable nil)
  (setq lsp-ui-sideline-show-code-actions nil)
  (setq lsp-completion-show-detail nil))

;; (use-package lsp-ivy
;;   :after lsp)

(use-package php-mode
  :straight t
  :mode "\\.php\\'"
  :hook (php-mode . lsp-deferred))

;; Format current php buffer on save
(defun lsp-php-install-save-hooks ()
  (add-hook 'before-save-hook #'lsp-format-buffer t t)
  (add-hook 'before-save-hook #'lsp-organize-imports t t))

(add-hook 'php-mode-hook #'lsp-php-install-save-hooks)

(use-package typescript-mode
  :straight t
  :mode
  ("\\.ts\\'"
   "\\.js\\'")
  :hook (typescript-mode . lsp-deferred)
  :config
  (setq typescript-indent-level 2))

(use-package lsp-python-ms
  :ensure t
  :hook (python-mode . (lambda ()
                         (require 'lsp-python-ms)
                         (lsp-deferred)))
  :init
  (setq lsp-python-ms-executable (executable-find "python-language-server")))

(use-package python-mode
  :ensure t
  :hook (python-mode . lsp-deferred)
  :config
  (setq python-shell-interpreter "python3")
  (setq flycheck-python-pylint-executable (executable-find "pylint"))
  (setq flycheck-pylintrc (substitute-in-file-name "$HOME/.pylintrc")))

(use-package nix-mode
  :mode "\\.nix\\'")

(use-package multi-web-mode
  :ensure t
  :hook (multi-web-mode . lsp-mode))

(require 'multi-web-mode)
(setq mweb-default-major-mode 'typescript-mode)
(setq mweb-tags '((html-mode "<template[^>]*>" "</template>")
                  (css-mode "<style[^>]*>" "</style>")
                  (css-mode "<style scoped[^>]*>" "</style>")))

(setq mweb-filename-extensions '("vue"))
(multi-web-global-mode 1)

(use-package css-mode
  :ensure t)

(use-package haskell-mode
  :straight t
  :mode ("\\.hs\\'")
  :hook (haskell-mode . lsp-deferred))

;; finds executable and some additional compiler settings
(use-package lsp-haskell
  :ensure t
  :after lsp-mode
  :hook (haskell-mode . lsp-deferred))

(use-package projectile
  :diminish projectile-mode
  :config (projectile-mode)
  :custom ((projectile-completion-system 'ivy))
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :init
  (projectile-mode 1)
  (setq projectile-switch-project-action #'projectile-dired))

(use-package counsel-projectile
  :after projectile
  :config (counsel-projectile-mode))

(use-package magit
  :commands magit-status
  :bind ("C-c g" . magit-status)
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

(use-package forge
  :after magit)

(use-package evil-nerd-commenter
  :bind ("C-;" . evilnc-comment-or-uncomment-lines))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(show-paren-mode 1)

;; Colors for # colors
(use-package rainbow-mode
  :defer t
  :hook (org-mode
         emacs-lisp-mode
         typescript-mode))

(custom-set-faces
 '(rainbow-delimiters-depth-1-face ((t (:foreground "#f66d9b"))))
 '(rainbow-delimiters-depth-2-face ((t (:foreground "#66c1b7"))))
 '(rainbow-delimiters-depth-3-face ((t (:foreground "#6574cd"))))
 '(rainbow-delimiters-depth-4-face ((t (:foreground "#fa7b62"))))
 '(rainbow-delimiters-depth-5-face ((t (:foreground "#fef691"))))
 '(rainbow-delimiters-depth-6-face ((t (:foreground "#ff70bf"))))
 '(rainbow-delimiters-depth-7-face ((t (:foreground "#fdae42"))))
 '(rainbow-delimiters-depth-8-face ((t (:foreground "#8f87de")))))

(use-package yasnippet
  :ensure t
  :hook (prog-mode . yas-minor-mode)
  :init
  (yas-global-mode 1)
  :config
  (yas-reload-all))

(use-package popup-kill-ring
  :ensure t
  :bind ("M-y" . popup-kill-ring))

(use-package flycheck
  :defer t
  :hook(lsp-mode . flycheck-mode))

(use-package smartparens
  :hook (prog-mode . smartparens-mode))

(use-package paren
  :config
  (set-face-attribute 'show-paren-match-expression nil :background "#363e4a")
  (show-paren-mode 1))

(use-package dired
  :ensure nil
  :commands (dired dired-jump)
  :bind (("C-x C-j" . dired-jump))
  :custom ((dired-listing-switches "-agho --group-directories-first"))
  )

(use-package dired-rainbow
  :defer 2
  :config
  (dired-rainbow-define-chmod directory "#6cb2eb" "d.*")
  (dired-rainbow-define html "#eb5286" ("css" "less" "sass" "scss" "htm" "html" "jhtm" "mht" "eml" "mustache" "xhtml"))
  (dired-rainbow-define xml "#f2d024" ("xml" "xsd" "xsl" "xslt" "wsdl" "bib" "json" "msg" "pgn" "rss" "yaml" "yml" "rdata"))
  (dired-rainbow-define document "#9561e2" ("docm" "doc" "docx" "odb" "odt" "pdb" "pdf" "ps" "rtf" "djvu" "epub" "odp" "ppt" "pptx"))
  (dired-rainbow-define markdown "#ffed4a" ("org" "etx" "info" "markdown" "md" "mkd" "nfo" "pod" "rst" "tex" "textfile" "txt"))
  (dired-rainbow-define database "#6574cd" ("xlsx" "xls" "csv" "accdb" "db" "mdb" "sqlite" "nc"))
  (dired-rainbow-define media "#de751f" ("mp3" "mp4" "mkv" "MP3" "MP4" "avi" "mpeg" "mpg" "flv" "ogg" "mov" "mid" "midi" "wav" "aiff" "flac"))
  (dired-rainbow-define image "#f66d9b" ("tiff" "tif" "cdr" "gif" "ico" "jpeg" "jpg" "png" "psd" "eps" "svg"))
  (dired-rainbow-define log "#c17d11" ("log"))
  (dired-rainbow-define shell "#f6993f" ("awk" "bash" "bat" "sed" "sh" "zsh" "vim"))
  (dired-rainbow-define interpreted "#38c172" ("py" "ipynb" "rb" "pl" "t" "msql" "mysql" "pgsql" "sql" "r" "clj" "cljs" "scala" "js"))
  (dired-rainbow-define compiled "#4dc0b5" ("asm" "cl" "lisp" "el" "c" "h" "c++" "h++" "hpp" "hxx" "m" "cc" "cs" "cp" "cpp" "go" "f" "for" "ftn" "f90" "f95" "f03" "f08" "s" "rs" "hi" "hs" "pyc" ".java"))
  (dired-rainbow-define executable "#8cc4ff" ("exe" "msi"))
  (dired-rainbow-define compressed "#51d88a" ("7z" "zip" "bz2" "tgz" "txz" "gz" "xz" "z" "Z" "jar" "war" "ear" "rar" "sar" "xpi" "apk" "xz" "tar"))
  (dired-rainbow-define packaged "#faad63" ("deb" "rpm" "apk" "jad" "jar" "cab" "pak" "pk3" "vdf" "vpk" "bsp"))
  (dired-rainbow-define encrypted "#ffed4a" ("gpg" "pgp" "asc" "bfe" "enc" "signature" "sig" "p12" "pem"))
  (dired-rainbow-define fonts "#6cb2eb" ("afm" "fon" "fnt" "pfb" "pfm" "ttf" "otf"))
  (dired-rainbow-define partition "#e3342f" ("dmg" "iso" "bin" "nrg" "qcow" "toast" "vcd" "vmdk" "bak"))
  (dired-rainbow-define vc "#0074d9" ("git" "gitignore" "gitattributes" "gitmodules"))
  (dired-rainbow-define-chmod executable-unix "#38c172" "-.*x.*"))

(use-package dired-single
  :commands (dired dired-jump))

(use-package all-the-icons-dired
  :hook (dired-mode . all-the-icons-dired-mode))

(use-package dired-open
  :commands (dired dired-jump)
  :config
  ;; Doesn't work as expected!
  ;;(add-to-list 'dired-open-functions #'dired-open-xdg t)
  (setq dired-open-extensions '(("png" . "feh")
                                ("mkv" . "mpv"))))

(setq-default tab-width 2)
(setq-default indent-tabs-mode nil)

(use-package multiple-cursors
  :bind (("C-S-c C-S-c" . mc/edit-lines)
         ("C->" . mc/mark-next-like-this)
         ("C-<" . mc/mark-previous-like-this)
         ("C-c C-<" . mc/mark-all-like-this)))

(use-package undo-tree)
(global-undo-tree-mode 1)
(global-set-key (kbd "C-/") #'undo)
(defalias 'redo 'undo-tree-redo)
(global-set-key (kbd "C-?") #'redo)

(defun copy-word ()
  (interactive)
  (save-excursion
    (forward-char 1)
    (backward-word)
    (kill-word 1)
    (yank)))

(defun smart-beginning-of-line ()
  (interactive)
  (let ((oldpos (point)))
    (back-to-indentation)
    (and (= oldpos (point))
         (beginning-of-line))))

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

(defun aborn/backward-kill-word ()
  "Customize/Smart backward-kill-word."
  (interactive)
  (let* ((cp (point))
         (backword)
         (end)
         (space-pos)
         (backword-char (if (bobp)
                            ""           ;; cursor in begin of buffer
                          (buffer-substring cp (- cp 1)))))
    (if (equal (length backword-char) (string-width backword-char))
        (progn
          (save-excursion
            (setq backword (buffer-substring (point) (progn (forward-word -1) (point)))))
          (setq ab/debug backword)
          (save-excursion
            (when (and backword          ;; when backword contains space
                       (s-contains? " " backword))
              (setq space-pos (ignore-errors (search-backward " ")))))
          (save-excursion
            (let* ((pos (ignore-errors (search-backward-regexp "\n")))
                   (substr (when pos (buffer-substring pos cp))))
              (when (or (and substr (s-blank? (s-trim substr)))
                        (s-contains? "\n" backword))
                (setq end pos))))
          (if end
              (kill-region cp end)
            (if space-pos
                (kill-region cp space-pos)
              (backward-kill-word 1))))
      (kill-region cp (- cp 1)))         ;; word is non-english word
    ))

(defun custom-avy-copy-line ()
  (interactive)
  (save-excursion
    (avy-goto-line)
    (back-to-indentation)
    (kill-line)
    (yank)))

;; General binds
(global-set-key (kbd "C-c w") #'copy-word)
(global-set-key (kbd "C-c l") #'custom-avy-copy-line)
(global-set-key (kbd "C-x C-b") #'switch-to-buffer)
(global-set-key (kbd "C-a") #'smart-beginning-of-line)
(global-set-key (kbd "M-]") #'shift-right)
(global-set-key (kbd "M-[") #'shift-left)
(global-set-key [C-backspace] #'aborn/backward-kill-word)
(global-set-key (kbd "C-M-<return>") #'eshell)

;; Half the distance of page down and up
(autoload 'View-scroll-half-page-forward "view") (autoload 'View-scroll-half-page-backward "view")
(global-set-key (kbd "C-v") 'View-scroll-half-page-forward)
(global-set-key (kbd "M-v") 'View-scroll-half-page-backward)

;; unbind annoying keybinds
(unbind-key "C-x C-n") ;; useless command
(unbind-key "M-`")

;; Remove whitespace from buffer on save
(add-hook 'before-save-hook 'delete-trailing-whitespace)
