(defun my-lua-send-file ()
  (interactive)
  (lua-send-string (format "_ = dofile('%s')" buffer-file-name))
  (switch-to-buffer-other-window "*lua*")
  )

(add-hook 'lua-mode-hook
	  (lambda()
	    (add-to-list (make-local-variable 'company-backends)
			 '(company-lua
			   company-yasnippet)
			 )
	    (setq
	     tab-width 8
	     indent-tabs-mode t
	     lua-indent-level 8
	     )
	    (hs-minor-mode 1)))

(provide 'init-lua)
