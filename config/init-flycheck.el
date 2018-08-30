(require 'flycheck)

;; Do not highlight anything at all.
;; See check results by left fringe
(setq flycheck-highlighting-mode nil)

(add-hook 'prog-mode-hook #'global-flycheck-mode)

(provide 'init-flycheck)
