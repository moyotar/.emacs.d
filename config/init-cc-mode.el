(defun my-c-mode-hook ()
  (add-to-list (make-local-variable 'company-backends)
			 '(company-ycmd
			   company-yasnippet
			   )
			 )
  (c-set-offset 'substatement-open 0)
  (setq	c-basic-offset 8          ;; 基本缩进宽度
        indent-tabs-mode t        ;; 禁止空格替换Tab
        default-tab-width 8)      ;; 默认Tab宽度
  
  (local-set-key (kbd "C-c .") 'ace-mc-add-multiple-cursors)
  (setq-local sp-escape-quotes-after-insert nil)
)

(require 'cc-mode)

(define-key c-mode-base-map (kbd "RET") 'c-context-line-break)

(add-hook 'c-mode-hook 'my-c-mode-hook)
(add-hook 'c++-mode-hook 'my-c-mode-hook)

(provide 'init-cc-mode)
