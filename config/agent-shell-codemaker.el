;;; agent-shell-codemaker.el --- CodeMaker agent configurations -*- lexical-binding: t; -*-

;; Copyright (C) 2024 Alvaro Ramirez

;; Author: Alvaro Ramirez https://xenodium.com
;; URL: https://github.com/xenodium/agent-shell

;; This package is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This package is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:
;;
;; This file includes CodeMaker-specific configurations.
;;

;;; Code:

(eval-when-compile
  (require 'cl-lib))
(require 'shell-maker)
(require 'acp)

(declare-function agent-shell--indent-string "agent-shell")
(declare-function agent-shell-make-agent-config "agent-shell")
(autoload 'agent-shell-make-agent-config "agent-shell")
(declare-function agent-shell--make-acp-client "agent-shell")
(declare-function agent-shell--dwim "agent-shell")

(cl-defun agent-shell-codemaker-make-authentication (&key api-key none)
  "Create CodeMaker authentication configuration.

API-KEY is the CodeMaker API key string or function that returns it.
NONE when non-nil disables API key authentication.

Only one of API-KEY or NONE should be provided, never both."
  (when (and api-key none)
    (error "Cannot specify both :api-key and :none - choose one"))
  (unless (or api-key none)
    (error "Must specify either :api-key or :none"))
  (cond
   (api-key `((:api-key . ,api-key)))
   (none `((:none . t)))))

(defcustom agent-shell-codemaker-authentication
  (agent-shell-codemaker-make-authentication :none t)
  "Configuration for CodeMaker authentication.

Set via `agent-shell-codemaker-make-authentication'.

For example, to use an API key:

  (setq agent-shell-codemaker-authentication
        (agent-shell-codemaker-make-authentication
         :api-key \"your-api-key\"))

Or to rely on external authentication:

  (setq agent-shell-codemaker-authentication
        (agent-shell-codemaker-make-authentication :none t))"
  :type 'alist
  :group 'agent-shell)

(defcustom agent-shell-codemaker-acp-command
  '("codemaker" "acp")
  "Command and parameters for the CodeMaker client.

The first element is the command name, and the rest are command parameters."
  :type '(repeat string)
  :group 'agent-shell)

(defcustom agent-shell-codemaker-environment
  nil
  "Environment variables for the CodeMaker client.

This should be a list of environment variables to be used when
starting the CodeMaker client process."
  :type '(repeat string)
  :group 'agent-shell)

(defun agent-shell-codemaker-make-agent-config ()
  "Create a CodeMaker agent configuration.

Returns an agent configuration alist using `agent-shell-make-agent-config'."
  (agent-shell-make-agent-config
   :identifier 'codemaker
   :mode-line-name "CodeMaker"
   :buffer-name "CodeMaker"
   :shell-prompt "CodeMaker> "
   :shell-prompt-regexp "CodeMaker> "
   :icon-name "codemaker.png"
   :welcome-function #'agent-shell-codemaker--welcome-message
   :client-maker (lambda (buffer)
                   (agent-shell-codemaker-make-client :buffer buffer))
   :install-instructions "See https://codemaker.dev for installation."))

(defun agent-shell-codemaker-start-agent ()
  "Start an interactive CodeMaker agent shell."
  (interactive)
  (agent-shell--dwim :config (agent-shell-codemaker-make-agent-config)
                     :new-shell t))

(defun agent-shell-codemaker-key ()
  "Get the CodeMaker API key."
  (cond ((stringp (map-elt agent-shell-codemaker-authentication :api-key))
         (map-elt agent-shell-codemaker-authentication :api-key))
        ((functionp (map-elt agent-shell-codemaker-authentication :api-key))
         (condition-case _err
             (funcall (map-elt agent-shell-codemaker-authentication :api-key))
           (error
            (error "API key not found.  Check out `agent-shell-codemaker-authentication'"))))
        (t
         nil)))

(cl-defun agent-shell-codemaker-make-client (&key buffer)
  "Create a CodeMaker client using BUFFER as context.

Uses `agent-shell-codemaker-authentication' for authentication configuration."
  (unless buffer
    (error "Missing required argument: :buffer"))
  (let ((api-key (agent-shell-codemaker-key)))
    (agent-shell--make-acp-client :command (car agent-shell-codemaker-acp-command)
                                  :command-params (cdr agent-shell-codemaker-acp-command)
                                  :environment-variables (append (cond ((map-elt agent-shell-codemaker-authentication :none)
                                                                        nil)
                                                                       (api-key
                                                                        (list (format "CODEMAKER_API_KEY=%s" api-key)))
                                                                       (t
                                                                        (error "Missing CodeMaker authentication")))
                                                                 agent-shell-codemaker-environment)
                                  :context-buffer buffer)))

(defun agent-shell-codemaker--welcome-message (config)
  "Return CodeMaker welcome message using `shell-maker' CONFIG."
  (let ((art (agent-shell--indent-string 4 (agent-shell-codemaker--ascii-art)))
        (message (string-trim-left (shell-maker-welcome-message config) "\n")))
    (concat "\n\n"
            art
            "\n\n"
            message)))

(defun agent-shell-codemaker--ascii-art ()
  "CodeMaker ASCII art."
  (let* ((is-dark (eq (frame-parameter nil 'background-mode) 'dark))
         (text (string-trim "
  ██████╗ ███╗   ███╗
 ██╔════╝ ████╗ ████║
 ██║      ██╔████╔██║
 ██║      ██║╚██╔╝██║
 ╚██████╗ ██║ ╚═╝ ██║
  ╚═════╝ ╚═╝     ╚═╝" "\n")))
    (propertize text 'font-lock-face (if is-dark
                                         '(:foreground "#a0a0a0" :inherit fixed-pitch)
                                       '(:foreground "#505050" :inherit fixed-pitch)))))

(provide 'agent-shell-codemaker)

;;; agent-shell-codemaker.el ends here
