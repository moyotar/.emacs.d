;; 全屏启动
(setq initial-frame-alist (quote ((fullscreen . maximized))))
(package-initialize)

(if (display-graphic-p)
    (progn
      (tool-bar-mode -1)
      (scroll-all-mode -1)))

(add-hook 'horizontal-scroll-bar-mode-hook '(lambda ()  (setq horizontal-scroll-bar nil)))

;; 显示行号和列号
;; (global-linum-mode 1)
(global-display-line-numbers-mode 1)
(column-number-mode 1)
(setq linum-format "%4d ")

;; 关闭启动帮助画面
(setq inhibit-splash-screen 1)

(setq inhibit-compacting-font-caches t)

(set-face-attribute 'default nil :height 180)

;; 更改光标
(setq-default cursor-type 'box)

;; 快速打开配置文件
(defun open-init-file()
  (interactive)
  (find-file "~/.emacs.d/init.el"))
;; 这一行代码，将函数 open-init-file 绑定到 <f2> 键上
(global-set-key (kbd "<f2>") 'open-init-file)

;;选中时输入自动删除选中
(delete-selection-mode 1)

(defun switch-whitespace-mode()
  (interactive)
  (whitespace-mode 'toggle)
  )

(global-set-key (kbd "<f6>") 'switch-whitespace-mode)

;; 括号匹配
;; (electric-pair-mode t)
(show-paren-mode)
(setq show-paren-style 'parenthesis)

(fset 'yes-or-no-p 'y-or-n-p)

(require 'desktop)
(setq desktop-path (list "~/.emacs.d/desktop/"))
(desktop-save-mode 1)

(setq frame-title-format
      (list
       '(buffer-file-name "%f" (dired-directory dired-directory "%b"))
       " @moyotar"))

(setq buffer-file-coding-system 'utf-8)
(prefer-coding-system 'gbk)
(prefer-coding-system 'utf-8)
(define-coding-system-alias 'UTF-8 'utf-8)
(define-coding-system-alias 'GB18030 'gb18030)
(setq file-name-coding-system 'UTF-8-unix)

(setq load-prefer-newer t)

;; close backup
(setq make-backup-files nil)

(require 'ansi-color)
(setq ansi-color-names-vector
      ["black" "tomato" "PaleGreen2" "gold1"
       "DeepSkyBlue1" "MediumOrchid1" "cyan" "white"])
(setq ansi-color-map (ansi-color-make-color-map))

(custom-set-variables
 '(ansi-color-names-vector
   ["#3F3F3F" "#CC9393" "#7F9F7F" "#F0DFAF" "#8CD0D3" "#DC8CC3" "#93E0E3" "#DCDCCC"]))

(custom-set-faces
 '(cursor ((t (:background "slate blue" :foreground "ghost white")))))

(setq vc-log-show-limit 100)

;; Prefer Source Code Pro
(when (member "Source Code Pro" (font-family-list))
  (set-face-attribute
   'default nil
   :font (font-spec :family "Source Code Pro"
                    :weight 'normal
                    :slant 'normal
                    :size 16.0)))

(when (equal 'windows-nt system-type)
  (server-start)
  (dolist (charset '(kana han symbol cjk-misc bopomofo))
    (set-fontset-font
     (frame-parameter nil 'font)
     charset
     (font-spec :family "新宋体"
		:weight 'normal
		:slant 'normal
		))
    )
  (setq face-font-rescale-alist '(("新宋体" . 1.2)))
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

(setq aw-dispatch-always t)
(global-set-key (kbd "M-o") 'ace-window)

(defadvice text-scale-increase (around all-buffers (arg) activate)
  (dolist (buffer (buffer-list))
    (with-current-buffer buffer
      ad-do-it)))


(setq read-process-output-max (* 1024 1024))

(provide 'init-basic)
