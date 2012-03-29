;;enable "R" to rename buffer in buffer menu mode
(defun Buffer-menu-rename-buffer (newname)
          "Rename buffer at line in window."
          (interactive
           (list (read-buffer "Rename buffer (to new name): "
                              (buffer-name (Buffer-menu-buffer t)))))
          (with-current-buffer (Buffer-menu-buffer t)
            (rename-buffer newname))
          (revert-buffer))
        
        (define-key Buffer-menu-mode-map "R" 'Buffer-menu-rename-buffer)
