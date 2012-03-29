;;org-directory ""
(defvar org-directory "")

;;bookmark file ~/.emacs.bmk -> ~/Dropbox/.emacs.d/emacs.bmk
(set-default 'bookmark-default-file "~/Dropbox/.emacs.d/emacs.bmk")

;;recentf file ~/.emacs.bmk -> ~/Dropbox/.emacs.d/recentf
(set-default 'recentf-save-file "~/Dropbox/.emacs.d/recentf")

;;行数表示
(line-number-mode t)
(column-number-mode t)

;;メニューバーを隠す
(menu-bar-mode 0)
(if (featurep 'carbon-emacs-package)
    (tool-bar-mode 0) ) ;carbon emacsならツールバーも消す

;;スタートアップページを表示しない
(setq inhibit-startup-message t)

;; カーソル点滅しないように
(blink-cursor-mode 0)

;; アクティブでないバッファではカーソルを出さない
(setq cursor-in-non-selected-windows nil)

;; バックアップしない
(setq make-backup-files nil)

;; 自動保存したファイルを削除する
(setq delete-auto-save-files t)

;; 自動セーブしない
(setq auto-save-default nil)

;;静音化
(setq visible-bell t)
(setq ring-bell-function 'ignore)

;;文字の折り返しオン
(setq truncate-partial-width-windows nil)

;;改行後に自動インデント
(global-set-key "\C-m" 'newline-and-indent)

;;オートインデントでスペースを使う
(setq-default indent-tabs-mode nil)

;; 対応する括弧を光らせる
(show-paren-mode 1)

;; 一行ずつスクロール
(setq scroll-step 1)

;; recenf-mode
(recentf-mode t)

;; フリンジ(左右の折り返し表示領域)はいらない teminal時には実行しない
( if (eq window-system 'ns)
    (fringe-mode 0) )

;; リージョンを削除できるように
(delete-selection-mode t)

;; ドラックドロップでファイルを新規バッファで開く
(define-key global-map [ns-drag-file] 'ns-find-file)
(setq ns-pop-up-frames nil)

;;終了時に確認
(defadvice save-buffers-kill-emacs
  (before safe-save-buffers-kill-emacs activate)
  "safe-save-buffers-kill-emacs"
  (unless (yes-or-no-p "Really exit emacs? ")
    (keyboard-quit)))

;; 言語を日本語にする
;(set-language-environment 'Japanese)
(set-language-environment 'utf-8)
;; utf-8優先
(prefer-coding-system 'utf-8)

;;commandをメタキーにする。
(setq mac-command-modifier 'meta)

;; タブキー
(setq default-tab-width 4)
(setq indent-line-function 'indent-relative-maybe)

;;; sense-region
(autoload 'sense-region-on "sense-region"
  "System to toggle region and rectangle." t nil)
(sense-region-on)


;;iswichb-mode
(iswitchb-mode 1)

;;wdired-change-to-wdired-mode mode setting
(require 'wdired)
(define-key dired-mode-map "r" 'wdired-change-to-wdired-mode)


;;Ctr+H修正
(load "term/bobcat")
(when (fboundp 'terminal-init-bobcat) (terminal-init-bobcat))
(global-set-key "\C-h" 'delete-backward-char)

;; ファイル末の改行がなければ追加
(setq require-final-newline t)

;;shellモードで日本語表示を可能にする
   (set-language-environment "Japanese")
   (prefer-coding-system 'utf-8-unix)
   (setq default-buffer-file-coding-system 'utf-8)
   (set-buffer-file-coding-system 'utf-8)
   (set-terminal-coding-system 'utf-8)
   (set-keyboard-coding-system 'utf-8)
   (set-clipboard-coding-system 'utf-8)
(put 'upcase-region 'disabled nil)

;;Ctrl-x pで逆向きへのウィンドウ移動
(global-set-key "\C-xp" (lambda () (interactive) (other-window -1)))


;;編集行を強調する
(defface hlline-face
  '((((class color)
      (background dark))
     (:background "grey14"
                  :underline nil))
    (((class color)
      (background light))
     (:background "dark slate gray"
                  :underline nil))
    (t ()))
  "*Face used by hl-line.")
(setq hl-line-face 'hlline-face)
;;(setq hl-line-face 'underline)
(global-hl-line-mode)


;;;;レジスタ&ブックマーク関係
;;レジスタに保存した位置に移動する
(global-set-key "\C-xrj" 'jump-to-register)
;;ポイント位置をブックマークに設定する
(global-set-key "\C-xrb" 'bookmark-set)
;;ブックマークに移動
(global-set-key "\C-xrm" 'bookmark-jump)

;;Ctr-x Ctr-bでバッファメニューを開き、カーソルを飛ばす
(global-set-key "\C-x\C-b" 'buffer-menu)

;;Fnキー設定
;;F1 goto-line設定
(global-set-key "\M-1" 'goto-line)
;;F2 switch-to-buffer
(global-set-key "\M-2" 'switch-to-buffer)

;;Ctr-x q : query-replace
(global-set-key "\C-xq" 'query-replace)

;;tramp settings
(setq tramp-default-method "ssh")

;;Set Ctrl-t to find-tag-other-window
(global-set-key "\C-xt" 'find-tag-other-window)

;;Reset grep-find
  (setq grep-find-command
  "find . -path '*/.svn' -prune -o -type f -print | xargs grep -I -n -e ")
