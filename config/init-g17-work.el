;; g17 work config

(add-to-list 'auto-mode-alist '("\\.pto$" . lua-mode))

(defun g17-exec-cmd-1(cmd)
  (let* ((root (projectile-project-root))
	 (conf-file-path (expand-file-name "engine/etc/g17.conf" root))
	 (port nil))
    (if (file-exists-p conf-file-path)
	(progn (setq port
		      (shell-command-to-string
		       (format "grep '^server_id' %s | awk '{gsub(\"[^0-9]+\", \"\"); print $0}' | tr -d '\n' " conf-file-path)))
	       (message (shell-command-to-string (format "echo '%s' | nc -q 1 127.0.0.1 %s0" cmd port)))
	       )))
  )

(defun g17-exec-cmd(cmd)
  (interactive "Mcmd: ")
  (g17-exec-cmd-1 cmd))

(defun g17-update()
  (interactive)
  (let* ((file-name (file-relative-name (buffer-file-name) (format "%s/logic" (projectile-project-root)))))
    (g17-exec-cmd (format "ls Update(\"%s\") engine.RunCodeInFightThread(\"Update(\\\"%s\\\")\")" file-name file-name))))

(provide 'init-g17-work)

