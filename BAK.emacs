(add-to-list 'exec-path "/usr/local/bin")
(add-to-list 'exec-path "/Users/epd/.cargo/bin")
(add-to-list 'exec-path "/usr/local/opt/gnu-sed/libexec/gnubin")
(add-to-list 'exec-path "/usr/local/opt/llvm/bin")

(add-to-list 'load-path "/Users/Shared/ornldev/code/qmcpack/utils/code_tools")
(add-to-list 'load-path "/Users/Shared/ornldev/code/DCA-2/tools/emacs")


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

;; key bindings
(when (eq system-type 'darwin) ;; mac specific settings
  (setq mac-option-modifier 'meta)
  (setq mac-command-modifier 'control)
  (setq mac-control-modifier 'meta)
  (global-set-key [home] 'beginning-of-line-text)
  (global-set-key [end] 'move-end-of-line)
)
(global-set-key [kp-delete] 'delete-char) ;; sets fn-delete to be right-delete

;; ;; )


(defun pdoak-find-domain-name ()
  "Reliable way to get current hostname.
`(getenv \"HOSTNAME\")' won't work because $HOSTNAME is NOT an
 environment variable.
`system-name' won't work because /etc/hosts could be modified"
  (with-temp-buffer
    (shell-command "hostname -d" t)
    (goto-char (point-max))
    (delete-char -1)
    (buffer-string)))

(setq use-package-always-defer t)

(defmacro my-safe-init (fn &rest clean-up)
    "Wrap init blocks incase package is not installed on this host.
FN the block
CLEAN-UP what you do on unwind"
    `(unwind-protect
         (let (retval)
           (condition-case err
               (setq retval (progn, fn))
             ('error (message (format "%s" err))))
           )
       ,@clean-up))


(setq package-enable-at-startup nil)

(straight-use-package 'calmer-forest-theme)
(straight-use-package 'clang-format)
(straight-use-package 'cmake-mode)

(straight-use-package 'calmer-forest-theme)
(straight-use-package 'calmer-forest-theme)
(straight-use-package 'magit)

(straight-use-package 'helm)
(straight-use-package 'helm-rg)

(helm-mode 1)

(setq
 helm-scroll-amount 4 ; scroll 4 lines other window using M-<next>/M-<prior>
 helm-ff-search-library-in-sexp t ; search for library in `require' and `declare-function' sexp.
 helm-split-window-in-side-p t ;; open helm buffer inside current window, not occupy whole other window
 helm-candidate-number-limit 50 ; limit the number of displayed canidates
 helm-ff-file-name-history-use-recentf t
 helm-move-to-line-cycle-in-source t ; move to end or beginning of source when reaching top or bottom of source.
 )

(global-set-key (kbd "C-c h") 'helm-command-prefix)

(global-set-key (kbd "M-x") 'helm-M-x)
(global-set-key (kbd "M-y") 'helm-show-kill-ring)
(global-set-key (kbd "C-x b") 'helm-mini)
(global-set-key (kbd "C-x C-f") 'helm-find-files)
(global-set-key (kbd "C-h SPC") 'helm-all-mark-rings)
(global-set-key (kbd "C-c h o") 'helm-occur)

(setq helm-buffers-fuzzy-matching t
      helm-recentf-fuzzy-match    t)

(straight-use-package 'helm-projectile)

;; (projectile-global-mode)
(projectile-mode +1)
(define-key projectile-mode-map (kbd "s-p") 'projectile-command-map)
(define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
(setq projectile-completion-system 'helm)
(helm-projectile-on)

;; (straight-use-package 'visual-regexp)
(straight-use-package 'visual-regexp-steroids)
(require 'visual-regexp-steroids)

(defvar vr-query-replace-history nil)
(defvar vr-query-replace-defaults nil)
(define-key global-map (kbd "C-c v r") 'vr/replace)
(define-key global-map (kbd "C-c v q") 'vr/query-replace)
;; if you use multiple-cursors, this is for you:
;; (define-key global-map (kbd "C-c m") 'vr/mc-mark)
;; to use visual-regexp-steroids's isearch instead of the built-in regexp isearch, also include the following lines:
(define-key esc-map (kbd "C-r") 'vr/isearch-backward) ;; C-M-r
(define-key esc-map (kbd "C-s") 'vr/isearch-forward) ;; C-M-s

(straight-use-package 'vterm)

(defun shell-mode-fish-alternate-config-dir (origfun procname &rest args)
  (if (not (equal procname "shell"))
      (apply origfun procname args)
    (let ((process-environment
       `(,"XDG_CONFIG_HOME=/Users/epd/.config/emacs-fish"
         . ,process-environment)
       ))
    (apply origfun procname args))))

;; "XDG_DATA_HOME=~/.config/emacs-fish/"

(advice-add 'make-comint-in-buffer :around
	    'shell-mode-fish-alternate-config-dir)

;; (defun fish-vterm-directory-tracking ()
;;   (setq dirtrack-list '("^.*.*.* \\(.*?\\) " 1 nil))
;;   (dirtrack-mode 1))

;; (add-hook 'vterm-mode-hook 'fish-vterm-directory-tracking)

(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)
(add-to-list 'comint-output-filter-functions 'ansi-color-process-output)

(straight-use-package 'auctex)
(straight-use-package 'plantuml-mode)
(straight-use-package 'figlet)

(setq-default TeX-master nil)
(setq TeX-auto-save t)
(setq-default TeX-master nil)
(setq TeX-auto-save t)
(setq TeX-parse-self t)
(setq-default TeX-master nil)
(setq TeX-PDF-mode t)

(straight-use-package 'dap-mode)

(dap-mode 1)
(dap-tooltip-mode 1)
(dap-auto-configure-mode 1)
(dap-ui-controls-mode 1)
(require 'dap-lldb)
(dap-ui-mode 1)
(setq dap-auto-configure-features '(sessions locals breakpoints expressions repl controls tooltip))
(setq dap-lldb-debug-program '("lldb-vscode"))

(straight-use-package 'speck)

(my-safe-init
 (progn (require 'qmcpack-style))
        (message "qmcpack-style..."))

(my-safe-init
 (progn (require 'dca-style))
        (message "dca-style..."))

(straight-use-package 'realgud)
(straight-use-package 'realgud-lldb)
(require 'realgud-lldb)

(straight-use-package 'julia-mode)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(LaTeX-command "pdflatex")
 '(TeX-command-list
   '(("pdflatex" "pdflatex" TeX-run-command nil (latex-mode))
     ("TeX"
      "%(PDF)%(tex) %(file-line-error) %`%(extraopts) %S%(PDFout)%(mode)%' %(output-dir) %t"
      TeX-run-TeX nil (plain-tex-mode texinfo-mode ams-tex-mode) :help
      "Run plain TeX")
     ("LaTeX" "%`%l%(mode)%' %T" TeX-run-TeX nil
      (latex-mode doctex-mode) :help "Run LaTeX")
     ("Makeinfo" "makeinfo %(extraopts) %(o-dir) %t" TeX-run-compile
      nil (texinfo-mode) :help "Run Makeinfo with Info output")
     ("Makeinfo HTML" "makeinfo %(extraopts) %(o-dir) --html %t"
      TeX-run-compile nil (texinfo-mode) :help
      "Run Makeinfo with HTML output")
     ("AmSTeX"
      "amstex %(PDFout) %`%(extraopts) %S%(mode)%' %(output-dir) %t"
      TeX-run-TeX nil (ams-tex-mode) :help "Run AMSTeX")
     ("ConTeXt"
      "%(cntxcom) --once --texutil %(extraopts) %(execopts)%t"
      TeX-run-TeX nil (context-mode) :help "Run ConTeXt once")
     ("ConTeXt Full" "%(cntxcom) %(extraopts) %(execopts)%t"
      TeX-run-TeX nil (context-mode) :help
      "Run ConTeXt until completion")
     ("BibTeX" "bibtex %(O?aux)" TeX-run-BibTeX nil
      (plain-tex-mode latex-mode doctex-mode context-mode texinfo-mode
		      ams-tex-mode)
      :help "Run BibTeX")
     ("Biber" "biber %(output-dir) %s" TeX-run-Biber nil
      (plain-tex-mode latex-mode doctex-mode texinfo-mode ams-tex-mode)
      :help "Run Biber")
     ("Texindex" "texindex %s.??" TeX-run-command nil (texinfo-mode)
      :help "Run Texindex")
     ("Texi2dvi" "%(PDF)texi2dvi %t" TeX-run-command nil
      (texinfo-mode) :help "Run Texi2dvi or Texi2pdf")
     ("View" "%V" TeX-run-discard-or-function t t :help "Run Viewer")
     ("Print" "%p" TeX-run-command t t :help "Print the file")
     ("Queue" "%q" TeX-run-background nil t :help
      "View the printer queue" :visible TeX-queue-command)
     ("File" "%(o?)dvips %d -o %f " TeX-run-dvips t
      (plain-tex-mode latex-mode doctex-mode texinfo-mode ams-tex-mode)
      :help "Generate PostScript file")
     ("Dvips" "%(o?)dvips %d -o %f " TeX-run-dvips nil
      (plain-tex-mode latex-mode doctex-mode texinfo-mode ams-tex-mode)
      :help "Convert DVI file to PostScript")
     ("Dvipdfmx" "dvipdfmx -o %(O?pdf) %d" TeX-run-dvipdfmx nil
      (plain-tex-mode latex-mode doctex-mode texinfo-mode ams-tex-mode)
      :help "Convert DVI file to PDF with dvipdfmx")
     ("Ps2pdf" "ps2pdf %f %(O?pdf)" TeX-run-ps2pdf nil
      (plain-tex-mode latex-mode doctex-mode texinfo-mode ams-tex-mode)
      :help "Convert PostScript file to PDF")
     ("Glossaries" "makeglossaries %(d-dir) %s" TeX-run-command nil
      (plain-tex-mode latex-mode doctex-mode texinfo-mode ams-tex-mode)
      :help "Run makeglossaries to create glossary file")
     ("Index" "makeindex %(O?idx)" TeX-run-index nil
      (plain-tex-mode latex-mode doctex-mode texinfo-mode ams-tex-mode)
      :help "Run makeindex to create index file")
     ("upMendex" "upmendex %(O?idx)" TeX-run-index t
      (plain-tex-mode latex-mode doctex-mode texinfo-mode ams-tex-mode)
      :help "Run upmendex to create index file")
     ("Xindy" "texindy %s" TeX-run-command nil
      (plain-tex-mode latex-mode doctex-mode texinfo-mode ams-tex-mode)
      :help "Run xindy to create index file")
     ("Check" "lacheck %s" TeX-run-compile nil (latex-mode) :help
      "Check LaTeX file for correctness")
     ("ChkTeX" "chktex -v6 %s" TeX-run-compile nil (latex-mode) :help
      "Check LaTeX file for common mistakes")
     ("Spell" "(TeX-ispell-document \"\")" TeX-run-function nil t
      :help "Spell-check the document")
     ("Clean" "TeX-clean" TeX-run-function nil t :help
      "Delete generated intermediate files")
     ("Clean All" "(TeX-clean t)" TeX-run-function nil t :help
      "Delete generated intermediate and output files")
     ("Other" "" TeX-run-command t t :help "Run an arbitrary command")))
 '(c-default-style
   '((c-mode . "qmcpack") (c++-mode . "qmcpack") (java-mode . "java")
     (awk-mode . "awk") (other . "gnu")))
 '(compilation-scroll-output 'first-error)
 '(custom-safe-themes
   '("7a424478cb77a96af2c0f50cfb4e2a88647b3ccca225f8c650ed45b7f50d9525"
     "e214cf551a6d5a68e7a0a969ca0f086c0beea95794a199c7325602133a99b7c8"
     default))
 '(dap-internal-terminal 'dap-internal-terminal-vterm)
 '(flyspell-sort-corrections t)
 '(plantuml-default-exec-mode 'executable)
 '(plantuml-executable-path "/usr/local/bin/plantuml")
 '(plantuml-indent-level 4)
 '(plantuml-jar-path "/usr/local/bin/plantuml")
 '(safe-local-variable-values
   '((highlight-80+-columns . 100) (c-default-style . "qmcpack-style")))
 '(speck-aspell-program "/usr/local/bin/hunspell")
 '(speck-hunspell-default-dictionary-name en)
 '(speck-hunspell-dictionary-alist nil)
 '(speck-hunspell-library-directory "/Users/epd/Library/Spelling")
 '(speck-ispell-coding-system 'utf-8)
 '(vr/command-python
   "python3.11 /Users/epd/.emacs.d/straight/build/visual-regexp-steroids/regexp.py")
 '(warning-suppress-log-types '((comp))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :extend nil :stipple nil :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight regular :height 140 :width normal :foundry "nil" :family "Monaco")))))

(add-hook 'LaTeX-mode-hook 'visual-line-mode)
(add-hook 'LaTeX-mode-hook 'flyspell-mode)
(add-hook 'LaTeX-mode-hook 'LaTeX-math-mode)
(setq TeX-auto-save t)
(setq TeX-parse-self t)


