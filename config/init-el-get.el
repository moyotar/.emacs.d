(add-to-list 'load-path "~/.emacs.d/el-get/el-get")

(unless (require 'el-get nil 'noerror)
  (with-current-buffer
      (url-retrieve-synchronously
       "https://raw.githubusercontent.com/dimitri/el-get/master/el-get-install.el")
    (goto-char (point-max))
        (eval-print-last-sexp)))

;; Note: Need to update my-packages's value after installed a new package every time.
;;  `(setq my-packages ',(mapcar #'el-get-as-symbol (el-get-list-package-names-with-status "installed")))
(setq my-packages
      '(ace-jump-mode ace-mc ample-regexps anaphora auto-highlight-symbol avy bash-completion cl-lib color-theme-zenburn company-lua company-mode dash deferred el-get emacs-async epl expand-region f flycheck fold-this ghub graphql helm helm-ag helm-gtags helm-projectile helm-smex htmlize json-mode json-reformat json-snatcher let-alist lua-mode magit magit-popup markdown-mode multiple-cursors nav-flash org-bullets package paredit pkg-info popup projectile rainbow-delimiters request rich-minority s seq smart-mode-line smartparens smex treepy vlfi with-editor yasnippet yasnippet-snippets))

(when (equal system-type 'gnu/linux)
  (setq my-packages (append my-packages '(bash-completion))))

(el-get 'sync my-packages)

(custom-set-variables
 '(safe-local-variable-values
   (quote
    ((eval ignore-errors "Write-contents-functions is a buffer-local alternative to before-save-hook"
	   (add-hook
	    (quote write-contents-functions)
	    (lambda nil
	      (delete-trailing-whitespace)
	      nil))
	   (require
	    (quote whitespace))
	   "Sometimes the mode needs to be toggled off and on."
	   (whitespace-mode 0)
	   (whitespace-mode 1))
     (whitespace-style face tabs trailing lines-tail)))))

(provide 'init-el-get)
