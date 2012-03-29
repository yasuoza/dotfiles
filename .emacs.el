;; load-path
(setq load-path
      (append
       (list
        (expand-file-name "~/dotfiles/.emacs.d/")
        (expand-file-name "~/dotfiles/.emacs.d/elisp/")
        (expand-file-name "~/dotfiles/.emacs.d/elisp/mmm-mode/")
        )
       load-path))

;; load config files
(require 'init-loader)
(init-loader-load "~/dotfiles/.emacs.d/conf")

;; PATH
(setq exec-path (cons "/usr/local/bin" exec-path))
(setenv "PATH"
    (concat '"/usr/local/bin:" (getenv "PATH")))
