;; g17 work config  -*- lexical-binding: t; -*-

(add-to-list 'auto-mode-alist '("\\.pto$" . lua-mode))

(defun g17-exec-cmd-1(cmd)
  (let* ((root (projectile-project-root))
	 (conf-file-path (expand-file-name "engine/etc/g17.conf" root))
	 (port nil))
    (if (file-exists-p conf-file-path)
	(progn
	  (setq port-conf (shell-command-to-string (format "grep -E '\s*\"DebugPort\"\s*:' %s" conf-file-path)))
	  (setq suffix "")
	  (if (string-empty-p port-conf)
	      (setq port-conf
		    (shell-command-to-string (format "grep -E '\s*\"server_id\"\s*:' %s" conf-file-path))
		    suffix "0"))
	  (setq port (shell-command-to-string (format "echo '%s' | grep -Eoh '[0-9]+' | tr -d '\n'" port-conf)))
	  (message (shell-command-to-string (format "echo '%s' | nc -q 1 127.0.0.1 %s%s" cmd port suffix)))
	  ))))

(defun g17-exec-cmd(cmd)
  (interactive "Mcmd: ")
  (g17-exec-cmd-1 cmd))

(defun g17-update()
  (interactive)
  (let* ((file-name (file-relative-name (buffer-file-name) (format "%s/logic" (projectile-project-root)))))
    (if current-prefix-arg
	(g17-exec-cmd (format "ls Update(\"%s\") engine.RunCodeInFightThread(\"Update(\\\"%s\\\")\")" file-name file-name))
      (g17-exec-cmd (format "ls Update(\"%s\")" file-name)))))

(provide 'init-g17-work)

