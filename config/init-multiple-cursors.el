;;; multiple-cursors-config

(require 'multiple-cursors)

(global-set-key (kbd "C-S-c C-S-c")
		'mc/mark-all-in-region-regexp)

(global-set-key (kbd "C-c m n")
		'mc/mark-next-like-this)

(global-set-key (kbd "C-c m p")
		'mc/mark-previous-like-this)

(global-set-key (kbd "C-c m m")
		'mc/mark-all-like-this)

(global-set-key (kbd "C-c .") 'ace-mc-add-multiple-cursors)


(provide 'init-multiple-cursors)
