; mmm-mode in php
(require 'mmm-mode)
(setq mmm-global-mode 'maybe)
(mmm-add-mode-ext-class nil "\\.php?\\'" 'html-php)
(mmm-add-classes
 '((html-php
    :submode php-mode
    :front "<\\?\\(php\\)?"
    :back "\\?>")))
(mmm-add-classes
 '((html-javascript
    :submode javascript-mode
    :front "<script[^>]*>"
    :back "</script>")))
(mmm-add-mode-ext-class nil "\\.html?\\'" 'html-javascript)
(add-to-list 'auto-mode-alist '("\\.php?\\'" . html-mode))

;; mmm-modeのフェイスを変更
(set-face-bold-p 'mmm-default-submode-face t)
(set-face-background 'mmm-default-submode-face "black")
