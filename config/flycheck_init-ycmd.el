(require 'ycmd)

(set-variable 'ycmd-server-command
	      (list "python" (expand-file-name "extraBin/ycmd/ycmd" user-emacs-directory)))

(company-ycmd-setup)

(setq request-message-level -1)

(setq company-ycmd-request-sync-timeout 0)

;; (add-hook 'after-init-hook #'global-ycmd-mode)

(provide 'init-ycmd)


