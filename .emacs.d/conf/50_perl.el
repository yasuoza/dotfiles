;;perl-mode -> cperl-mode
(defalias 'perl-mode 'cperl-mode)
(setq auto-mode-alist (append '(("\\.psgi$" . cperl-mode)) auto-mode-alist))
(setq auto-mode-alist (append '(("\\.cgi$" . cperl-mode)) auto-mode-alist))
(setq auto-mode-alist (append '(("\\.pl$" . cperl-mode)) auto-mode-alist))
(setq auto-mode-alist (append '(("\\.pm$" . cperl-mode)) auto-mode-alist))
(setq auto-mode-alist (append '(("\\.t$" . cperl-mode)) auto-mode-alist))


;;cperl indent setting
(setq  cperl-indent-level 4
      ;; cperl-omment-column 40
      ;; cperl-brace-imaginary-offset 0
      ;; cperl-brace-offset 0
      ;; cperl-label-offset -2
      ;; cperl-min-label-indent 1
      cperl-continued-statement-offset 4
      ;; cperl-continued-brace-offset 0
	  cperl-close-paren-offset -4
      ;; cperl-indent-wrt-brace t
      cperl-indent-parens-as-block t
     )

;;perl-competion settings
(add-hook  'cperl-mode-hook (lambda ()
                              (require 'auto-complete)
                              (require 'perl-completion)
                              (add-to-list 'ac-sources 'ac-source-perl-completion)
                              (perl-completion-mode t)))


;;redefine keybing
(add-hook  'cperl-mode-hook (lambda ()
                              (local-set-key [?\C-;] 'plcmp-cmd-smart-complete)
                              ))


;; perltidy
(defun perltidy-region ()
   "Run perltidy on the current region."
   (interactive)
   (save-excursion
     (shell-command-on-region (point) (mark) "perltidy -q" nil t)))
 (defun perltidy-defun ()
   "Run perltidy on the current defun."
   (interactive)
   (save-excursion (mark-defun)
                   (perltidy-region)))                              


;; flymake for perl
(require 'set-perl5lib)
(defvar flymake-perl-err-line-patterns '(("\\(.*\\) at \\([^ \n]+\\) line \\([0-9]+\\)[,.\n]" 2 3 nil 1)))
(defconst flymake-allowed-perl-file-name-masks '(("\\.pl$" flymake-perl-init)
                                               ("\\.pm$" flymake-perl-init)
                                               ("\\.t$" flymake-perl-init)
                                               ))
 

;; flymake (Emacs22から標準添付されている)
(require 'flymake)

;; set-perl5lib
(require 'set-perl5lib)

;; エラー、ウォーニング時のフェイス
(set-face-background 'flymake-errline "red4")
(set-face-foreground 'flymake-errline "black")
(set-face-background 'flymake-warnline "yellow")
(set-face-foreground 'flymake-warnline "black")

;; エラーをミニバッファに表示
(defun flymake-display-err-minibuf ()
  "Displays the error/warning for the current line in the minibuffer"
  (interactive)
  (let* ((line-no             (flymake-current-line-no))
         (line-err-info-list  (nth 0 (flymake-find-err-info flymake-err-info line-no)))
         (count               (length line-err-info-list)))
    (while (> count 0)
      (when line-err-info-list
        (let* ((file       (flymake-ler-file (nth (1- count) line-err-info-list)))
               (full-file  (flymake-ler-full-file (nth (1- count) line-err-info-list)))
               (text (flymake-ler-text (nth (1- count) line-err-info-list)))
               (line       (flymake-ler-line (nth (1- count) line-err-info-list))))
          (message "[%s] %s" line text)))
      (setq count (1- count)))))

;; Perl用設定
(defvar flymake-perl-err-line-patterns
  '(("\\(.*\\) at \\([^ \n]+\\) line \\([0-9]+\\)[,.\n]" 2 3 nil 1)))

(defconst flymake-allowed-perl-file-name-masks
  '(("\\.pl$" flymake-perl-init)
    ("\\.pm$" flymake-perl-init)
    ("\\.t$" flymake-perl-init)))

(defun flymake-perl-init ()
  (let* ((temp-file (flymake-init-create-temp-buffer-copy
                     'flymake-create-temp-inplace))
         (local-file (file-relative-name
                      temp-file
                      (file-name-directory buffer-file-name))))
    (list "perl" (list "-wc" local-file))))

(defun flymake-perl-load ()
  (interactive)
  (defadvice flymake-post-syntax-check (before flymake-force-check-was-interrupted)
    (setq flymake-check-was-interrupted t))
  (ad-activate 'flymake-post-syntax-check)
  (setq flymake-allowed-file-name-masks (append flymake-allowed-file-name-masks flymake-allowed-perl-file-name-masks))
  (setq flymake-err-line-patterns flymake-perl-err-line-patterns)
  (set-perl5lib)
  (flymake-mode t))

;;enable if you want to use flymake-perl-mode with cperl-mode
;(add-hook 'cperl-mode-hook 'flymake-perl-load)
    
;; Ctr-ceで次のエラーに飛べるように
(defun next-flymake-error ()
  (interactive)
  (flymake-goto-next-error)
  (let ((err (get-char-property (point) 'help-echo)))
    (when err
      (message err))))
(global-set-key "\C-ce" 'next-flymake-error)
