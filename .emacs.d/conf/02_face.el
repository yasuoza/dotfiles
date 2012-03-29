;;フォント設定
( if (eq window-system 'ns )
    (when (>= emacs-major-version 23)
      (set-face-attribute 'default nil
                          :family "monaco"
                          :height 124)
      (set-fontset-font
       (frame-parameter nil 'font)
       'japanese-jisx0208
       '("Hiragino Kaku Gothic Pro" . "iso10646-1"))
      (set-fontset-font
       (frame-parameter nil 'font)
       'japanese-jisx0212
       '("Hiragino Kaku Gothic Pro" . "iso10646-1"))
      (set-fontset-font
       (frame-parameter nil 'font)
       'mule-unicode-0100-24ff
       '("monaco" . "iso10646-1"))
      (setq face-font-rescale-alist
            '(("^-apple-hiragino.*" . 1.0)
              (".*osaka-bold.*" . 1.0)
              (".*osaka-medium.*" . 1.0)
              (".*courier-bold-.*-mac-roman" . 1.0)
              (".*monaco cy-bold-.*-mac-cyrillic" . 0.9)
              (".*monaco-bold-.*-mac-roman" . 0.9)
              ("-cdac$" . 1.3)))))


;; ウィンドウ設定
(global-font-lock-mode 1)
(if window-system (progn
  (setq initial-frame-alist '((width . 200) (height . 53) (top . 0) (left . 0)))
))
(setq frame-title-format (format "%%f - Emacs@%s" (system-name)))

;;選択範囲を反転させる
(setq transient-mark-mode t)

;; 色つける
(global-font-lock-mode t)
(setq-default transient-mark-mode t)
(require 'font-lock)

;; 縦分割とかでも行を折り返す
(setq truncate-partial-width-windows nil)

;;透明化 & カラーテーマ設定
(require 'color-theme)
(color-theme-initialize)
;;(color-theme-dark-laptop)
(color-theme-blackboard)
(set-face-background 'region "gray50")
(setq default-frame-alist (cons '(alpha . (95 90)) default-frame-alist))
