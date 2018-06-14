(require 'projectile)
(projectile-global-mode)
(require 'helm-projectile)
(setq projectile-completion-system 'helm)
(helm-projectile-on)
(setq projectile-indexing-method 'alien)

(defun my-projectile-find-file (arg)
  (interactive "P")
  (when (and (equal system-type 'windows-nt) (projectile-project-p))
    ;; set helm-locate-command
    ;; Need to replace '/' to '\'. fuck MS!
    (setq helm-locate-command
	  (concat "es -p " (replace-regexp-in-string "/" "\\\\" (projectile-project-root)) " %s %s")))
  (if (equal arg '(4))
      (helm-locate-1 '(16) nil nil (thing-at-point 'filename))
    (helm-locate-1 '(4) nil nil (thing-at-point 'filename)))
  )

(define-key projectile-mode-map (kbd "C-c p f") 'my-projectile-find-file)


(provide 'init-projectile)
