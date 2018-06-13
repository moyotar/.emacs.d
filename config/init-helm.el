(require 'helm)
(helm-mode 1)
(setq helm-follow-mode-persistent t)
(global-set-key (kbd "C-x C-f") 'helm-find-files)
(global-set-key (kbd "C-x b") 'helm-mini)

(require 'helm-ag)
(setq helm-ag-insert-at-point nil)
(global-set-key (kbd "C-c s") 'helm-ag-this-file)

(require 'helm-smex)
(global-set-key [remap execute-extended-command] #'helm-smex)
(global-set-key (kbd "M-X") #'helm-smex-major-mode-commands)

(require 'helm-gtags)
(setq helm-gtags-ignore-case t
      helm-gtags-auto-update t
      helm-gtags-use-input-at-cursor t
      helm-gtags-pulse-at-cursor t
      helm-gtags-prefix-key "\C-c g"
      helm-gtags-suggested-key-mapping t
      )

(define-key helm-gtags-mode-map (kbd "C-c g a") 'helm-gtags-tags-in-this-function)
(define-key helm-gtags-mode-map (kbd "M-.") 'helm-gtags-dwim)
(define-key helm-gtags-mode-map (kbd "M-,") 'helm-gtags-pop-stack)
(define-key helm-gtags-mode-map (kbd "C-c <") 'helm-gtags-previous-history)
(define-key helm-gtags-mode-map (kbd "C-c >") 'helm-gtags-next-history)

(dolist (hook '(dired-mode-hook eshell-mode-hook c-mode-hook
				c++-mode-hook python-mode-hook
				lua-mode-hook))
  (add-hook hook 'helm-gtags-mode)
  )


(provide 'init-helm)
