(setq scheme-program-name "gosh")
(require 'cmuscheme)

;; ���������ɒ����򒣲��Ē�˒ʬ�����ƒ��
;; ��������gosh�����󒥿��ג�꒥�����Ԓ����뒥���ޒ��ɒ���꒵������ޒ�����
(defun scheme-other-window ()
  "Run scheme on other window"
  (interactive)
  (switch-to-buffer-other-window
   (get-buffer-create "*scheme*"))
  (run-scheme scheme-program-name))
;; �����Β����ޒ��ɒ��Ctrl-cS��ǒ�ƒ�Ӓ�В����ޒ�����
(define-key global-map
  "\C-cS" 'scheme-other-window)

;; �ľ���/�ľ��咤Β�璸̒�˒�В�������뒳璸̒�����钤���ޒ�����
(show-paren-mode)


