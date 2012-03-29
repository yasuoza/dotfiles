;; zencoding
(require 'zencoding-mode)
;; Auto-start on any markup modes
(add-hook 'sgml-mode-hook 'zencoding-mode)
(add-hook 'html-mode-hook 'zencoding-mode)
(add-hook 'text-mode-hook 'zencoding-mode)
