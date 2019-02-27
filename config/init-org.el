(require 'org)
(require 'ox-md)

(setq org-src-fontify-natively t)

(add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))

(define-key org-mode-map (kbd "C-c ;") nil)
(define-key org-mode-map (kbd "C-c .") nil)
(define-key org-mode-map (kbd "C-c t") 'org-time-stamp)

(org-babel-do-load-languages
      'org-babel-load-languages
      '((emacs-lisp . t)
        (lua . t)
	(python . t)
	(shell . t)
	(dot . t)))

(setq org-confirm-babel-evaluate nil)

(provide 'init-org)
