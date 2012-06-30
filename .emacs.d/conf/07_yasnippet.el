;; yasnippet
(add-to-list 'load-path "~/dotfiles/.emacs.d/snippets")
(setq yas/snippet-dirs "~/dotfiles/.emacs.d/snippets")

(require 'yasnippet)
(yas/initialize)
(yas/load-directory "~/dotfiles/.emacs.d/snippets")
