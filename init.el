(add-to-list 'load-path (expand-file-name "config" user-emacs-directory))

(setq package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
			 ("popkit" . "http://elpa.popkit.org/packages/")))

;;----------------------------------------------------------------------------
;; Adjust garbage collection thresholds during startup, and thereafter
;;----------------------------------------------------------------------------
(let ((init-gc-cons-threshold (* 128 1024 1024)))
  (setq gc-cons-threshold init-gc-cons-threshold)
  (add-hook 'after-init-hook
            (lambda () (setq gc-cons-threshold (* 50 1024 1024)))))

(require 'init-el-get)
(require 'init-basic)
(require 'init-theme)
(require 'init-cc-mode)
(require 'init-expand-region)
(require 'init-helm)
(require 'init-projectile)
(require 'init-multiple-cursors)
(require 'init-yasnippet)
(require 'init-company)
(require 'init-sml)
(require 'init-dir)
(require 'init-avy)
(require 'init-lua)
(require 'init-rainbow-delimiters)
(require 'init-ahs)
(require 'init-shell)
(require 'init-python)
(require 'init-flycheck)
(require 'init-vlf)
(require 'init-org)
(require 'init-smartparens)

(provide 'init)
;;; init.el ends here

