(require 'projectile)
(projectile-global-mode)
(require 'helm-projectile)
(setq projectile-completion-system 'helm)
(helm-projectile-on)
(setq projectile-indexing-method 'alien)

(defun my-projectile-find-file (arg)
  (interactive "P")
  (if (equal arg '(4))
      (helm-locate-1 '(16) nil nil (thing-at-point 'filename))
    (helm-locate-1 '(4) nil nil (thing-at-point 'filename)))
  )

(define-key projectile-mode-map (kbd "C-c p f") 'my-projectile-find-file)

(provide 'init-projectile)
