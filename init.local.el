:;; placeholder init.local.el
;; code that should be run at the very beginning of init, e.g.

;; (setq radian-font ...)
;; (setq radian-font-size ...)

;; (radian-local-on-hook before-straight

;; code that should be run right before straight.el is bootstrapped,
;; e.g.

(setq radian-disabled-packages
      '(haskell-mode
        emacsql-sqlite
        forge))


;; (setq straight-vc-git-default-protocol ...)
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
                ("/" . #'my/vertico-insert)))

  ;; Configure directory extension.
  (radian-use-package vertico-directory
    :after vertico
    :ensure t
    :demand
    ;; More convenient directory navigation commands
    :bind (:map vertico-map
                ("RET"   . vertico-directory-enter)
                ("DEL"   . vertico-directory-delete-char)
                ("M-DEL" . vertico-directory-delete-word))
    ;; Tidy shadowed file names
    :hook (rfn-eshadow-update-overlay . vertico-directory-tidy))
  (setq make-backup-files t)
  (setq auto-save-default t)
  (setq create-lockfiles t))
;; see M-x customize-group RET radian-hooks RET for which hooks you
;; can use with `radian-local-on-hook'
