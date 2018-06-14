(custom-set-faces
 '(rainbow-delimiters-depth-1-face ((t (:foreground "#7E3DA7"))))
 '(rainbow-delimiters-depth-2-face ((t (:foreground "chocolate2"))))
 '(rainbow-delimiters-depth-3-face ((t (:foreground "#4ef261"))))
 '(rainbow-delimiters-depth-4-face ((t (:foreground "#4EDAE1"))))
 '(rainbow-delimiters-depth-5-face ((t (:foreground "#F17374"))))
 '(rainbow-delimiters-depth-6-face ((t (:foreground "yellow"))))
 '(rainbow-delimiters-depth-7-face ((t (:foreground "#797BF4"))))
 '(rainbow-delimiters-depth-8-face ((t (:foreground "maroon1"))))
 '(rainbow-delimiters-depth-9-face ((t (:foreground "#F5A47A")))))

(add-hook 'prog-mode-hook #'rainbow-delimiters-mode)

(provide 'init-rainbow-delimiters)
