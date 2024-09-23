;;; gsp-ts-mode --- Tree-Sitter support for GSP  -*- lexical-binding: t; -*-

;; Copyright © 2024 Thomas Voss

;; Author:   Thomas Voss <mail@thomasvoss.com>
;; Created:  September 2024
;; Keywords: languages tree-sitter
;; URL:      https://git.thomasvoss.com/gsp-ts-mode
;; Version:  1.0.0

;; Permission to use, copy, modify, and/or distribute this software for any
;; purpose with or without fee is hereby granted.
;;
;; The software is provided ‘as is’ and the author disclaims all warranties with
;; regard to this software including all implied warranties of merchantability
;; and fitness.  In no event shall the author be liable for any special, direct,
;; indirect, or consequential damages or any damages whatsoever resulting from
;; loss of use, data or profits, whether in an action of contract, negligence or
;; other tortious action, arising out of or in connection with the use or
;; performance of this software.

;;; Commentary:

;; TODO

;;; Code:

(defcustom gsp-ts-indent-offset 2
  "Number of spaces for each indentation step in `gsp-ts-mode'."
  :version "1.0.0"
  :type 'integer
  :safe 'integerp
  :group 'gsp)

(defvar gsp-ts-font-lock-rules
  '(:language gsp
    :feature delimiter
    (["{" "}"] @font-lock-bracket-face)

    :language gsp
    :feature operator
    (["@" "-" "="] @font-lock-operator-face)

    :language gsp
    :feature tag
    ((node name: (ident) @font-lock-function-call-face))

    :language gsp
    :feature attribute
    ([(id_attr) (class_attr)] @font-lock-constant-face)

    :language gsp
    :feature attribute
    ((attr name: (ident) @font-lock-constant-face))

    :language gsp
    :feature string
    ((string) @font-lock-string-face)

    :language gsp
    :override t
    :feature comment
    ((comment) "/" @font-lock-comment-delimiter-face)

    :language gsp
    :override t
    :feature comment
    ((comment (_) @font-lock-comment-face)))
  "Font lock rules for `gsp-ts-mode'.  These settings are passed directly to `treesit-font-lock-rules'.

See the documentation for `treesit-font-lock-rules' for more information.")

(defvar gsp-ts-indent-rules
  `((gsp
     ((parent-is "document") column-0 0)
     ((node-is "}") parent-bol 0)
     ((node-is "attr_list") parent gsp-ts-indent-offset)
     ((node-is ,(regexp-opt '("attr" "id_attr" "class_attr"))) first-sibling 0)
     ;; The node is nested not in another node, but in a node body
     ((parent-is "node_body") grand-parent gsp-ts-indent-offset)
     ((parent-is "text") parent-bol 0)
     (catch-all parent 0)
     (no-node parent 0)))
  "Indentation rules for `gsp-ts-mode'.  These settings are assigned directly to `treesit-simple-indent-rules'.

See the documentation for `treesit-simple-indent-rules' and
`treesit-simple-indent-presets' for more information.")

(defun gsp-ts--setup ()
  "Setup tree-sitter for `gsp-ts-mode'."
  (setq-local
   treesit-font-lock-settings (apply #'treesit-font-lock-rules
                                     gsp-ts-font-lock-rules)
   treesit-simple-indent-rules gsp-ts-indent-rules
   treesit-font-lock-feature-list '((comment string)
                                    (tag attribute)
                                    (operator)
                                    (delimiter)))
  (treesit-major-mode-setup))

;;;###autoload
(define-derived-mode gsp-ts-mode prog-mode "GSP"
  "Major mode for editing GSP, powered by Tree-Sitter.

\\<gsp-ts-mode-map>"
  :group 'gsp
  (setq-local font-lock-defaults nil)
  (unless (treesit-ready-p 'gsp)
    (error "Tree-Sitter for GSP isn’t available"))
  (treesit-parser-create 'gsp)
  (gsp-ts--setup))

(unless (treesit-available-p)
  (error "Tree-Sitter support is required for `gsp-ts-mode'"))
(require 'treesit)
(when (treesit-ready-p 'gsp)
  (add-to-list 'auto-mode-alist '("\\.gsp\\'" . gsp-ts-mode)))

(provide 'gsp-ts-mode)
;;; gsp-ts-mode.el ends here
