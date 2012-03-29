;; psvn.el commitを日本語でかけるように設定
(require 'psvn)
(setq process-coding-system-alist '(("svn" . utf-8)))
(setq default-file-name-coding-system 'utf-8)
(setq svn-status-svn-file-coding-system 'utf-8)
