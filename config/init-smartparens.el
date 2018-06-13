
(require 'smartparens-config)
(eval-after-load 'smartparens-config '(progn
					(sp-use-paredit-bindings)
					(message "Finished use paredit key bindings.")))

(smartparens-global-mode t)
(sp-local-pair 'prog-mode "{" nil :post-handlers '(("||\n[i]" "RET")))

(provide 'init-smartparens)
