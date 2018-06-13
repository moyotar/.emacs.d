
(require 'company)

(global-company-mode 1)
(setq company-idle-delay 0.2)
(setq company-minimum-prefix-length 2)
(setq company-auto-complete nil)

;; set default `company-backends'
(setq company-backends
      '((company-files          ; files & directory
	 company-keywords       ; keywords
	 company-capf
	 company-yasnippet
	 )
	(company-abbrev company-dabbrev)
	        ))


(provide 'init-company)
