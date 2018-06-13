
(require 'shell)

(defun clear-shell ()
  (interactive)
  (let ((comint-buffer-maximum-size 0))
    (comint-truncate-buffer)))

(add-hook 'shell-mode-hook
	  (lambda ()
	    (shell-dirtrack-mode 0) ;stop the usual shell-dirtrack mode
	    (set-variable 'dirtrack-list '("^\\(.*@.*:\\)?\\(.*\\)[$#] $" 2 nil)) ; pattern depends on $PS1
	    (dirtrack-mode))
	  )

(define-key shell-mode-map (kbd "C-c c b") 'clear-shell)

(setq sh-basic-offset 8 sh-indentation 8)

(provide 'init-shell)
