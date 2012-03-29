;;auto-complete
(require 'auto-complete-config)
(add-to-list 'ac-dictionary-directories "~/Dropbox/.emacs.d/elisp//ac-dict")
(ac-config-default)
(require 'auto-complete)
(global-auto-complete-mode t)

;;Enable Ctr-n & Ctr-p to select list
(define-key ac-complete-mode-map "\C-n" 'ac-next)
(define-key ac-complete-mode-map "\C-p" 'ac-previous)

;;ac-company
(add-to-list 'load-path "~/Dropbox/.emacs.d/elisp/")
(autoload 'company-mode "company" nil t)

;;auto complete and show menu will start 
(setq ac-auto-start 2)
;(setq ac-auto-start nil)

;; set time to show menu 
(setq ac-auto-show-menu 0.5)

;; if ac-show-menu-immediately-on-auto-complete , menu will apear immediately
;(setq ac-show-menu-immediately-on-auto-complete t)

;;to reduce complete cost
(setq ac-delay 0.2)
(setq ac-candidate-limit 5)


;;Distinguish Latter letter and small letter
(setq ac-ignore-case nil)


;;set trigger key
;(ac-set-trigger-key "TAB")


(ac-clear-variable-every-minute 1)
