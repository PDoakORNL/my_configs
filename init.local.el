;; -*- lexical-binding: t; -*-
:;; placeholder init.local.el
;; code that should be run at the very beginning of init, e.g.

;; (setq radian-font ...)
;; (setq radian-font-size ...)

;; (radian-local-on-hook before-straight

;; code that should be run right before straight.el is bootstrapped,
;; e.g.

(setq radian-disabled-packages
      '(haskell-mode
        lsp-haskel
        emacsql-sqlite
        forge))

(setq radian-env-setup nil)
;; (setq straight-vc-git-default-protocol ssh)
;; (setq straight-check-for-modifications ...))
(radian-local-on-hook before-straight
  (setq straight-recipes-gnu-elpa-use-mirror t)
  ;; (setq straight-check-for-modifications t)
  )

(radian-local-on-hook after-init
  ;; code that should be run at the end of init, e.g.
  (radian-use-package vertico
    :ensure t
    :demand
    :config
    (setq vertico-cycle t)
    ;; currently requires melpa version of vertico
    (setq vertico-preselect 'directory)
    :init
    (vertico-mode)
    (defun my/vertico-insert ()
      (interactive)
      (let* ((mb (minibuffer-contents-no-properties))
             (lc (if (string= mb "") mb (substring mb -1))))
        (cond ((string-match-p "^[/~:]" lc) (self-insert-command 1 ?/))
              ((file-directory-p (vertico--candidate)) (vertico-insert))
              (t (self-insert-command 1 ?/)))))
    :bind (:map vertico-map
                ;;                ("/" . #'vertico-insert)
                ("?" . #'minibuffer-completion-help)
                ("M-RET" . #'minibuffer-force-complete-and-exit)
                ("M-TAB" . #'minibuffer-complete)))

  ;; Configure directory extension.
  (setq make-backup-files t)
  (setq auto-save-default t)
  (setq create-lockfiles t)
  (radian-use-package vterm
    :config
    (define-key vterm-mode-map (kbd "C-q") #'vterm-send-next-key)
    (define-key vterm-mode-map (kbd "<home>")
                (lambda () (interactive) (vterm-send-string "\033[H")))
    (define-key vterm-mode-map (kbd "<end>")
                (lambda () (interactive) (vterm-send-string "\033[F")))
    (setq vterm-copy-exclude-prompt t)
    (setq vterm-copy-mode-remove-fake-newlines t)
    )
  (radian-use-package visual-regexp-steroids
    :config
    (setq vr/engine 'pcre))

  (cond ((radian-operating-system-p macOS)
         (add-to-list 'load-path "/Users/Shared/ornldev/code/qmcpack/utils/code_tools")
         (add-to-list 'load-path "/Users/Shared/ornldev/code/DCA-2/tools/emacs"))
        (t (add-to-list 'load-path "/raid/epd/qmcpack/utils/code_tools")
           (add-to-list 'load-path "/raid/epd/DCA-2/tools/emacs")))
  (require 'qmcpack-style)
  (require 'dca-style)
  ;;  (require 'mrpapp-style)
  (use-feature cc-mode
    :config
    (radian-defadvice radian--advice-inhibit-c-submode-indicators (&rest _)
      :override #'c-update-modeline
      "Unconditionally inhibit CC submode indicators in the mode lighter.")

    ;; This style is only used for languages which do not have
    ;; a more specific style set in `c-default-style'.
    (setf (map-elt c-default-style 'other) "qmcpack")
    (put 'c-default-style 'safe-local-variable #'stringp)
    ;; (add-to-list 'sp-ignore-modes-list #'c-mode)
    ;; (add-to-list 'sp-ignore-modes-list #'c++-mode)
    (add-hook
     'c++-mode-hook
     (lambda ()
       (local-set-key (kbd "M-RET") #'c-indent-new-comment-line)
       (sp-local-pair 'c++-mode "\"" nil :when '(sp-point-before-eol-p))
       (sp-local-pair 'c++-mode "/*" "*/" :actions '(:rem navigate autoskip) :post-handlers nil)
       (sp-local-pair 'c++-mode "(" nil :when '(sp-point-before-eol-p))
       (sp-local-pair 'c++-mode "{" nil :when '(sp-point-before-eol-p))
       (electric-pair-mode -1))
     )
    )
  (radian-use-package lsp-ui
    :bind (("s-g" . #'lsp-ui-peek-find-definitions)
	   ("s-r" . #'lsp-ui-peek-find-references)
	   ("s-i" . #'lsp-ui-peek-find-implementation))
    )

  ;; (radian-use-package ts-mode)
  (radian-use-package awk-ts-mode
    :straight (:host github :repo "nverno/awk-ts-mode")
    :config (add-to-list 'treesit-language-source-alist
                         '(awk "https:/github.com/Beaglefoot/tree-sitter-awk"))
    )
  ;; (radian-use-package llvm-ts-mode)
  ;; (radian-use-package perl-ts-mode)
  ;; (radian-use-package julia-ts-mode
  ;;   :ensure t
  ;;   :mode "\\.jl$")
  ;; (radian-use-package elisp-tree-sitter)

  (radian-use-package cmake-format
    :straight (:host github :repo "simonfxr/cmake-format.el")
    :config (setq cmake-format-command "/raid/epd/spack/opt/spack/linux-skylake_avx512/python-venv-1.0-wrt32qougdv3znh6uenxavhttyk3ttcg/bin/cmake-format"
                  cmake-format-args '("-i")))

  ;; Support super alphabet combinations for iterm2
  (unless (display-graphic-p)
    (cl-loop for char from ?a to ?z
             do (define-key input-decode-map (format "\e[1;P%c" char) (kbd (format "s-%c" char))))
    )
  (when (radian-operating-system-p darwin)
    (setq mac-command-modifier 'control)
    (setq mac-control-modifier 'meta)
    (setq mac-option-modifier 'super)
    (global-set-key [kp-delete] 'delete-char)
    (global-set-key [home] 'beginning-of-line-text)
    (global-set-key [end] 'move-end-of-line)) ;; sets fn-delete to be
  ;; right-delete

  (use-package org
    :bind(:map org-mode-map
               ("C-S-<left>" . #'org-shiftleft)
               ("C-S-<right>" . #'org-shiftright))
    :config
    (setq org-clock-idle-time 10)
    (setq org-clock-continuously t))
  (cond ((string-match "sdgx-server" (system-name)) (straight-use-package 'llm)
         (radian-use-package ellama
           :ensure t
           :bind ("C-c e" . ellama)
           ;; send last message in chat buffer with C-c C-c
           :hook (org-ctrl-c-ctrl-c-final . ellama-chat-send-last-message)
           :init
           ;; setup key bindings
           ;; (setopt ellama-keymap-prefix "C-c e")
           ;; language you want ellama to translate to
           (setopt ellama-language "English")
           ;; customize display buffer behaviour
           ;; see ~(info "(elisp) Buffer Display Action Functions")~
           (setopt ellama-chat-display-action-function #'display-buffer-full-frame)
           (setopt ellama-instant-display-action-function #'display-buffer-at-bottom)
           :config
           ;; could be llm-openai for example                                                       (require 'llm-openai)
           (require 'llm-openai)
           (setopt ellama-provider
  	           (make-llm-openai-compatible
  	            ;; this model should be pulled to use it
  	            ;; value should be the same as you print in terminal during pull
  	            :url "http://127.0.0.1:8080"
                    :chat-model "Qwen3-Coder-480B-A35B-Instruct"))
           ;; show ellama context in header line in all buffers
           (ellama-context-header-line-global-mode +1)
           ;; show ellama session id in header line in all buffers
           (ellama-session-header-line-global-mode +1))))

  (defun guess-all-hooks ()
    "Return a list of all variables that are probably hook lists."
    (let ((syms '()))
      (mapatoms
       (lambda (sym)
         (if (ignore-errors (symbol-value sym))
             (let ((name (symbol-name sym)))
               (when (string-match "-hook\\(s\\)?\\|functions$" name)
                 (push sym syms))))))
      syms))

  (defun face-it (str face)
    "Apply FACE to STR and return."
    (propertize str 'face face))

  (defun describe-hook (hook)
    "Display documentation about a hook variable and the
functions it contains."
    (interactive
     (list (completing-read
            "Hook: " (mapcar (lambda (x) (cons x nil)) (guess-all-hooks)))))
    (let* ((sym (intern hook))
           (sym-doc (documentation-property sym 'variable-documentation))
           (hook-docs (mapcar
                       (lambda (func)
                         (cons func (ignore-errors (documentation func))))
                       (symbol-value sym))))
      (switch-to-buffer
       (with-current-buffer (get-buffer-create "*describe-hook*")
         (let ((inhibit-read-only t))
           (delete-region (point-min) (point-max))
           (insert (face-it "Hook: " 'font-lock-constant-face) "\n\n")
           (insert (face-it (concat "`" hook "'") 'font-lock-variable-name-face))
           ;; FROM-STRING TO-STRING &optional delimited start end
           ;; backward regiond-non-contiguous-p
           ;; (replace-string "\n" "\n\t" nil
           ;;                 (point)
           ;;                 (save-excursion
           ;;                   (insert "\n" sym-doc "\n\n")
           ;;                   (1- (point))))
           (perform-replace "\n" "\n\t" nil nil nil nil nil
                            (point)
                            (save-excursion
                              (insert "\n" sym-doc "\n\n")
                              (1- (point))))
           (goto-char (point-max))
           (insert (face-it "Hook Functions: " 'font-lock-constant-face) "\n\n")
           (dolist (hd hook-docs)
             (insert (face-it (concat "`" (symbol-name (car hd)) "'")
                              'font-lock-function-name-face)
                     ": \n\t")
             (perform-replace "\n" "\n\t" nil nil nil nil nil
                              (point)
                              (save-excursion
                                (insert (or (cdr hd) "No Documentation") "\n\n")
                                (1- (point))))
             (goto-char (point-max))))
         (help-mode)
         (help-make-xrefs)
         (read-only-mode t)
         (setq truncate-lines nil)
         (current-buffer)))))
  )


;; see M-x customize-group RET radian-hooks RET for which hooks you
;; can use with `radian-local-on-hook'
