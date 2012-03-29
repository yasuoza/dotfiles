(require 'multi-term)
(setq multi-term-program "/bin/bash")
(setq locale-coding-system 'utf-8)
(setenv "LANG" "ja_JP.UTF-8")

;; term に奪われたくないキー
(add-to-list 'term-unbind-key-list '"C-o")


;; term 内での文字削除、ペーストを有効にする
(add-hook 'term-mode-hook
          '(lambda ()
             (define-key term-raw-map (kbd "C-h") 'term-send-backspace)
             (define-key term-raw-map (kbd "C-y") 'term-paste)
             ))
