;; -*- lexical-binding: t; -*-
(setq gc-cons-threshold (* 100 1024 1024))

(add-to-list 'load-path (expand-file-name "config" user-emacs-directory))
(add-to-list 'load-path "~/.emacs.d/el-get/el-get")

(setq frame-title-format
      (list
       '(buffer-file-name "%f" (dired-directory dired-directory "%b"))
       " @moyotar"))

;; 显示行号和列号
(global-display-line-numbers-mode 1)
(column-number-mode 1)
(setq linum-format "%4d ")

;; 关闭启动帮助画面
(setq inhibit-splash-screen 1)

(setq inhibit-compacting-font-caches t)

;; 更改光标
(setq-default cursor-type 'box)

;; 快速打开配置文件
(defun open-init-file()
  (interactive)
  (find-file "~/.emacs.d/init.el"))
;; 这一行代码，将函数 open-init-file 绑定到 <f2> 键上
(global-set-key (kbd "<f2>") 'open-init-file)

;; 全屏启动

(setq initial-frame-alist (quote ((fullscreen . maximized))))

(menu-bar-mode -1)
(if (display-graphic-p)
    (progn
      (tool-bar-mode -1)
      (scroll-all-mode -1)
      (toggle-scroll-bar -1)))

(add-hook 'horizontal-scroll-bar-mode-hook (lambda ()  (setq horizontal-scroll-bar nil)))

;;选中时输入自动删除选中
(delete-selection-mode 1)

(defun switch-whitespace-mode()
  (interactive)
  (whitespace-mode 'toggle)
  )

(global-set-key (kbd "<f6>") 'switch-whitespace-mode)

(fset 'yes-or-no-p 'y-or-n-p)

(define-coding-system-alias 'GB18030 'gb18030)
(prefer-coding-system 'gbk)
(define-coding-system-alias 'UTF-8 'utf-8)
(prefer-coding-system 'utf-8)
(setq file-name-coding-system 'UTF-8-unix)
(setq load-prefer-newer t)

;; close backup
(setq make-backup-files nil)

(setq vc-log-show-limit 100)

(defadvice text-scale-increase (around all-buffers (arg) activate)
  (dolist (buffer (buffer-list))
    (with-current-buffer buffer
      ad-do-it)))

(setq read-process-output-max (* 1024 1024))

(cond
 ((equal 'darwin system-type)
  (set-face-attribute
   'default nil
   :font (font-spec :name "Monaco"
                    :size 18.0))

  (dolist (charset '(kana han symbol cjk-misc bopomofo))
    (set-fontset-font
     (frame-parameter nil 'font)
     charset
     (font-spec :name "Hiragino Sans GB")))

  (setq face-font-rescale-alist '(("Hiragino Sans GB" . 1.2))))

 ((equal 'windows-nt system-type)
  (server-start)
  (when (member "Source Code Pro" (font-family-list))
    (set-face-attribute
     'default nil
     :font (fontspec :family "Source Code Pro"
                     :weight 'normal
                     :slant 'normal
                     :size 16.0)))
  (dolist (charset '(kana han symbol cjk-misc bopomofo))
    (set-fontset-font
     (frame-parameter nil 'font)
     charset
     (font-spec :family "新宋体"
		:weight 'normal
		:slant 'normal
		))
    )
  (setq face-font-rescale-alist '(("新宋体" . 1.2))))
 )

(setq source-directory (expand-file-name "emacs-source" user-emacs-directory))

(defun my-compile()
  (interactive)
  (let ((command (eval compile-command)))
    (if (or compilation-read-command current-prefix-arg)
	(setq command (compilation-read-command command)))
    (compile command t))
  ;; after first compile, don't need to confirm next time
  (setq-local compilation-read-command nil))

(global-set-key (kbd "<f5>") 'my-compile)

;; ====================== package config begin ======================

(unless (require 'el-get nil 'noerror)
  (with-current-buffer
      (url-retrieve-synchronously
       "https://raw.githubusercontent.com/dimitri/el-get/master/el-get-install.el")
    (goto-char (point-max))
    (eval-print-last-sexp)))

(add-to-list 'el-get-recipe-path (expand-file-name "el-get-recipes" user-emacs-directory))

;; Note: Need to update my-packages's value after installed a new package every time.
;; ielm: `(setq my-packages ',(mapcar #'el-get-as-symbol (el-get-list-package-names-with-status "installed")))
(setq my-packages
      '(ace-jump-mode ace-mc ace-window ample-regexps anaphora autothemer avy bash-completion cl-lib cmake-mode color-theme-zenburn company-lua company-mode dash deferred el-get emacs-async emacs-theme-gruvbox epl expand-region f flycheck fold-this ghub graphql helm helm-ag helm-gtags helm-projectile helm-rg helm-smex helm-xref highlight-symbol ht htmlize hydra json-mode json-reformat json-snatcher let-alist lsp-mode lua-mode magit magit-popup markdown-mode multiple-cursors nav-flash org-bullets package paredit pkg-info popup powerline projectile rainbow-delimiters request rich-minority rmsbolt s seq smart-mode-line smartparens smex spinner transient treepy use-package vlfi with-editor yasnippet yasnippet-snippets))

(when (equal system-type 'gnu/linux)
  (setq my-packages (append my-packages '(bash-completion))))

(when (equal system-type 'darwin)
  ;;; I prefer cmd key for meta
    (setq mac-option-key-is-meta nil
	  mac-command-key-is-meta t
	  mac-command-modifier 'meta
	  mac-option-modifier 'none
	  my-packages (append my-packages '(exec-path-from-shell))
	  )
  )

(el-get 'sync my-packages)

(eval-when-compile
  (require 'use-package))

(require 'bind-key)

(setq use-package-verbose t)

(defun use-package-handler/:defer (name _keyword arg rest state)
	(let ((body (use-package-process-keywords name rest state)))
	  (use-package-concat
	   (if (or (numberp arg) (listp arg))
	     `((run-with-idle-timer ,arg nil #'require
				    ',(use-package-as-symbol name) nil t)))
	   (if (or (not arg) (null body))
               body
	     `((eval-after-load ',name ',(macroexp-progn body)))))))

(let ((defer-time (if (equal 'windows-nt system-type) 1.5 0.5))
      (delta (if (equal 'windows-nt system-type) 0.4 0.2)))
  (defun use-package-defer-time () (setq defer-time (+ defer-time delta))))

(use-package helm
  :bind
  (("C-x C-f" . helm-find-files)
   ("C-x b" . helm-mini)
   ("C-c s" . helm-occur)
   )
  
  :config
  (helm-mode 1)
  (setq helm-follow-mode-persistent t)
  (setq helm-minibuffer-history-must-match nil)
  )

(use-package helm-smex
  :config
  (global-set-key [remap execute-extended-command] #'helm-smex)
  (global-set-key (kbd "M-X") #'helm-smex-major-mode-commands)
  )

(use-package projectile
  :init  
  (setq projectile-keymap-prefix (kbd "C-c p"))
  
  :config
  (projectile-global-mode)
  (setq projectile-completion-system 'helm)
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
    (if (string-match "-p" helm-locate-command)
	(setq helm-locate-command nil))
    )

  (define-key projectile-mode-map (kbd "C-c p f") 'my-projectile-find-file)
  
  :defer (use-package-defer-time))

(use-package helm-projectile
  :config
  (setq projectile-completion-system 'helm)
  (helm-projectile-on)
  
  :defer (use-package-defer-time)
  )

;; 括号匹配
(use-package paren
  :config
  (show-paren-mode)
  (setq show-paren-style 'parenthesis)
  :defer (use-package-defer-time)
  )

(when (equal system-type 'darwin)
  (use-package exec-path-from-shell
    :config
    (exec-path-from-shell-initialize)
    :defer (use-package-defer-time)
    )
  )

(use-package desktop
  :config
  (setq desktop-path (list "~/.emacs.d/desktop/"))
  (desktop-save-mode 1)
  )

(use-package ansi-color
  :config
  (setq ansi-color-names-vector
	["black" "tomato" "PaleGreen2" "gold1"
	 "DeepSkyBlue1" "MediumOrchid1" "cyan" "white"])
  (setq ansi-color-map (ansi-color-make-color-map))
  
  :defer (use-package-defer-time)
  )

(use-package ace-window
  :bind
  (("M-o" . 'ace-window))
  :init
  (setq aw-dispatch-always t)
  :defer t
  )

;; (use-package zenburn-theme
;;   :init
;;   (setq zenburn-override-colors-alist
;;       '(("zenburn-orange" . "#21A675")
;; 	("zenburn-yellow" . "#E29C45")))
;;   :config
;;   (load-theme 'zenburn t)
;;   )

(use-package gruvbox-theme
  :config
  (load-theme 'gruvbox-dark-soft t))

(use-package smart-mode-line
  :config
  (setq sml/no-confirm-load-theme t)
  (setq sml/theme 'dark) ;; or 'dark
  (add-hook 'after-init-hook (lambda () (sml/setup) (load-theme 'smart-mode-line-powerline t)))
  )

(use-package cc-mode
  :config
  (define-key c-mode-base-map (kbd "RET") 'c-context-line-break)
  
  (defun hook-c/c++-insert-function ()
    "check if need to convert '.' to '->' in c/c++ mode"
    (condition-case nil
	(when (= (char-before (- (point) 1)) ?. )
	  (lsp--cur-workspace-check)
	  ;; delay call or no codeAction yet!
	  (run-with-timer 0.3 nil (lambda () 
				    (lsp--send-request-async (lsp--make-request
							      "textDocument/codeAction"
							      (lsp--text-document-code-action-params "quickfix"))
							     (lambda (actions)
							       (if actions
								   (progn
								     (lsp--execute-code-action (lsp-seq-first actions))
								     (let ((this-command 'company-idle-begin)
									   (company-minimum-prefix-length 0))
								       (company-auto-begin)
								       (company-post-command))
								     ))
							       )))))
      (t ())
      ))
  
  (defun my-c-mode-hook ()
    (add-hook 'post-self-insert-hook 'hook-c/c++-insert-function 0 t)

    (c-set-offset 'substatement-open 0)
    (setq c-basic-offset 8          ;; 基本缩进宽度
	  indent-tabs-mode t        ;; 禁止空格替换Tab
	  default-tab-width 8)      ;; 默认Tab宽度
    
    (local-set-key (kbd "C-c .") 'ace-mc-add-multiple-cursors)
    (setq-local sp-escape-quotes-after-insert nil)
    (let* ((file-name (buffer-file-name))
	   (is-windows (equal 'windows-nt system-type))
	   (exec-suffix (if is-windows ".exe" ".out"))
	   (os-sep (if is-windows "\\" "/")))
      (if file-name
	  (progn
	    (setq file-name (file-name-nondirectory file-name))
	    (let ((out-file (concat (file-name-sans-extension file-name) exec-suffix)))
	      (setq-local compile-command (format "g++ -std=c++17 '%s' -o '%s' && .%s'%s'" file-name out-file os-sep out-file)))
	    )
	))
    )
  (add-hook 'c-mode-hook 'my-c-mode-hook)
  (add-hook 'c++-mode-hook 'my-c-mode-hook)

  :defer (use-package-defer-time)
  )

(use-package expand-region
  :bind
  ("C-c ;" . er/expand-region)
  )

(use-package helm-gtags
  :hook
  ((c-mode . helm-gtags-mode)
   (c++-mode . helm-gtags-mode)
   (python-mode . helm-gtags-mode)
   (lua-mode . helm-gtags-mode)
   )
  :init
  (setq	helm-gtags-prefix-key "\C-c g")
  :config
  (setq helm-gtags-ignore-case t
	helm-gtags-auto-update t
	helm-gtags-use-input-at-cursor t
	helm-gtags-pulse-at-cursor t
	helm-gtags-suggested-key-mapping t
	)
  :bind
  (:map helm-gtags-mode-map
	("C-c g a" . helm-gtags-tags-in-this-function)
	("M-." . helm-gtags-dwim)
	("M-," . helm-gtags-pop-stack)
	("C-c <" . helm-gtags-previous-history)
	("C-c >" . helm-gtags-next-history)
	)
  )

(use-package multiple-cursors
  :bind
  (("C-S-c C-S-c" . mc/mark-all-in-region-regexp)
   ("C-c m n" . mc/mark-next-like-this)
   ("C-c m p" . mc/mark-previous-like-this)
   ("C-c m m" . mc/mark-all-like-this)
   )
  )

(use-package ace-mc
  :bind
  ("C-c ." . ace-mc-add-multiple-cursors)
  )

(use-package yasnippet
  :config
  (yas-global-mode 1)
  
  :defer (use-package-defer-time)
  )

(use-package company
  :config
  (global-company-mode 1)
  (setq company-idle-delay 0.2
	company-minimum-prefix-length 2
	company-auto-complete nil)
  (setq company-backends
	'((company-files          ; files & directory
	   company-keywords       ; keywords
	   company-capf
	   company-yasnippet
	   )
	  (company-abbrev company-dabbrev)
	  ))

  :defer (use-package-defer-time)
  )

(use-package dired-x
  :hook
  (dired-mode . dired-omit-mode))

(use-package avy
  :bind
  ("C-c SPC" . avy-goto-char)
  :config
  (dolist (hook '(conf-space-mode-hook
		  conf-colon-mode-hook
		  conf-pdd-mode-hook
		  conf-unix-mode-hook
		  conf-windows-mode-hook
		  conf-xdefaults-mode-hook
		  conf-javaprop-mode-hook
		  comint-mode-hook
		  eshell-mode-hook
		  org-mode-hook))
    (add-hook hook (lambda ()
		     (local-set-key (kbd "C-c SPC") 'avy-goto-char))))
  
  :defer (use-package-defer-time)
  )

(use-package lua-mode
  :config
  (defun my-lua-send-file ()
    (interactive)
    (lua-send-string (format "_ = dofile('%s')" buffer-file-name))
    (switch-to-buffer-other-window "*lua*")
    )
  (add-hook 'lua-mode-hook
	    (lambda()
	      (setq-local company-backends
			   '((company-lua
			     company-yasnippet)))
	      (setq
	       tab-width 8
	       indent-tabs-mode t
	       lua-indent-level 8
	       )
	      (hs-minor-mode 1)))
  
  :defer (use-package-defer-time)
  )

(use-package rainbow-delimiters
  :hook
  (prog-mode . rainbow-delimiters-mode)
  :defer t
  )

(use-package highlight-symbol
  :hook
  (prog-mode . highlight-symbol-mode)
  (prog-mode . highlight-symbol-nav-mode)
  :init
  (setq highlight-symbol-nav-mode-map
	(let ((map (make-sparse-keymap)))
	  (define-key map (kbd "C-M-s") 'highlight-symbol-next)
	  (define-key map (kbd "C-M-r") 'highlight-symbol-prev)
	  map))
  :config
  (setq highlight-symbol-idle-delay 0.5)
  (setq highlight-symbol-on-navigation-p t)
  :defer t
  )

(use-package shell
  :config
  (defun clear-shell ()
    (interactive)
    (let ((comint-buffer-maximum-size 0))
      (comint-truncate-buffer)))
  
  (define-key shell-mode-map (kbd "C-c c b") 'clear-shell)

  (add-hook 'shell-mode-hook
	    (lambda ()
	      (setq sh-basic-offset 8 sh-indentation 8)
	      (shell-dirtrack-mode 0) ;stop the usual shell-dirtrack mode
	      ;; pattern depends on $PS1
	      (let ((pattern (if (equal 'darwin system-type) "^\\(.*\\)\\[\\(.*\\)\\]" "^\\(.*@.*:\\)?\\(.*\\)[$#] $")))
		(set-variable 'dirtrack-list `(,pattern 2 nil)))
	      (dirtrack-mode))
	    )
  
  :defer (use-package-defer-time)
  )

(use-package python
  :config
  (add-hook 'python-mode-hook
	    (lambda()
	      (setq indent-tabs-mode t        ;; 禁止空格替换 Tab
		    tab-width 8
		    python-indent-offset 8
		    )
	      (hs-minor-mode 1)
	      (if (executable-find "python3")
		  (setq python-shell-interpreter "python3"))
	      ))
  
  :defer (use-package-defer-time)
  )

(use-package flycheck
  :config
  (setq flycheck-highlighting-mode nil)
  
  :defer (use-package-defer-time)
  )

(use-package vlf-setup
  :defer (use-package-defer-time)
  )

(use-package org
  :config
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

  :defer (use-package-defer-time)
  )

(use-package smartparens-config
  :config
  (sp-use-paredit-bindings)
  (dolist (key '("M-<up>" "M-<down>" "C-<right>"
		 "C-<left>" "C-M-<left>" "C-M-<right>"))
    (define-key smartparens-mode-map (kbd key) nil))
  (smartparens-global-mode t)
  (sp-local-pair 'prog-mode "{" nil :post-handlers '(("||\n[i]" "RET")))
  
  :defer (use-package-defer-time)
  )

(use-package lsp-mode
  :hook
  ((c-mode . lsp-deferred)
   (c++-mode . lsp-deferred))
  :commands
  (lsp lsp-deferred)
  :init
  (setq lsp-keymap-prefix "C-c l")
  :custom
  (lsp-file-watch-threshold nil)
  (lsp-enable-symbol-highlighting nil)
  (lsp-eldoc-hook nil)
  (lsp-restart 'ignore)
  (lsp-enable-on-type-formatting nil)
  (lsp-enable-indentation nil)
  (lsp-signature-auto-activate nil)
  :config
  (add-hook 'lsp-mode-hook (lambda ()
			     (if (bound-and-true-p lsp-mode)
				 (if (bound-and-true-p helm-gtags-mode)
				     (helm-gtags-mode -1))))))

(use-package rmsbolt
  :init
  (custom-set-faces
   '(rmsbolt-current-line-face ((t (:background "#5F5F87870000" :weight bold)))))
  :defer t)

(provide 'init)
;;; init.el ends here

