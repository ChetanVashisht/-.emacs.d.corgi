;; This is your Emacs init file, it's where all initialization happens. You can
;; open it any time with `SPC f e i' (file-emacs-init)

;; `bootstrap.el' contains boilerplate code related to package management. You
;; can follow the same pattern if you want to split out other bits of config.
(load-file (expand-file-name "bootstrap.el" user-emacs-directory))

;; What follows is *your* config. You own it, don't be afraid to customize it to
;; your needs. Corgi is just a set of packages. Comment out the next section and
;; you get a vanilla Emacs setup. You can use `M-x find-library' to look at the
;; package contents of each. If you want to tweak things in there then just copy
;; the code over to your `user-emacs-directory', load it with `load-file', and
;; edit it to your heart's content.

(setq evil-want-C-u-scroll t)
(setq evil-want-Y-yank-to-eol t)


(let ((straight-current-profile 'corgi))
  ;; Change a bunch of Emacs defaults, from disabling the menubar and toolbar,
  ;; to fixing modifier keys on Mac and disabling the system bell.
  (use-package corgi-defaults)

  ;; UI configuration for that Corgi-feel. This sets up a bunch of packages like
  ;; Evil, Smartparens, Ivy (minibuffer completion), Swiper (fuzzy search),
  ;; Projectile (project-aware commands), Aggressive indent, Company
  ;; (completion).
  (use-package corgi-editor)

  ;; The few custom commands that we ship with. This includes a few things we
  ;; emulate from Spacemacs, and commands for jumping to the user's init.el
  ;; (this file, with `SPC f e i'), or opening the user's key binding or signals
  ;; file.
  (use-package corgi-commands)

  ;; Extensive setup for a good Clojure experience, including clojure-mode,
  ;; CIDER, and a modeline indicator that shows which REPLs your evaluations go
  ;; to.
  ;; Also contains `corgi/cider-pprint-eval-register', bound to `,,', see
  ;; `set-register' calls below.
  (use-package corgi-clojure)

  ;; Emacs Lisp config, mainly to have a development experience that feels
  ;; similar to using CIDER and Clojure. (show results in overlay, threading
  ;; refactorings)
  (use-package corgi-emacs-lisp)

  ;; Change the color of the modeline based on the Evil state (e.g. green when
  ;; in insert state)
  (use-package corgi-stateline
    :config
    (global-corgi-stateline-mode))

  ;; Package which provides corgi-keys and corgi-signals, the two files that
  ;; define all Corgi bindings, and the default files that Corkey will look for.
  (use-package corgi-bindings)

  ;; Corgi's keybinding system, which builds on top of Evil. See the manual, or
  ;; visit the key binding and signal files (with `SPC f e k', `SPC f e K', `SPC
  ;; f e s' `SPC f e S')
  ;; Put this last here, otherwise keybindings for commands that aren't loaded
  ;; yet won't be active.
  (use-package corkey
    :config
    (corkey-mode 1)
    ;; Automatically pick up keybinding changes
    (corkey/load-and-watch)))

;; Load other useful packages you might like to use

;; Powerful Git integration. Corgi already ships with a single keybinding for
;; Magit, which will be enabled if it's installed (`SPC g g' or `magit-status').
(use-package magit)

;; Language-specific packages
(use-package markdown-mode)
(use-package yaml-mode)
(use-package typescript-mode)

;; Some other examples of things you could include. There's a package for
;; everything in Emacs, so if you're missing a specific feature, see if you
;; can't find a good package that provides it.

;; Color hex color codes so you can see the actual color.
(use-package rainbow-mode)


;; A hierarchical file browser, included here as an example of how to set up
;; custom keys, see `user-keys.el' (visit it with `SPC f e k').
(use-package treemacs
  :config
  (setq treemacs-follow-after-init t)
  (treemacs-project-follow-mode)
  (treemacs-git-mode 'simple))

(use-package treemacs-evil)
(use-package treemacs-projectile)

;; REPL-driven development for JavaScript, included as an example of how to
;; configure signals, see `user-signal.el' (visit it with `SPC f e s')
(use-package js-comint)

;; Start the emacs-server, so you can open files from the command line with
;; `emacsclient -n <file>' (we like to put `alias en="emacsclient -n"' in our
;; shell config).
(server-start)

;; Emacs has "registers", places to keep small snippets of text. We make it easy
;; to run a snippet of Clojure code in such a register, just press comma twice
;; followed by the letter that designates the register (while in a Clojure
;; buffer with a connected REPL). The code will be evaluated, and the result
;; pretty-printed to a separate buffer.

;; By starting a snippet with `#_clj' or `#_cljs' you can control which type of
;; REPL it will go to, in case you have both a CLJ and a CLJS REPL connected.
(set-register ?k "#_clj (do (require 'kaocha.repl) (kaocha.repl/run))")
(set-register ?K "#_clj (do (require 'kaocha.repl) (kaocha.repl/run-all))")
(set-register ?r "#_clj (do (require 'user :reload) (user/reset))")
(set-register ?g "#_clj (user/go)")
(set-register ?b "#_clj (user/browse)")

;; We like this theme because it looks nice and works well enough in terminals,
;; swap it out with whatever suits you.
(use-package color-theme-sanityinc-tomorrow
  :config
  (load-theme 'sanityinc-tomorrow-bright t))

;; Maybe set a nice font to go with it
(set-frame-font "Iosevka 22")

;; Enable our "connection indicator" for CIDER. This will add a colored marker
;; to the modeline for every REPL the current buffer is connected to, color
;; coded by type.
(corgi/enable-cider-connection-indicator)

;; Create a *scratch-clj* buffer for evaluating ad-hoc Clojure expressions. If
;; you make sure there's always a babashka REPL connection then this is a cheap
;; way to always have a place to type in some quick Clojure expression evals.
(with-current-buffer (get-buffer-create "*scratch-clj*")
  (clojure-mode))

;; Connect to Babashka if we can find it. This is a nice way to always have a
;; valid REPL to fall back to. You'll notice that with this all Clojure buffers
;; get a green "bb" indicator, unless there's a more specific clj/cljs REPL
;; available.
(when (executable-find "bb")
  (corgi/cider-jack-in-babashka))

;; Not a fan of trailing whitespace in source files, strip it out when saving.
(add-hook 'before-save-hook
          (lambda ()
            (when (derived-mode-p 'prog-mode)
              (delete-trailing-whitespace))))

;; Enabling desktop-save-mode will save and restore all buffers between sessions
;; (setq desktop-restore-frames nil)
;; (desktop-save-mode 1)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;; User Defined Config ;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; https://stackoverflow.com/a/64281978/4110233
(setq cider-lein-command "/Users/thechetan/bin/lein")

(define-obsolete-variable-alias 'cider-default-repl-command 'cider-jack-in-default)
(defcustom cider-jack-in-default (if (executable-find "clojure") 'clojure-cli 'lein)
  "The default tool to use when doing `cider-jack-in' outside a project.
This value will only be consulted when no identifying file types, i.e.
project.clj for leiningen or build.boot for boot, could be found.

As the Clojure CLI is bundled with Clojure itself, it's the default.
In the absence of the Clojure CLI (e.g. on Windows), we fallback
to Leiningen."
  :type '(choice (const 'lein)
                 (const 'boot)
                 (const 'clojure-cli)
                 (const 'shadow-cljs)
                 (const 'gradle))
  :group 'cider
  :safe #'symbolp
  :package-version '(cider . "0.9.0"))

;; Adding esacpe from insert mode
;; https://stackoverflow.com/a/13543550/4110233
(use-package key-chord)
(setq key-chord-two-keys-delay 0.3)
(key-chord-define evil-insert-state-map "jj" 'evil-normal-state)
(key-chord-mode 1)

;; https://stackoverflow.com/a/12916499/4110233
(define-key evil-ex-map "E" 'find-file)

;; https://stackoverflow.com/a/40570659/4110233
(define-key cider-repl-mode-map (kbd "<up>") 'cider-repl-previous-input)
(define-key cider-repl-mode-map (kbd "<down>") 'cider-repl-next-input)
(setq cider-repl-wrap-history t)
(setq cider-repl-history-size 1000)
(setq cider-repl-history-file "~/.cider-repl-history")
(global-visual-line-mode t)

(use-package evil-cleverparens
  :after (evil smartparens)
  :commands evil-cleverparens-mode
  :init
  (add-hook 'clojure-mode-hook #'evil-cleverparens-mode)
  (add-hook 'emacs-lisp-mode-hook #'evil-cleverparens-mode)
  (setq evil-cleverparens-complete-parens-in-yanked-region t)
  :config
  (setq evil-cleverparens-use-s-and-S nil)
  (evil-define-key '(normal visual) evil-cleverparens-mode-map
    "s" nil
    "S" nil
    "{" nil
    "}" nil
    "[" nil
    "]" nil
    (kbd "<tab>") 'evil-jump-item))

(use-package org
                                        ; :hook (org-mode . efs/org-mode-setup)
  :config
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t)
     (python . t)
     (clojure . t)))
  (setq org-ellipsis "⤵")
  (setq org-edit-src-content-indentation 0)
  (setq org-startup-folded t)
  (setq-default left-margin-width 10 right-margin-width 8) ; Define new widths.
  (set-window-buffer nil (current-buffer)) ; Use them now.
  (setq org-blank-before-new-entry t)
  (setq-default line-spacing 6)
  (setq org-babel-clojure-backend 'cider)
  (setq org-confirm-babel-evaluate nil)
  (require 'org-tempo)
  (require 'cider)
  (setq org-src-fontify-natively t)
  (setq org-fontify-quote-and-verse-blocks t)
  )


(use-package org-bullets
  :after org
  :hook (org-mode . org-bullets-mode)
  :custom
  (org-bullets-bullet-list '("◉" "○" "●" "○" "●" "○" "●")))

;; https://orgmode.org/worg/org-contrib/babel/languages/ob-doc-clojure.html

;; C-x n s: Zoom into section
;; C-x n b: Zoom into section
;; C-x n w: Zoom out
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(org-quote ((t (:inherit org-block :extend nil :background "gray5" :foreground "firebrick3" :box (:line-width 1 :color "gray38" :style pressed-button) :slant normal :weight normal :width normal)))))
