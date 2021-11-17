;; -*- lexical-binding: t; -*-

;; GC config
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

;; native comp
(when (and (fboundp 'native-comp-available-p)
           (native-comp-available-p))
  (progn
    (setq native-comp-async-report-warnings-errors nil)
    (setq comp-deferred-compilation t)
    (setq warning-minimum-level :error)
    (setq package-native-compile t)
    (add-to-list 'native-comp-eln-load-path (expand-file-name "eln-cache/" user-emacs-directory))))

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

;; Time emacs startup
(defun display-startup-time ()
  (message "Emacs loaded in %s with %d garbage collections."
           (format "%.2f seconds"
                   (float-time
                    (time-subtract after-init-time before-init-time)))
           gcs-done))
(add-hook 'emacs-startup-hook #'display-startup-time)

;; Set default font size values
(defvar default-font-size 140)
(defvar default-variable-font-size 140)
(setq custom-safe-themes t)

;; Default to utf-8
(setq default-buffer-file-coding-system 'utf-8-unix
      buffer-file-coding-system 'utf-8-unix)

(push "node_modules/" completion-ignored-extensions)
(push "__pycache__/" completion-ignored-extensions)

;; Syntax highlight for all buffers
(global-font-lock-mode t)
(blink-cursor-mode -1)

;; Dont save duplicate variables in kill ring
(setq kill-do-not-save-duplicates t)

;; When using gui confirm before closing
(when (window-system)
  (setq confirm-kill-emacs 'yes-or-no-p))

;; Weird
(setq system-uses-terminfo nil)

;; Set eec paths for npm packages on nix
(add-to-list 'exec-path "~/.npm/bin")

;; General Defaults
(setq undo-limit 1600000)
(setq delete-old-versions t
      delete-by-moving-to-trash t
      enable-recursive-minibuffers t)

(setq uniquify-buffer-name-style 'forward)

;; Ediff layout
(setq ediff-split-window-function 'split-window-horizontally
      ediff-window-setup-function 'ediff-setup-windows-plain)

;; Remove startup message
(advice-add 'display-startup-echo-area-message :override #'ignore)
(package-activate-all)
(setq package-archives '(("elpa" . "https://elpa.gnu.org/packages/")
			                   ("melpa" . "https://melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;; Initialize use-package on non-Linux platforms (incase I ever use emacs on windows)
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure nil
      straight-disable-native-compile nil
      straight-use-package-by-default nil)

(setq straight-check-for-modifications nil
      autoload-compute-prefixes nil
      straight-vc-git-default-clone-depth 1)

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

(use-package hydra
  :straight t)

(use-package use-package-hydra
  :straight t
  :demand t)

(use-package dashboard  
  :straight t
  :config
  (dashboard-setup-startup-hook)
  (setq dashboard-startup-banner 'official)
  (setq dashboard-items '((recents  . 10)
                          (projects . 5)
                          (bookmarks . 5)))
  (setq dashboard-banner-logo-title "")
  (setq dashboard-set-file-icons t))

(setq inhibit-startup-message t)
(setq initial-scratch-message "")

(scroll-bar-mode -1)
(tool-bar-mode -1)
(tooltip-mode -1)
(set-fringe-mode 10)
(menu-bar-mode -1)
(column-number-mode)
(global-display-line-numbers-mode t)

;; y or n instead of yes or no
(defalias 'yes-or-no-p 'y-or-n-p)

;; Fullscreen default
(set-frame-parameter (selected-frame) 'fullscreen 'maximized)
(add-to-list 'default-frame-alist '(fullscreen . maximized))

;; Disable line numbers for some modes
(dolist (mode '(org-mode-hook
                term-mode-hook
                shell-mode-hook
                eshell-mode-hook
                dired-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

;; Better scrolling
(setq scroll-conservatively 100
      scroll-preserve-screen-position t)

(require 'server nil t)
(use-package server
  :straight t
  :demand t
  :if window-system
  :init
  (when (not (server-running-p server-name))
    (server-start)))

(set-face-attribute 'default nil :font "Fantasque Sans Mono" :foundry "PfEd" :slant 'normal :weight 'normal :width 'normal :height 140)
(set-face-attribute 'fixed-pitch nil :font "Fantasque Sans Mono" :height default-font-size)
(set-face-attribute 'variable-pitch nil :font "Fantasque Sans Mono" :height default-variable-font-size :weight 'regular)

(add-to-list 'custom-theme-load-path "~/.config/emacs/themes")
;; (set-foreground-color "#c5c8c6")
;; (set-background-color "#1d1f21")

;; Custom faces
(custom-set-faces
 `(mode-line ((t (:underline (:line-width 1)))))
 `(cursor ((t (:background "IndianRed3")))))

;; mode line underline in right place
(setq x-underline-at-descent-line t)

(use-package tree-sitter-langs
  :straight t)

(use-package tree-sitter
  :straight t
  :config
  (global-tree-sitter-mode)
  (add-hook 'tree-sitter-after-on-hook #'tree-sitter-hl-mode))

(use-package popper
  :straight t
  :after projectile
  :bind (("C-c C-." . popper-toggle-latest)
         ("C-c M-." . popper-kill-latest-popup)
         ("C-c C-/" . popper-cycle)
         ("C-c C-;" . popper-toggle-type))
  :init
  (setq popper-reference-buffers
        (append
         '("\\*Messages\\*"
           "^\\*Warnings\\*$"
           "Output\\*$"
           "^\\*Backtrace\\*"
           "\\*Async Shell Command\\*"
           "\\*Completions\\*"
           "[Oo]utput\\*"
           help-mode
           compilation-mode)))
  (popper-mode +1)
  (popper-echo-mode +1))

(setq display-buffer-base-action
      '(display-buffer-reuse-mode-window
        display-buffer-reuse-window
        display-buffer-same-window))

;; If a popup does happen, don't resize windows to be equal-sized
(setq even-window-sizes nil)

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
  `((company-mode . " ⇝")
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
    (projectile-mode . "")
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
    (flymake-mode . "")))

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
        read-buffer-completion-ignore-case t)
  :custom-face
  (vertico-current ((t (:background "light blue"))))
  :init
  (vertico-mode))

(use-package orderless
  :straight t
  :demand t
  :config
  (defun orderless-company-fix-face+ (fn &rest args)
    (let ((orderless-match-faces [completions-common-part]))
      (apply fn args)))

  (setq completion-styles '(orderless)
        completion-category-defaults nil
        completion-category-overrides '((file (styles . (orderless partial-completion)))))

  (with-eval-after-load 'company
    (advice-add 'company-capf--candidates :around #'orderless-company-fix-face+)))

(use-package prescient
  :straight t
  :demand t
  :custom
  (prescient-history-length 1000)
  :config
  (prescient-persist-mode +1))

(use-package savehist
  :straight (savehist :type built-in)
  :hook (after-init . savehist-mode)
  :custom
  (savehist-additional-variables
   '(kill-ring search-ring regexp-search-ring
               consult--line-history evil-ex-history
               projectile-project-command-history)))

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
  :init
  (setq prefix-help-command #'embark-prefix-help-command)
  :bind
  (:map minibuffer-local-map
        ("C-c C-o" . embark-export))
  :bind*
  ("C-o" . embark-act)  
  ("C-h h" . embark-bindings))

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
  :demand t
  :after projectile
  :bind (("C-s" . consult-line)
         ("C-M-s" . multi-occur)
         ("C-M-l" . consult-outline)
         ("M-g M-g" . consult-goto-line)
         ("C-c h" . consult-mark)
         ("C-c H" . consult-global-mark)
         ("C-c f" . consult-flymake)
         ("C-x M-f" . consult-recent-file)
         ([remap popup-kill-ring] . consult-yank-from-kill-ring)
         :map minibuffer-local-map
         ("C-r" . consult-history))
  :config
  (setq consult-project-root-function #'projectile-project-root
        xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)
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

(use-package marginalia
  :straight t
  :after vertico
  :init
  (marginalia-mode)
  :custom
  (marginalia-annotators '(marginalia-annotators-heavy marginalia-annotators-light nil))
  :config
  (advice-add #'marginalia--project-root :override #'projectile-project-root)
  (add-hook 'marginalia-mode-hook #'all-the-icons-completion-marginalia-setup)
  (setq marginalia-command-categories
        (append '((projectile-find-file . project-file)
                  (projectile-find-dir . project-file)
                  (projectile-switch-project . project-file)
                  (projectile-recentf . project-file)
                  (projectile-switch-to-buffer . buffer)
                  (persp-switch-to-buffer . buffer))
                marginalia-command-categories)))

(use-package wgrep
  :straight t
  :config
  (setq wgrep-change-readonly-file t)
  :bind (:map wgrep-mode-map
              ("C-x C-s" . custom-wgrep-apply-save)))


(defun custom-wgrep-apply-save ()
  "Apply the edits and save the buffers"
  (interactive)
  (wgrep-finish-edit)
  (wgrep-save-all-buffers))

(use-package helpful
  :straight t
  :bind
  ([remap describe-function] . helpful-function)
  ([remap describe-symbol] . helpful-symbol)
  ([remap describe-variable] . helpful-variable)
  ([remap describe-command] . helpful-command)
  ([remap describe-key] . helpful-key))

(use-package ace-window
  :straight t
  :config
  (setq aw-dispatch-always t)
  (setq aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l))
  (defun my/ace-window ()
    (interactive)
    (if (> (length (mapcar #'window-buffer (window-list))) 2)
        (ace-select-window)
      (other-window -1)))
  (defun my/ace-swap-window ()
    (interactive)
    (if (> (length (mapcar #'window-buffer (window-list))) 2)
        (ace-swap-window)
      (window-swap-states)))
  :bind (("C-x o" . my/ace-window)
         ("C-x 0" . ace-delete-window)
         ("C-x O" . my/ace-swap-window)
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
  :bind (("C-x w" . persp-hydra/body)
         ("C-c C-'" . persp-next)
         ("C-x M-b" . persp-switch))
  :custom
  (persp-initial-frame-name "Win1")
  :config
  (setq persp-modestring-dividers '("|" "|" "|"))
  (unless (equal persp-mode t)
    (persp-mode))

  persp-modestring-dividers

  :hydra
  (persp-hydra (:columns 4 :color pink)
               "Perspective"
               ("a" persp-add-buffer "Add Buffer")
               ("i" persp-import "Import")
               ("c" persp-kill "Close")
               ("n" persp-next "Next")
               ("p" persp-prev "Prev")
               ("k" persp-remove-buffer "Kill Buffer")
               ("r" persp-rename "Rename")
               ("A" persp-set-buffer "Set Buffer")
               ("s" persp-switch "Switch")
               ("C-x" persp-switch-last "Switch Last")
               ("b" persp-switch-to-buffer "Switch to Buffer")
               ("P" projectile-persp-switch-project "Switch Project")
               ("q" nil :exit t)))

;; Yoinked from karthinks blog
(use-package avy
  :straight t
  :config
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
  ("M-m" . avy-goto-word-0)
  ("M-s" . avy-goto-char))

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

(use-package expand-region
  :straight t
  :bind (("C-}" . er/expand-region)
         ("C-M-}" . er/mark-outside-pairs)
         ("C-{" . er/mark-inside-pairs)))

(use-package no-littering
  :straight t)

;; Disable auto saving and backups and symbolic link files
(setq make-backup-files nil)
(setq backup-inhibited t)
(setq auto-save-default nil)
(setq create-lockfiles nil)

;; (use-package mu4e
;;   :config
;;   (setq mu4e-change-filenames-when-moving t
;;         mu4e-get-mail-command "mbsync -a"
;;         mu4e-view-show-images t
;;         mu4e-update-interval (* 10 60)
;;         mu4e-maildir "~/Mail")
;;   (setq mu4e-contexts
;;         `(,(make-mu4e-context
;;             :name "elixir"
;;             :vars '(
;;                     (user-full-name . "Ryan Denby")
;;                     (user-mail-address . "ryan@elixirgardens.co.uk")
;;                     (mu4e-sent-folder . "/sent/new")
;;                     (mu4e-trash-folder . "/trash/new")
;;                     (mu4e-drafts-folder . "/drafts/new")
;;                     (mu4e-sent-messages-behavior . sent)
;;                     ))))

;;   (setq mail-user-agent 'mu4e-user-agent
;;         message-send-mail-function 'smtpmail-send-it
;;         smtpmail-smtp-server "smtp.123-reg.co.uk"
;;         smtpmail-smtp-service 465
;;         smtpmail-stream-type 'ssl))

(use-package devdocs
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

(defun org-font-setup ()
  ;; Replace list hyphen with dot
  (font-lock-add-keywords 'org-mode
                          '(("^ *\\([-]\\) "
                             (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))


  ;; MAKE HYDRA TO MANAGE ORG TASKS
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

(defun my/org-last-task ()
  (interactive)
  (end-of-buffer)
  (org-previous-visible-heading 0))

(defun my/org-first-task ()
  (interactive)
  (beginning-of-buffer)
  (org-next-visible-heading 0))

(use-package org
  :straight (org :type built-in)
  :pin org
  :commands (org-capture org-agenda)
  :preface
  (defun my/project-task-file ()
    (interactive)
    (find-file (concat "~/.config/emacs/org/Projects/" (projectile-project-name) ".org")))

  :hook (org-mode . org-mode-setup)
  :bind (("M-o a" . org-agenda)
         ("M-o p t" . my/project-task-file)
         ("M-o t" . org-todo-hydra/body))
  :hydra
  (org-todo-hydra (:columns 4 :color pink)
                  "TODOS"
                  ("n" org-next-visible-heading "Next")
                  ("p" org-previous-visible-heading "Prev")
                  ("a" my/org-first-task "First")
                  ("e" my/org-last-task "Last")
                  ("k" org-cut-subtree "Kill")
                  ("t" org-todo "Status")
                  ("A" org-archive-done-tasks "Archive")
                  ("q" nil :exit t))
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
   (propertize " ⟣─ " 'face `(:foreground "#2544bb"))
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

  ;; Disable company in eshell
  (company-mode -1)
  (setq eshell-prompt-function 'my/eshell-prompt
        eshell-prompt-regexp "[a-zA-z]+ ⟣─ [^#$\n]+ # "
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

(use-package company
  :straight t
  :defer 1
  :defines company-backends
  :bind (:map company-active-map
              ("<tab>" . company-complete-selection))
  :init
  (global-company-mode 1)
  (setq company-auto-commit nil
        company-minimum-prefix-length 2
        company-tooltip-limit 10
        company-tooltip-align-annotations t
        company-dabbrev-ignore-case nil
        company-require-match 'never
        company-idle-delay 0.01
        company-dabbrev-other-buffers nil
        company-dabbrev-downcase nil))

(setq-default company-backends '(company-capf))

(defvar my/company-backend-alist
  '((text-mode (:separate company-dabbrev company-yasnippet company-ispell))
    (prog-mode (:separate company-yasnippet company-capf company-dabbrev-code))
    (conf-mode company-capf company-dabbrev-code company-yasnippet)
    (emacs-lisp-mode company-elisp))
  "An alist matching modes to company backends. The backends for any mode is
        built from this.")

(defun my/set-company-backend (modes &rest backends)
  "Prepends backends (in order) to `company-backends' in modes"
  (declare (indent defun))
  (dolist (mode (list modes))
    (if (null (car backends))
        (setq my/company-backend-alist
              (delq (assq mode my/company-backend-alist)
                    my/company-backend-alist))
      (setf (alist-get mode my/company-backend-alist)
            backends))))

(defun my/company-backends ()
  (let (backends)
    (let ((mode major-mode)
          (modes (list major-mode)))
      (while (setq mode (get mode 'derived-mode-parent))
        (push mode modes))
      (dolist (mode modes)
        (dolist (backend (append (cdr (assq mode my/company-backend-alist))
                                 (default-value 'company-backends)))
          (push backend backends)))
      (delete-dups
       (append (cl-loop for (mode . backends) in my/company-backend-alist
                        if (or (eq major-mode mode)
                               (and (boundp mode)
                                    (symbol-value mode)))
                        append backends)
               (nreverse backends))))))

(add-hook 'after-change-major-mode-hook
          (defun my/company-setup-backends ()
            (interactive)
            "Set `company-backends' for the current buffer."
            (setq-local company-backends (my/company-backends))))

;; (use-package corfu
;;   :straight (corfu :repo "minad/corfu" :branch "main")
;;   :bind (:map corfu-map
;;               ("<tab>" . corfu-insert))
;;   :config
;;   (setq corfu-cycle t
;;         corfu-auto t
;;         corfu-count 10
;;         corfu-auto-delay 0.01
;;         corfu-quit-at-boundary t
;;         corfu-quit-no-match t)
;;   :init
;;   (corfu-global-mode))

(use-package lsp-mode
  :straight t
  :after direnv
  :hook (lsp)
  :config
  (setq lsp-completion-provider :none)
  :bind (:map lsp-mode-map
              ("C-c o d" . lsp-describe-thing-at-point)
              ("C-c o f" . lsp-format-buffer)
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
  (lsp-signature-render-documentation t))

;; (use-package lsp-ui
;;   :straight t
;;   :hook (lsp-mode . lsp-ui-mode)
;;   :config
;;   (setq lsp-ui-sideline-enable nil)
;;   (setq lsp-ui-sideline-ignore-duplicate t)
;;   (setq lsp-ui-doc-enable nil)
;;   (setq lsp-ui-doc-show-with-cursor nil)
;;   (setq lsp-ui-doc-show-with-mouse nil)
;;   (setq lsp-ui-sideline-show-code-actions nil)
;;   (add-hook 'lsp-mode-hook 'lsp-ui-mode))

(use-package direnv
  :straight t
  :config
  (advice-add 'lsp :before (lambda (&optional n) (direnv-update-environment)))
  (direnv-mode))

;; (use-package undo-tree
;;   :straight t
;;   :defer)

;; (use-package eglot
;;   :straight t
;;   :after project
;;   :hook (eglot-connect . eglot-signal-didChangeConfiguration)
;;   :commands (eglot
;;              eglot-ensure
;;              my/eglot-mode-server
;;              my/eglot-mode-server-all)
;;   :config
;;   (add-to-list 'eglot-server-programs '(php-mode . ("intelephense" "--stdio")))
;;   (add-to-list 'eglot-server-programs '(web-mode "vls"))
;;   :init
;;   (setq eglot-sync-connect 1
;;         eglot-connect-timeout 10
;;         eglot-confirm-server-initiated-edits nil
;;         eglot-autoreconnect nil
;;         eglot-autoshutdown t
;;         eglot-send-changes-idle-time 0.5
;;         eglot-auto-display-help-buffer nil
;;         eglot-stay-out-of '(company)
;;         eglot-ignored-server-capabilites '(:documentHighlightProvider))
;;   (add-hook 'flymake-diagnostic-functions 'eglot-flymake-backend)
;;   :bind
;;   ("C-c o d" . eldoc-doc-buffer)
;;   ("C-c o f" . eglot-format-buffer)
;;   ("C-c o a" . eglot-code-actions)
;;   ("C-c o r" . xref-find-references))

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
  :mode ("\\.sld\\'"))

(use-package latex
  :straight (latex :type built-in)
  :defer 5
  :after tex  
  :mode ("\\.tex\\'" . LaTeX-mode))

;; (use-package auctex
;;   :straight (auctex :type built-in))

(use-package cdlatex  
  :straight (cdlatex :type built-in)
  :defer 5
  :after latex    
  :hook (LaTeX-mode . turn-on-cdlatex))

(use-package projectile
  :straight t
  :defer 10
  :config (projectile-mode)
  :bind (([remap projectile-ripgrep] . consult-ripgrep))
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :config
  (setq projectile-switch-project-action #'projectile-dired)
  :init
  (projectile-mode 1))

(use-package project
  :straight (project :type built-in))

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
  (yas-reload-all))

(use-package flymake
  :straight (flymake :type built-in)  
  :init
  (setq-default flymake-diagnostic-functions nil)
  (with-eval-after-load 'flymake-proc
    (remove-hook 'flymake-diagnostic-functions 'flymake-proc-legacy-flymake))
  :config
  (setq flymake-start-on-flymake-mode t
        flymake-start-on-save-buffer t))

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
         ("<return>" . dired-find-alternate-file)
         ("q" . (lambda () (interactive) (find-alternate-file ".."))))
  :custom
  ((dired-listing-switches "-AGFhlv --group-directories-first")
   (dired-recursive-copies t))
  :config
  (put 'dired-find-alternate-file 'disabled nil)
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
(global-set-key (kbd "C-c o R")  #'delete-trailing-whitespace)
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

;; Open my default persp layouts
(defun my/persp-setup-hook ()
  (interactive)
  (persp-switch "Win2")
  (persp-switch "Win1"))

(add-hook 'after-init-hook #'my/persp-setup-hook)

;; Load theme
(use-package modus-themes
  :straight (modus-themes :type built-in)
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
         modus-themes-scale-headings t
         modus-themes-scale-1 1.1
         modus-themes-scale-2 1.15
         modus-themes-scale-3 1.20
         modus-themes-scale-4 1.25
         modus-themes-scale-title 1.30)
  (load-theme 'modus-operandi))
