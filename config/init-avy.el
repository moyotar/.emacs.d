(global-set-key (kbd "C-c SPC") 'avy-goto-char)

;; enable avy jump KB in specific modes
(dolist (hook '(conf-space-mode-hook
		conf-colon-mode-hook
		conf-pdd-mode-hook
		conf-unix-mode-hook
		conf-windows-mode-hook
		conf-xdefaults-mode-hook
		conf-javaprop-mode-hook
		comint-mode-hook
		eshell-mode-hook
		org-mode-hook))
  (add-hook hook (lambda ()
		    (local-set-key (kbd "C-c SPC") 'avy-goto-char))))

(provide 'init-avy)
