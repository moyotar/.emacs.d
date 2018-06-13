;;; auto-highlight-symbol
(setq auto-highlight-symbol-mode-map
      (let ((map (make-sparse-keymap)))
	(define-key map (kbd "C-M-r"    ) 'ahs-backward		)
	(define-key map (kbd "C-M-s"	) 'ahs-forward		)
	(define-key map (kbd "M--"      ) 'ahs-back-to-start    )
	(define-key map (kbd "C-x C-'"  ) 'ahs-change-range     )
	(define-key map (kbd "C-x C-a"  ) 'ahs-edit-mode        )
	map))

(global-auto-highlight-symbol-mode)

(setq ahs-idle-interval 0.5)

(setq ahs-default-range 'ahs-range-whole-buffer)

(provide 'init-ahs)
