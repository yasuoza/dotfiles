;; python-mode
(setq auto-mode-alist
      (cons '("\\.py$" . python-mode) auto-mode-alist))
(autoload 'python-mode "python-mode" "Python editing mode." t)

;; インデント4
(add-hook 'python-mode-hook
      '(lambda()
         (setq indent-tabs-mode t)
         (setq indent-level 4)
         (setq python-indent 4)
         (setq tab-width 4))) 

;; pysmell
(require 'pysmell)
(add-hook 'python-mode-hook (lambda () (pysmell-mode 1)))

(defvar ac-source-pysmell
  '((candidates
  . (lambda ()
   (require 'pysmell)
   (pysmell-get-all-completions))))
  "~/Dropbox/.emacs.d/")

(add-hook 'python-mode-hook
'(lambda ()
 (set (make-local-variable 'ac-sources) (append ac-sources '(ac-source-pysmell)))))
