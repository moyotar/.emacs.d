
(require 'smartparens-config)
(eval-after-load 'smartparens-config '(progn
					(sp-use-paredit-bindings)
					(dolist (key '("M-<up>" "M-<down>" "C-<right>"
						       "C-<left>" "C-M-<left>" "C-M-<right>"))
					  (define-key smartparens-mode-map (kbd key) nil))
					(message "Finished use paredit key bindings.")))

(smartparens-global-mode t)
(sp-local-pair 'prog-mode "{" nil :post-handlers '(("||\n[i]" "RET")))

(provide 'init-smartparens)
