(add-to-list 'load-path "~/.emacs.d/el-get/el-get")

(unless (require 'el-get nil 'noerror)
  (require 'package)
  (package-refresh-contents)
  (package-initialize)
  (package-install 'el-get)
  (require 'el-get))

;; Note: Need to update my-packages's value after installed a new package every time.
(setq my-packages
      '(ace-jump-mode ace-mc ample-regexps anaphora auto-highlight-symbol avy bash-completion cl-lib color-theme-zenburn company-lua company-mode dash deferred el-get emacs-async emacs-ycmd epl expand-region f flycheck fold-this ghub helm helm-ag helm-gtags helm-projectile helm-smex json-mode json-reformat json-snatcher let-alist lua-mode magit magit-popup markdown-mode multiple-cursors nav-flash org-bullets package paredit pkg-info popup projectile rainbow-delimiters request rich-minority s seq smart-mode-line smartparens smex vlfi with-editor yasnippet yasnippet-snippets))

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
