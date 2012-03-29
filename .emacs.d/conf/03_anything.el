(require 'anything)
(require 'anything-config)
(define-key global-map (kbd "C-x b") 'anything)

(setq anything-sources
      '(anything-c-source-buffers+
        anything-c-source-recentf
        anything-c-source-files-in-current-dir
        ))

;; anything-complete
(require 'anything-complete)
;; Automatically collect symbols by 150 secs
(anything-lisp-complete-symbol-set-timer 150)



;;; anything-c-moccurの設定
(require 'anything-c-moccur)
;; カスタマイズ可能変数の設定(M-x customize-group anything-c-moccur でも設定可能)
(setq anything-c-moccur-anything-idle-delay 0.2 ;`anything-idle-delay'
      anything-c-moccur-higligt-info-line-flag t ; `anything-c-moccur-dmoccur'などのコマンドでバッファの情報をハイライトする
      anything-c-moccur-enable-auto-look-flag t ; 現在選択中の候補の位置を他のwindowに表示する
      anything-c-moccur-enable-initial-pattern t) ; `anything-c-moccur-occur-by-moccur'の起動時にポイントの位置の単語を初期パターンにする


;; anything-etags+.el
(require 'anything-etags+)
(global-set-key "\M-." 'anything-etags+-select-one-key)


;;; キーバインドの割当(好みに合わせて設定してください)
(global-set-key (kbd "M-o") 'anything-c-moccur-occur-by-moccur) ;バッファ内検索
(global-set-key (kbd "C-M-o") 'anything-c-moccur-dmoccur) ;ディレクトリ
(add-hook 'dired-mode-hook ;dired
          '(lambda ()
             (local-set-key (kbd "O") 'anything-c-moccur-dired-do-moccur-by-moccur)))


;; Set anythig faces
(set-face-background 'anything-header "DarkGreen")
(set-face-foreground 'anything-header "yellow")


