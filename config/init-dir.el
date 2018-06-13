
(require 'dired-x)
(add-hook 'dired-mode-hook '(lambda () (setq dired-omit-mode t)))

(provide 'init-dir)
