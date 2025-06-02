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


;; (setq straight-vc-git-default-protocol ssh)
;; (setq straight-check-for-modifications ...))
(radian-local-on-hook before-straight
  nil)



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
  (radian-use-package vterm)
  (radian-use-package visual-regexp-steroids
    :config
    (setq vr/engine 'pcre))

  (add-to-list 'load-path "/raid/epd/qmcpack/utils/code_tools")
  (add-to-list 'load-path "/raid/epd/DCA-2/tools/emacs")
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

    (put 'c-default-style 'safe-local-variable #'stringp))
  (radian-use-package lsp-ui
    :bind (("s-g" . #'lsp-ui-peek-find-definitions)
           ("s-r" . #'lsp-ui-peek-find-references)
           ("s-i" . #'lsp-ui-peek-find-implementation))

    )
  ;; Support super alphabet combinations for iterm2
  (unless (display-graphic-p)
    (cl-loop for char from ?a to ?z
             do (define-key input-decode-map (format "\e[1;P%c" char) (kbd (format "s-%c" char))))
    (add-hook
     'c++-mode-hook
     (lambda ()
       (local-set-key (kbd "RET") #'c-indent-new-comment-line))
     )
    )
  (when (radian-operating-system-p darwin)
    (setq mac-option-modifier 'super)
    (setq mac-command-modifier 'control)
    (setq mac-control-modifier 'meta)
    (global-set-key [kp-delete] 'delete-char)) ;; sets fn-delete to be right-delete
  )

;; see M-x customize-group RET radian-hooks RET for which hooks you
;; can use with `radian-local-on-hook'
