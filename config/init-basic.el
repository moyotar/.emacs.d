;; 全屏启动
(setq initial-frame-alist (quote ((fullscreen . maximized))))
(package-initialize)

(tool-bar-mode -1)

;; 关闭文件滑动控件
(scroll-bar-mode -1)
(add-hook 'horizontal-scroll-bar-mode-hook '(lambda ()  (setq horizontal-scroll-bar nil)))

;; 显示行号和列号
;; (global-linum-mode 1)
(global-display-line-numbers-mode 1)
(column-number-mode 1)
(setq linum-format "%4d ")

;; 关闭启动帮助画面
(setq inhibit-splash-screen 1)

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
 '(line-number ((t (:inherit (shadow default) :foreground "#00d7d7"))))
 '(cursor ((t (:background "slate blue" :foreground "ghost white")))))

(setq vc-log-show-limit 100)

;; Prefer Source Code Pro
(when (member "Source Code Pro" (font-family-list))
  (custom-set-faces
   '(default ((t (:inherit nil :stipple nil :background "#3F3F3F" :foreground "#DCDCCC"
			   :inverse-video nil :box nil :strike-through nil :overline nil
			   :underline nil :slant normal :weight normal :height 162
			   :width normal :foundry "outline" :family "Source Code Pro"))))))

(setq source-directory (expand-file-name "emacs-source" user-emacs-directory))

(provide 'init-basic)
