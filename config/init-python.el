(add-hook 'python-mode-hook
	  (lambda()
	    (make-local-variable 'company-backends)
	    (setq indent-tabs-mode t        ;; 禁止空格替换 Tab
		  tab-width 8
		  python-indent-offset 8
		  )
	    (hs-minor-mode 1)
	    ))

(provide 'init-python)
