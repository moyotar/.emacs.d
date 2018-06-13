;; smart mode line
(setq sml/no-confirm-load-theme t)
(setq sml/theme 'respectful) ;; or 'dark
(add-hook 'after-init-hook #'sml/setup)

(provide 'init-sml)
