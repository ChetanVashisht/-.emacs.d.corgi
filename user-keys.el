;;; -*- no-byte-compile: t -*-

;; This is your user keys file, here you can configure key bindings that will
;; get added to Corgi. You can also override Corgi's default bindings this way.
;;
;; Bindings here are nested, e.g. `("SPC" ("b" ("k" kill-buffer)))' means that
;; "space" followed by "b" and then "k" will invoke `M-x kill-buffer'.
;;
;; You can add a descriptions before the command, this will show up in a pop-up
;; when you press the prefix key and wait a bit. (This uses which-key)
;;
;; `("SPC" ("b" ("k" "Choose a buffer to kill" kill-buffer)))'
;;
;; Instead of a prefix key you can use a symbol like `normal' or `insert', which
;; designates the Evil state (what vim calls the mode). `global' means any
;; state, `normal|visual' means either normal or visual.
;;
;; Instead of a command like `kill-buffer' you can put a keyword like
;; `:eval/buffer'. This is called a "signal". In the `corgi-signals' (or
;; `user-signals') file these are bound to specific commands based on the major
;; mode. E.g. in Emacs Lisp `:eval/buffer' means `eval-buffer', whereas in
;; Clojure it means `cider-eval-buffer'.

(bindings
 ;; "global" bindings are always active regardless of Evil's "state" (= vim mode)
 ;; If you don't provide this the default is `normal'.
 (global
                                        ;("C-k" "Move to right split window" evil-window-up)
                                        ;("C-j" "Move to down split window" evil-window-down)
                                        ;("C-j" "Move to down split window" evil-window-down)
  )

 (motion
  (":" "Barf" sp-backward-barf-sexp)
  ("F" "Slurp" sp-backward-slurp-sexp)
  ("{" "Barf" :sexp/barf-forward)
  ("}" "Slurp" :sexp/slurp-forward)
  (";" "Execute" evil-ex))

 (normal|visual
  (">" "Right-shift" evil-shift-right)
  ("<" "Left-shift" evil-shift-left)
  ("k" "up" evil-previous-visual-line)
  ("j" "down" evil-next-visual-line)
  )


 (normal|visual
  ("<backspace>" "Switch to previous Buffer" corgi/switch-to-previous-buffer)
  ("SPC"
   ("0" "Select Treemacs" treemacs-select-window)
   ("f"
    ("t" "Turn Treemacs on/off" treemacs)
    ("T" "Focus current file in file tree" treemacs-find-file))
   )))
