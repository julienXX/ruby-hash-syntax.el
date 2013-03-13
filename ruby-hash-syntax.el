;;; ruby-hash-syntax.el --- Convert ruby hash syntax to 1.9

;; Copyright (C) 2013 Julien Blanchard <julien@sideburns.eu>

;; Licensed under the same terms as Emacs.

;; Keywords: ruby hash syntax
;; Created: 13 March 2013
;; Author: Julien Blanchard <julien@sideburns.eu>
;; Version: 0.0.1

;; This file is NOT part of GNU Emacs.

;;; Commentary:

;;; Installation

;; $ cd ~/.emacs.d/vendor
;; $ git clone git://github.com/julienXX/ruby-hash-syntax.el.git
;;
;; In your Emacs config:
;;
;; (add-to-list 'load-path "~/.emacs.d/vendor/ruby-hash-syntax.el")
;; (require 'ruby-hash-syntax)

;;; Code:

(defvar *ruby-hash-syntax-project-roots*
  '("Gemfile" "Rakefile" "config.ru")
  "The presence of any file/directory in this list indicates a project root.")

(defvar *ruby-hash-syntax-project-root* nil
  "Used internally to cache the project root.")

(defun ruby-hash-syntax-project-root ()
  "Returns the current project root."
  (when (or
         (null *ruby-hash-syntax-project-root*)
         (not (string-match *ruby-hash-syntax-project-root* default-directory)))
    (let ((root (ruby-hash-syntax-find-project-root)))
      (if root
          (setq *ruby-hash-syntax-project-root* (expand-file-name (concat root "/")))
        (setq *ruby-hash-syntax-project-root* nil))))
  *ruby-hash-syntax-project-root*)

(defun root-match(root names)
  (member (car names) (directory-files root)))

(defun root-matches(root names)
  (if (root-match root names)
      (message
      (root-match root names)
    (if (eq (length (cdr names)) 0)
        'nil
      (root-matches root (cdr names))
      )))

(defun ruby-hash-syntax-find-project-root (&optional root)
  "Determines the current project root by recursively searching for an indicator."
  (when (null root) (setq root default-directory))
  (cond
   ((root-matches root *ruby-hash-syntax-project-roots*)
    (expand-file-name root))
   ((equal (expand-file-name root) "/") nil)
   (t (ruby-hash-syntax-find-project-root (concat (file-name-as-directory root) "..")))))

(defun ruby-hash-syntax-convert-file ()
  "Convert current buffer ruby hash syntax to 1.9.
This command calls syntax_fix ruby gem."
  (interactive)
  (let* (
         (fName (buffer-file-name))
         (fSuffix (file-name-extension fName))
         )
    (when (buffer-modified-p)
      (progn
        (when (y-or-n-p "Buffer modified.  Do you want to save first? ")
          (save-buffer))))

    (if (or (string-equal fSuffix "rb") (string-equal fSuffix "haml") (string-equal fSuffix "erb") (string-equal fSuffix "rake") )
        (progn
          (shell-command (format "syntax_fix -p %s" fName))
          (revert-buffer  "IGNORE-AUTO" "NOCONFIRM" "PRESERVE-MODES")
          (message "Syntax conversion finished"))
      (progn
        (error "File 「%s」 doesn't end in '.rb', '.erb', '.rake' or '.haml'" fName)
        )
      )))

(defun ruby-hash-syntax-convert-project ()
  "Convert current project ruby hash syntax to 1.9.
This command calls syntax_fix ruby gem."
  (interactive)
  (when (buffer-modified-p)
    (progn
      (when (y-or-n-p "Buffer modified.  Do you want to save first? ")
        (save-buffer))))

  (if (not (null (ruby-hash-syntax-project-root)))
      (progn
        (shell-command (format "syntax_fix -p %s" (ruby-hash-syntax-project-root)))
        (revert-buffer  "IGNORE-AUTO" "NOCONFIRM" "PRESERVE-MODES")
        (message "Syntax converted in the project"))
    (progn
      (error "Looks like you're not in a Ruby project")
      )
    ))

(provide 'ruby-hash-syntax)
;;; ruby-hash-syntax.el ends here
