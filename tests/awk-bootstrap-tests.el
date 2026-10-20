;;; awk-bootstrap-tests.el --- Isolated AWK bootstrap checks -*- lexical-binding: t; -*-
(require 'ert)
(require 'cl-lib)
(require 'seq)
(require 'bytecomp)

(defconst awk-test-root
  (file-name-directory (directory-file-name
                        (file-name-directory (or load-file-name buffer-file-name)))))
(defconst awk-test-forms
  (with-temp-buffer
    (insert-file-contents (expand-file-name "init.local.el" awk-test-root))
    (let (form hook)
      (condition-case nil
          (while (not hook)
            (setq form (read (current-buffer)))
            (when (and (listp form)
                       (equal (seq-take form 2) '(radian-local-on-hook after-init)))
              (setq hook form)))
        (end-of-file (error "Missing after-init hook")))
      (let ((package (cl-position-if
                      (lambda (x) (and (listp x)
                                       (equal (seq-take x 2)
                                              '(radian-use-package awk-ts-mode))))
                      (cddr hook))))
        (unless package (error "Missing AWK declaration"))
        (let ((forms (cl-subseq (cddr hook) (1- package) (1+ package))))
          (unless (eq (caar forms) 'eval-and-compile)
            (error "Bootstrap must immediately precede AWK declaration"))
          forms)))))

(defvar treesit-language-source-alist)
(defvar awk-test-ready)
(defvar awk-test-installs)
(defvar awk-test-enabled)
(defvar awk-test-support)
(defvar awk-test-library)
(defvar awk-test-outcome)
(defvar awk-test-requires)

(defmacro awk-test-isolated (&rest body)
  (declare (indent 0))
  `(let* ((default-directory awk-test-root)
          (temporary-file-directory (expand-file-name "build/" awk-test-root))
          (_ (make-directory temporary-file-directory t))
          (dir (make-temp-file "awk-test-" t))
          (user-emacs-directory (file-name-as-directory dir))
          (process-environment (copy-sequence process-environment))
          (treesit-language-source-alist nil)
          (awk-test-ready nil) (awk-test-installs 0)
          (awk-test-enabled t) (awk-test-support t) (awk-test-library t)
          (awk-test-outcome 'success) (awk-test-requires 0)
          (real-require (symbol-function 'require)))
     (setenv "HOME" dir)
     (unwind-protect
         (cl-letf (((symbol-function 'radian-enabled-p)
                    (lambda (package) (should (eq package 'awk-ts-mode))
                      awk-test-enabled))
                   ((symbol-function 'require)
                    (lambda (feature &optional filename noerror)
                      (if (eq feature 'treesit)
                          (progn (cl-incf awk-test-requires) awk-test-library)
                        (funcall real-require feature filename noerror))))
                   ((symbol-function 'treesit-available-p)
                    (lambda () awk-test-support))
                   ((symbol-function 'treesit-language-available-p)
                    (lambda (language) (should (eq language 'awk)) awk-test-ready))
                   ((symbol-function 'treesit-install-language-grammar)
                    (lambda (language)
                      (should (eq language 'awk))
                      (should (equal (assq 'awk treesit-language-source-alist)
                                     '(awk "https://github.com/Beaglefoot/tree-sitter-awk")))
                      (cl-incf awk-test-installs)
                      (pcase awk-test-outcome
                        ('success (setq awk-test-ready t))
                        ('error (error "stub compiler failed"))))))
           ,@body)
       (delete-directory dir t))))

(defun awk-test-bootstrap ()
  (eval (car awk-test-forms) t))

(ert-deftest awk-bootstrap-existing ()
  (awk-test-isolated
    (setq awk-test-ready t)
    (awk-test-bootstrap)
    (should (= awk-test-installs 0))))

(ert-deftest awk-bootstrap-install-idempotent ()
  (awk-test-isolated
    (awk-test-bootstrap)
    (awk-test-bootstrap)
    (should awk-test-ready)
    (should (= awk-test-installs 1))
    (should (= (length treesit-language-source-alist) 1))))

(ert-deftest awk-bootstrap-disabled ()
  (awk-test-isolated
    (setq awk-test-enabled nil)
    (awk-test-bootstrap)
    (should (= awk-test-requires 0))
    (should (= awk-test-installs 0))
    (should-not treesit-language-source-alist)))

(ert-deftest awk-bootstrap-unsupported ()
  (dolist (missing '(library support))
    (awk-test-isolated
      (if (eq missing 'library) (setq awk-test-library nil)
        (setq awk-test-support nil))
      (should (string-match-p
               "requires Emacs tree-sitter support"
               (error-message-string (should-error (awk-test-bootstrap)))))
      (should (= awk-test-installs 0)))))

(ert-deftest awk-bootstrap-install-failures ()
  (dolist (outcome '(error unavailable))
    (awk-test-isolated
      (setq awk-test-outcome outcome)
      (should (string-match-p
               (if (eq outcome 'error) "AWK grammar installation failed: stub compiler failed"
                 "AWK grammar is unavailable after installation")
               (error-message-string (should-error (awk-test-bootstrap)))))
      (should (= awk-test-installs 1)))))

;; Simulate the package handler loading a dependency during macro expansion,
;; before :init/:preface would run.  The generated require also checks .elc load.
(defmacro radian-use-package (package &rest _args)
  (unless awk-test-ready (error "Package expanded before grammar was ready"))
  (require package)
  `(require ',package))

(ert-deftest awk-bootstrap-runtime-and-compile-order ()
  (dolist (compile-first '(nil t))
    (awk-test-isolated
      (let* ((load-path (cons dir load-path))
             (features (delq 'awk-ts-mode (copy-sequence features)))
             (source (expand-file-name "fixture.el" dir))
             (dependency (expand-file-name "awk-ts-mode.el" dir)))
        (with-temp-file dependency
          (insert "(unless (treesit-language-available-p 'awk)\n"
                  "  (error \"Dependency loaded before grammar was ready\"))\n"
                  "(provide 'awk-ts-mode)\n"))
        (with-temp-file source
          (insert ";;; -*- lexical-binding: t; -*-\n")
          (dolist (form awk-test-forms) (prin1 form (current-buffer)) (insert "\n")))
        (if compile-first
            (progn
              (should (byte-compile-file source))
              (should (featurep 'awk-ts-mode))
              (should (= awk-test-installs 1))
              ;; A fresh runtime must bootstrap too, not just the compiler.
              (setq awk-test-ready nil awk-test-installs 0
                    features (delq 'awk-ts-mode features))
              (load (byte-compile-dest-file source) nil t t))
          (load source nil t t))
        (should awk-test-ready)
        (should (featurep 'awk-ts-mode))
        (should (= awk-test-installs 1))))))
