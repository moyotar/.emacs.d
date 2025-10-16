;; g17 work config  -*- lexical-binding: t; -*-

(add-to-list 'auto-mode-alist '("\\.pto$" . lua-mode))

(defvar g17-command-history nil
  "记录执行过的 G17 命令历史")

(defun g17-exec-cmd-1(oricmd)
  (let* ((root (projectile-project-root))
         (conf-file-path (expand-file-name "engine/etc/g17.conf" root))
         (port nil)
         (cmd (replace-regexp-in-string "\\bself\\b" "USERTBL.UserTbl[next(USERTBL.UserTbl)]" oricmd)))
    (if (numberp current-prefix-arg)
        (setq port (* current-prefix-arg 10))
      (if (file-exists-p conf-file-path)
          (progn
            (setq port-conf (shell-command-to-string (format "grep -E '\s*\"DebugPort\"\s*:' %s | head -n 1" conf-file-path)))
            (setq suffix "")
            (if (string-empty-p port-conf)
                (setq port-conf
                      (shell-command-to-string (format "grep -E '\s*\"server_id\"\s*:' %s | head -n 1" conf-file-path))
                      suffix "0"))
            (setq port (shell-command-to-string (format "echo '%s' | grep -Eoh '[0-9]+' | tr -d '\n'" port-conf))))))
    (message (shell-command-to-string (format "echo '%s' | nc -w 2 127.0.0.1 %s" cmd (or port ""))))
    (setq g17-command-history
          (cons cmd (remove cmd g17-command-history)))
    (when (> (length g17-command-history) 100)
      (setq g17-command-history (nthcdr 0 (butlast g17-command-history (- (length g17-command-history) 100)))))))

(defun g17-exec-cmd(cmd)
  (interactive "Mcmd: ")
  (let ((command (format "ls return JSON.encode({%s})" cmd)))
    (message "执行命令: %s" command)
    (g17-exec-cmd-1 command)))

(defun g17-exec-noret-cmd(cmd)
  (interactive "Mcmd: ")
  (let ((command (format "ls %s" cmd)))
	(message "执行命令: %s" command)
	(g17-exec-cmd-1 command)))

(defun g17-update()
  (interactive)
  (let* ((file-name (file-relative-name (buffer-file-name) (format "%s/logic" (projectile-project-root)))))
    (if current-prefix-arg
	(g17-exec-cmd-1 (format "ls Update(\"%s\") engine.RunCodeInFightThread(\"Update(\\\"%s\\\")\")" file-name file-name))
      (g17-exec-cmd-1 (format "ls Update(\"%s\")" file-name)))))

(defun call-this-split-args (input-str)
  "分割 Lua 参数，支持数字、字符串和嵌套 table '{}'"
  (let ((len (length input-str))
        (args '())
        (i 0))
    (while (< i len)
      (cond
       ;; 跳过空白和逗号
       ((member (aref input-str i) '(?, ?\s))
        (setq i (1+ i)))
       
       ;; 处理字符串 "
       ((eq (aref input-str i) ?\")
        (let ((start i))
          (setq i (1+ i))
          (while (and (< i len)
                      (not (and
                            (eq (aref input-str i) ?\")
                            (not (eq (aref input-str (1- i)) ?\\)))))
            (setq i (1+ i)))
          (setq args (append args
                             (list (substring input-str start (1+ i)))))
          (setq i (1+ i))))
       
       ;; 处理字符串 '
       ((eq (aref input-str i) ?\')
        (let ((start i))
          (setq i (1+ i))
          (while (and (< i len)
                      (not (and
                            (eq (aref input-str i) ?\')
                            (not (eq (aref input-str (1- i)) ?\\)))))
            (setq i (1+ i)))
          (setq args (append args
                             (list (substring input-str start (1+ i)))))
          (setq i (1+ i))))
       
       ;; 处理 table {
       ((eq (aref input-str i) ?{)
        (let ((depth 1)
              (start i))
          (setq i (1+ i)) ; 跳过第一个 {
          (while (and (< i len) (> depth 0))
            (cond
             ((eq (aref input-str i) ?{)
              (setq depth (1+ depth)))
             ((eq (aref input-str i) ?})
              (setq depth (1- depth))))
            (setq i (1+ i)))
          ;; 把整个 table 串进参数（包括花括号）
          (setq args (append args
                             (list (substring input-str start i))))))
       
       ;; 处理一般类型（数字、未加引号的字符串）
       (t
        (let ((start i))
          (while (and (< i len)
                      (not (member (aref input-str i) '(?, ?\s))))
            (setq i (1+ i)))
          (setq args (append args
                             (list (string-trim (substring input-str start i)))))))))
    args))

(defun call-this-generate-command ()
  "解析当前 Lua 函数，并返回正确的远程调用命令"
  (save-excursion
    (let* ((line-str (string-trim (thing-at-point 'line t)))  ;; 获取当前行
           (colon-pos (string-match "\\([a-zA-Z0-9_]+\\):\\([a-zA-Z0-9_]+\\)" line-str))
           (local-func (string-match "^local[ \t]+function[ \t]+" line-str)) ;; 是否为 local 函数
           (func-name (cond
                       (colon-pos (concat (match-string 1 line-str) "." (match-string 2 line-str)))
                       ((string-match "function[ \t]+\\([a-zA-Z0-9_.]+\\)" line-str)
                        (match-string 1 line-str))
                       (t nil)))  ;; 无法解析则返回 nil
           (proj-root (ignore-errors (projectile-project-root)))  ;; 防止 `nil` 报错
           (file-path (when (and proj-root (buffer-file-name))
                        (file-relative-name (buffer-file-name) (expand-file-name "logic" proj-root))))
           (params (when (string-match "function[^()]*([ \t]*\\([^)]*\\)[ \t]*)" line-str)
                     (let ((args (mapcar #'string-trim (split-string (match-string 1 line-str) "," t))))
                       (if colon-pos (cons "self" args) args))))
           (variadic (string-match "\\.\\.\\." line-str)) ;; 是否有变长参数 (...)
           (arg-count (length params)))

      ;; 错误检查
      (unless func-name (error "无法解析有效的函数名"))
      (unless file-path (error "文件未在项目 logic 目录中"))

      ;; 读取用户输入
      (let* ((input-str (if (> arg-count 0)
			    (read-string (format "请输入 %s 参数%s（用逗号隔开）: " 
                                             (if variadic "至少" "") 
                                             arg-count))
			  ""))
             (args (call-this-split-args input-str)))

        ;; ;; 确保输入参数数量匹配（若无变长参数，参数数量必须一致）
        ;; (when (and (not variadic) (/= (length args) arg-count))
        ;;   (error "输入参数数量 (%d) 与函数期望参数数量 (%d) 不匹配" (length args) arg-count))

        ;; 选择正确的 Lua 远程调用方式
        (let ((command
               (if local-func
                   (format "GetLocal(Import(\"%s\"), \"%s\")(%s)"
                           file-path
                           func-name
                           (mapconcat 'identity args ", "))
                 (format "Import(\"%s\").%s(%s)"
                         file-path
                         func-name
                         (mapconcat 'identity args ", ")))))
          command)))))

(defun g17-call-this ()
  "调用 `call-this-generate-command` 生成命令并执行"
  (interactive)
  (let ((command (format "ls return JSON.encode({%s})" (call-this-generate-command))))
    (message "执行命令: %s" command)
    (g17-exec-cmd-1 command)))

(defun g17-cocall-this ()
  "调用 `call-this-generate-command` 生成命令并执行"
  (interactive)
  (let ((command (format "ls CoRun(function() print(JSON.encode({%s})) end)" (call-this-generate-command))))
    (message "执行命令: %s" command)
    (g17-exec-cmd-1 command)))

(defun g17-user-login()
  (interactive)
  (g17-exec-cmd-1 (format "ls CoRun(TEST_CLIENT.CoGetTestUsers, HostId, 10)")))

(defun g17-command-history ()
  "从历史记录中选择一个命令执行"
  (interactive)
  (if (null g17-command-history)
      (message "暂无历史命令")
    (let* ((cmd (completing-read "选择历史命令: " g17-command-history)))
      (g17-exec-cmd-1 cmd))))

(provide 'init-g17-work)

