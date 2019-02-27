(defun my-c-mode-hook ()
  (add-to-list (make-local-variable 'company-backends)
			 '(company-yasnippet)
			 )
  (c-set-offset 'substatement-open 0)
  (setq	c-basic-offset 8          ;; 基本缩进宽度
        indent-tabs-mode t        ;; 禁止空格替换Tab
        default-tab-width 8)      ;; 默认Tab宽度
  
  (local-set-key (kbd "C-c .") 'ace-mc-add-multiple-cursors)
  (setq-local sp-escape-quotes-after-insert nil)
  (let ((file-name (buffer-file-name)))
    (if file-name
	(progn
	  (setq file-name (file-name-nondirectory file-name))
	  (let ((out-file (concat (file-name-sans-extension file-name) ".out")))
	    (setq-local compile-command (format "g++ -std=c++14 %s -o %s && ./%s" file-name out-file out-file)))
	  )
	))
)

(require 'cc-mode)

(define-key c-mode-base-map (kbd "RET") 'c-context-line-break)

(add-hook 'c-mode-hook 'my-c-mode-hook)
(add-hook 'c++-mode-hook 'my-c-mode-hook)

(provide 'init-cc-mode)

