;;; my-editing.el -*- lexical-binding: t; -*-

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
         ("C-{" . er/select-text-in-delims)))

(use-package anzu
  :straight t
  :bind
  ([remap query-replace] . anzu-query-replace)
  ([remap query-replace-regexp] . anzu-query-replace-regexp)
  :config
  (global-anzu-mode +1))

(use-package evil-nerd-commenter
  :straight t
  :bind ("C-;" . evilnc-comment-or-uncomment-lines))

(use-package rainbow-delimiters
  :straight t
  :hook (prog-mode . rainbow-delimiters-mode)
  :config
  (setq show-paren-mode 1)
  (setq rainbow-delimiters-max-face-count 4))

;; Colors for # colors
(use-package rainbow-mode
  :straight t
  :defer t
  :hook (org-mode
         emacs-lisp-mode
         typescript-mode
         web-mode))

(use-package yasnippet
  :straight t
  :demand t
  :custom
  (yas-triggers-in-field t)
  :init
  (yas-global-mode 1)
  ;; :config
  ;; (defun do-yas-expand ()
  ;;   (let ((yas/fallback-behavior 'return-nil))
  ;;     (yas/expand)))
  ;; 
  ;; (defun tab-complete-or-next-field ()
  ;;   (interactive)
  ;;   (if (or (not yas/minor-mode)
  ;;           (null (do-yas-expand)))
  ;;       (if corfu--candidates
  ;;           (progn
  ;;             (corfu-insert)
  ;;             (yas-next-field))
  ;;         (yas-next-field))))
  ;; :bind (:map yas-keymap
  ;;             ("<tab>" . tab-complete-or-next-field))
  )

(use-package flymake
  :straight (flymake :type built-in)
  :defer 3
  :init
  (setq-default flymake-diagnostic-functions nil)
  (with-eval-after-load 'flymake-proc
    (remove-hook 'flymake-diagnostic-functions 'flymake-proc-legacy-flymake))
  :config
  (setq flymake-start-on-flymake-mode t
        flymake-start-on-save-buffer t))

(use-package flymake-diagnostic-at-point
  :straight t
  :after flymake
  :hook (flymake-mode . flymake-diagnostic-at-point-mode))

(use-package flyspell
  :straight (flyspell :type built-in)
  :hook (text-mode . flyspell-mode))

;;;###autoload
(defun er/select-text-in-delims ()
  (interactive)
  (let ( $skipChars $p1 )
    (setq $skipChars "^\"'`<>(){}[]??????????")
    (skip-chars-backward $skipChars)
    (setq $p1 (point))
    (skip-chars-forward $skipChars)
    (set-mark $p1)))

(use-package multiple-cursors
  :straight t
  :bind (("C-S-c C-S-c" . mc/edit-lines)
         ("C-<" . mc/mark-next-like-this)
         ("C->" . mc/mark-previous-like-this)
         ("C-c m a" . mc/mark-all-like-this))
  :config
  (setq mc/always-repeat-command t))

(defun my/beginning-of-line ()
  (interactive)
  (if (= (point) (progn (back-to-indentation) (point)))
	  (beginning-of-visual-line)))

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

;;;###autoload
(defun shift-right (count)
  (interactive "p")
  (shift-text count))

;;;###autoload
(defun shift-left (count)
  (interactive "p")
  (shift-text (- count)))

;;;###autoload
(defun my/backward-kill-word ()
  "Smarter C-Backspace control"
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

(defun my/op-thing-at-point (op thing)
  "Get the start and end bounds of a type of thing at point."
  (superword-mode 1)
  (let ((bounds (bounds-of-thing-at-point thing)))
    (if bounds
        (funcall op (car bounds) (cdr bounds))
      (error "No %s at point" thing)))
  (superword-mode -1)
  (global-subword-mode 1))

;;;###autoload
(defun multi-line-next ()
  (interactive)
  (forward-line 10))

;;;###autoload
(defun multi-line-prev ()
  (interactive)
  (forward-line -10))

;; General binds
(global-set-key (kbd "C-x c f") (lambda () (interactive) (find-file "~/.config/emacs/init.el")))
(global-set-key (kbd "C-x c r") (lambda () (interactive) (find-file "~/.config/emacs/org/Roam/")))
(global-set-key (kbd "C-c w") (lambda () (interactive) (my/op-thing-at-point 'copy-region-as-kill 'word)))
(global-set-key (kbd "M-d") (lambda () (interactive) (my/op-thing-at-point 'kill-region 'word)))
(define-key prog-mode-map (kbd "C-a") #'my/beginning-of-line)
(global-set-key (kbd "M-]") #'shift-right)
(global-set-key (kbd "M-[") #'shift-left)
(global-set-key (kbd "M-n") 'forward-paragraph)
(global-set-key (kbd "M-p") 'backward-paragraph)
(global-set-key (kbd "C-M-<backspace>") #'backward-kill-sexp)
(global-set-key (kbd "C-M-<return>") #'vterm)
(global-set-key (kbd "C-S-k") #'kill-whole-line)
(global-set-key (kbd "C-x c e")  #'dashboard-refresh-buffer)
(global-set-key (kbd "C-c o g")  #'xref-find-definitions)
(global-set-key (kbd "C-/")  #'undo-only)
(global-set-key (kbd "C-?")  #'undo-redo)
(global-set-key (kbd "C-S-n")  #'multi-line-next)
(global-set-key (kbd "C-S-p")  #'multi-line-prev)
(global-set-key [remap org-cycle-agenda-files] 'ignore)
(bind-key* "C-<backspace>" #'my/backward-kill-word)


;; unbind annoying keybinds
(global-unset-key  (kbd "C-x C-n"))
(global-unset-key  (kbd "M-`"))
(global-unset-key  (kbd "C-z"))
(global-unset-key  (kbd "C-x C-z"))

(defadvice kill-region (before slick-cut activate compile)
  "When called interactively with no active region, kill a single line instead."
  (interactive
   (if mark-active (list (region-beginning) (region-end))
     (list (save-excursion (back-to-indentation) (point)) (line-end-position)))))

(defadvice kill-ring-save (before slick-copy activate compile)
  "When called interactively with no active region, copy a single line instead."
  (interactive
   (if mark-active (list (region-beginning) (region-end))
     (message "Line Copied")
     (list (save-excursion (back-to-indentation) (point)) (line-end-position)))))

(defadvice kill-line (before kill-line-autoreindent activate)
  "Kill excess whitespace when joining lines.
If the next line is joined to the current line, kill the extra indent whitespace in front of the next line."
  (when (and (eolp) (not (bolp)))
    (save-excursion
      (forward-char 1)
      (just-one-space 1))))

(defun pils-follow (&rest _arg)
  "Advice to follow a function which spawn a window."
  (other-window 1))

(advice-add 'split-window-below :after #'pils-follow)
(advice-add 'split-window-right :after #'pils-follow)

(advice-add 'find-function :before 'better-jumper-set-jump)
(advice-add 'consult-ripgrep :before 'better-jumper-set-jump)
(advice-add 'consult-line :before 'better-jumper-set-jump)

(provide 'my-editing)
