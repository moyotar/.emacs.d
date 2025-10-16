;; -*- lexical-binding: t; -*-
(setq gc-cons-threshold (* 200 1024 1024)
      gc-cons-percentage 0.8)

(setq xterm-max-cut-length 5242880)	;; 5MB

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

(setq lsp-use-plists t)

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
      '(ace-jump-mode ace-mc ace-window ample-regexps anaphora autothemer avy bash-completion cl-lib cmake-mode color-theme-zenburn company-lua company-mode compat copilot dash deferred dockerfile-mode editorconfig el-get emacs-aio emacs-async emacs-theme-gruvbox epl exec-path-from-shell expand-region f flycheck fold-this ghub go-mode gptel graphql helm helm-ag helm-gtags helm-projectile helm-smex helm-xref highlight-symbol ht htmlize hydra json-mode json-reformat json-snatcher let-alist llama lsp-mode magit magit-popup markdown-mode multiple-cursors nav-flash org-bullets package pkg-info popup powerline projectile rainbow-delimiters request rich-minority rmsbolt s seq smart-mode-line smex spinner tablist transient treepy use-package vlfi wfnames with-editor yaml yaml-imenu yaml-mode yasnippet yasnippet-snippets mcp treesit-auto lua-mode kubernetes))

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
  (define-key helm-map (kbd "C-r") 'helm-minibuffer-history)
  (helm-mode 1)
  (setq helm-move-to-line-cycle-in-source nil)
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
  (defun helm-projectile-ag-rg (&optional options)
    "Helm version of `projectile-ag'.
OPTIONS explicit command line arguments to ag"
    (interactive (if current-prefix-arg (list (helm-read-string "option: " "" 'helm-ag--extra-options-history))))
    (if (require 'helm-ag nil t)
        (if (projectile-project-p)
	    (let* ((ignored (when (helm-projectile--projectile-ignore-strategy)
			      (mapconcat (lambda (i)
                                           (format "-g !%s" i))
                                         (append (helm-projectile--ignored-files)
						 (helm-projectile--ignored-directories)
                                                 (cadr (projectile-parse-dirconfig-file)))
                                         " ")))
		   (helm-ag-base-command (concat helm-ag-base-command
                                                 (when ignored (concat " " ignored))
                                                 " " options))
		   (current-prefix-arg nil))
	      (helm-do-ag (projectile-project-root)
			  (car (projectile-parse-dirconfig-file))))
	  (error "You're not in a project"))
      (when (yes-or-no-p "`helm-ag' is not installed. Install? ")
	(condition-case nil
            (progn
              (package-install 'helm-ag)
              (helm-projectile-ag options))
          (error (error "`helm-ag' is not available.  Is MELPA in your `package-archives'?"))))))
  (define-key projectile-mode-map (kbd "C-c p s s") 'helm-projectile-ag-rg)
  :defer (use-package-defer-time)
  )

(use-package helm-ag
  :defer t
  :config
  (custom-set-variables
 '(helm-ag-base-command "rg -S --no-heading --line-number --color never")
 `(helm-ag-success-exit-status '(0 2)))
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
  (load-theme 'gruvbox-dark-soft t)
  (custom-set-faces
   '(diff-added ((t (:extend t :background "#335533" :foreground "#7F9F7F"))))
   '(diff-refine-added ((t (:background "#338833" :foreground "#BFEBBF"))))
   '(diff-refine-removed ((t (:background "#883333" :foreground "#CC9393"))))
   '(diff-removed ((t (:extend t :background "#553333" :foreground "#AC7373"))))
   )
  )

(use-package smart-mode-line
  :config
  (setq sml/no-confirm-load-theme t)
  (setq sml/theme 'dark) ;; or 'dark
  (add-hook 'after-init-hook (lambda () (sml/setup) (load-theme 'smart-mode-line-powerline t)))
  )

(use-package c-ts-mode
  :config
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

  (setq c-ts-mode-indent-style 'bsd)
  (setq c-ts-mode-indent-offset 8)
  (setq indent-tabs-mode t)
  
  (defun my-c-mode-hook ()
    (add-hook 'post-self-insert-hook 'hook-c/c++-insert-function 0 t)

    (local-set-key (kbd "C-c .") 'ace-mc-add-multiple-cursors)
    ;; (setq-local sp-escape-quotes-after-insert nil)
    (let* ((file-name (buffer-file-name))
	   (is-windows (equal 'windows-nt system-type))
	   (exec-suffix (if is-windows ".exe" ".out"))
	   (os-sep (if is-windows "\\" "/")))
      (if file-name
	  (progn
	    (setq file-name (file-name-nondirectory file-name))
	    (let ((out-file (concat (file-name-sans-extension file-name) exec-suffix)))
	      (setq-local compile-command (format "g++ -std=c++20 '%s' -o '%s' && .%s'%s'" file-name out-file os-sep out-file)))
	    )
	))
    )
  (add-hook 'c-ts-base-mode-hook 'my-c-mode-hook)
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
  
  (add-hook 'lua-mode-hook
	    (lambda ()
	      (setq
	       indent-tabs-mode t
	       lua-indent-level 8
	       )
	      ))
  
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


(use-package elec-pair
  :hook (prog-mode . electric-pair-mode)
  :config
  ;; ;; Custom pairs (extend as needed)
  ;; (setq electric-pair-pairs '(
  ;;     (?\" . ?\")
  ;;     (?\{ . ?\})
  ;;     (?\( . ?\))
  ;;     (?\[ . ?\])
  ;;     (?` . ?`)
  ;; ))
  )

(use-package lsp-mode
  :hook
  ((c-mode . lsp-deferred)
   (c++-mode . lsp-deferred))
  :commands
  (lsp lsp-deferred)
  :init
  (setq lsp-keymap-prefix "C-c l")
  (setq lsp-clients-clangd-args
	'("--header-insertion=never"))
  :custom
  (lsp-file-watch-threshold nil)
  (lsp-enable-symbol-highlighting nil)
  (lsp-eldoc-hook nil)
  (lsp-restart 'ignore)
  (lsp-enable-on-type-formatting nil)
  (lsp-enable-indentation nil)
  (lsp-signature-auto-activate nil)
  (lsp-modeline-code-actions-enable nil)
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


(use-package copilot
  :defer (use-package-defer-time)
  :hook (prog-mode . copilot-mode)
  :config
  ;; 配置补全接受方式
  (define-key copilot-completion-map (kbd "C-M-f") 'copilot-accept-completion)
  (define-key copilot-completion-map (kbd "M-n") 'copilot-accept-completion-by-word)
  (define-key copilot-completion-map (kbd "M-l") 'copilot-accept-completion-by-line)
  (define-key copilot-completion-map (kbd "C-M-n") 'copilot-next-completion)
  (define-key copilot-completion-map (kbd "C-M-p") 'copilot-previous-completion)

  ;; 其他自定义设置
  (setq copilot-indent-offset-warning-disable t)
  (setq copilot-max-char -1)
  (setq copilot-idle-delay 0.1)
  ;; (setq copilot-enable-predicates '(copilot--buffer-changed)
  )

(use-package gptel
  :defer (use-package-defer-time)
  :bind (("C-c g g" . gptel)
         ("C-c g s" . gptel-send)
         ("C-c g m" . gptel-menu)
         ("C-c g a" . gptel-add)
         ("C-c g t" . gptel-tools)
         ("C-c g r" . gptel-rewrite))
  :config
  (require 'gptel-integrations)
  (add-hook 'gptel-post-stream-hook 'gptel-auto-scroll)
  (setq gptel-model 'gpt-4.1
	gptel-backend  (gptel-make-gh-copilot "Copilot"))
  
  (gptel-make-deepseek "DeepSeek"
    :stream t
    :key (auth-source-pick-first-password
          :host "api.deepseek.com"
          :user "apikey")
    :models '(deepseek-chat
              deepseek-reasoner))

  (gptel-make-openai "OpenRouter"
    :host "openrouter.ai"
    :endpoint "/api/v1/chat/completions"
    :stream t
    :key (auth-source-pick-first-password
	  :host "openrouter.ai"
	  :user "apikey")
    :models '(deepseek/deepseek-chat-v3.1:free
	      qwen/qwen3-coder
	      qwen/qwen3-coder:free
	      openai/gpt-5-nano
	      openai/gpt-5-mini
	      openai/gpt-5
	      anthropic/claude-sonnet-4
	      anthropic/claude-3.5-haiku
	      google/gemini-2.5-flash-lite
	      google/gemini-2.5-flash
	      google/gemini-2.0-flash-001))
  (setq gptel-use-tools t)
  )

(use-package mcp
  :after gptel
  :custom (mcp-hub-servers
           `(("filesystem" . (:command "npx" :args ("-y" "@modelcontextprotocol/server-filesystem" "~")))
             ("fetch" . (:command "uvx" :args ("mcp-server-fetch")))
             )
  :config (require 'mcp-hub)
  :hook (after-init . mcp-hub-start-all-server)))

(use-package treesit-auto
  :config
  (setq treesit-auto-install 'prompt)
  (setq treesit-language-source-alist
        '((c "https://github.com/tree-sitter/tree-sitter-c" "v0.23.4")
          ))
  (delete 'lua treesit-auto-langs)
  (global-treesit-auto-mode))

(use-package kubernetes
  :commands (kubernetes-overview)
  :config
  (setq kubernetes-poll-frequency 3600
        kubernetes-redraw-frequency 3600))


(provide 'init)
;;; init.el ends here

