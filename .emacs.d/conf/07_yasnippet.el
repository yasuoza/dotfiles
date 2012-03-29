;; yasnippet
(add-to-list 'load-path "~/Dropbox/.emacs.d/snippets")
(setq yas/snippet-dirs "~/Dropbox/.emacs.d/snippets")

(require 'yasnippet)
(yas/initialize)
(yas/load-directory "~/Dropbox/.emacs.d/snippets")
