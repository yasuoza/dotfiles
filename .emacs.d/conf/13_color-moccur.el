;;regexp memo
;if you want to search word icluding white space,
;you have to write [ \t].
;ex) search "int x" as "int[ \t]x"

(require 'color-moccur)

;;set Ctr-s as occur-by-moccur
(global-set-key "\M-s" 'occur-by-moccur)

;;define grep function
(defalias 'grep 'moccur-grep)
(defalias 'grep-find 'moccur-grep-find)

;;define exclude mask
(setq dmoccur-exclusion-mask
      (append '("\\~$" "\\.svn\\/\*") dmoccur-exclusion-mask))


;;setting mocuur-edit
(require 'moccur-edit)

;;変更箇所に色付け
(setq moccur-edit-highlight-edited-text t)
(setq moccur-edit-remove-overlays t)
