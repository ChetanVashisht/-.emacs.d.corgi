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
(setq cider-lein-command "~/bin/lein")
(setq cider-eval-result-prefix " ;;=> ")

;; TODO: CHECK THIS
;; (define-obsolete-variable-alias 'cider-default-repl-command 'cider-jack-in-default)
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

;; Adding esacpe from insert mode
;; https://stackoverflow.com/a/13543550/4110233
(use-package key-chord)
(setq key-chord-two-keys-delay 0.3)
(key-chord-define evil-insert-state-map "jj" 'evil-normal-state)
(key-chord-define evil-insert-state-map ";;" 'evil-forward-char)
(key-chord-define evil-normal-state-map "fh" 'evil-window-left)
(key-chord-define evil-normal-state-map "fl" 'evil-window-right)
(key-chord-define evil-normal-state-map "fk" 'evil-window-up)
(key-chord-define evil-normal-state-map "fj" 'evil-window-down)
(key-chord-mode 1)

;; https://stackoverflow.com/a/12916499/4110233
(define-key evil-ex-map "E" 'find-file)

;; https://stackoverflow.com/a/40570659/4110233
(define-key cider-repl-mode-map (kbd "<up>") 'cider-repl-previous-input)
(define-key cider-repl-mode-map (kbd "<down>") 'cider-repl-next-input)


(use-package org
  :config
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t)
     (python . t)
     (clojure . t)))
  (setq org-ellipsis "⤵")
  (setq org-edit-src-content-indentation 0)
  (setq org-startup-folded t)
  (setq-default left-margin-width 2 right-margin-width 0) ; Define new widths.
  (set-window-buffer nil (current-buffer))                ; Use them now.
  (setq org-blank-before-new-entry nil)
  (setq-default line-spacing 6)
  (setq org-babel-clojure-backend 'cider)
  (setq org-confirm-babel-evaluate nil)
  (require 'org-tempo)
  (require 'cider)
  (require 'org-journal)
  (require 'key-chord)
  (require 'org-habit)
  (setq org-src-fontify-natively t)
  (setq org-hide-emphasis-markers t)
  (setq org-agenda-log-mode-items '(closed clock state))
  (setq org-fontify-quote-and-verse-blocks t)
  (setq org-startup-indented t)
  (setq org-agenda-start-with-log-mode '(closed clock state))
  (global-set-key (kbd "C-M-<return>") 'org-insert-subheading)
  (setq org-agenda-include-inactive-timestamps nil)
  (setq org-agenda-use-time-grid nil)
  (setq org-reverse-note-order t)
  (setq org-toggle-pretty-entities t)
  (setq org-todo-keywords
        '((sequence "TODO(t)" "IN-PROGRESS(i)" "|" "REJECTED(r@)" "FAILED(f@)" "DONE(d@)")))
  (setq org-refile-targets
        '((nil :maxlevel . 3)
          (org-agenda-files :maxlevel . 1)))
  (setq org-capture-templates
        '(("b" "Bills" entry (filename+headline "~/GTD/tasks.org" "Bills")
           "* [ ] Internet\n* [ ] Electricity")))

  ;; https://zzamboni.org/post/beautifying-org-mode-in-emacs/
  (let* ((variable-tuple
          (cond ((x-list-fonts "ETBembo")         '(:font "ETBembo"))
                ((x-list-fonts "Source Sans Pro") '(:font "Source Sans Pro"))
                ((x-list-fonts "Lucida Grande")   '(:font "Lucida Grande"))
                ((x-list-fonts "Verdana")         '(:font "Verdana"))
                ((x-family-fonts "Sans Serif")    '(:family "Sans Serif"))
                (nil (warn "Cannot find a Sans Serif Font.  Install Source Sans Pro."))))
         (base-font-color     (face-foreground 'default nil 'default))
         (headline           `(:inherit default :weight bold :foreground ,base-font-color)))

    (custom-theme-set-faces
     'user
     `(org-level-8 ((t (,@headline ,@variable-tuple))))
     `(org-level-7 ((t (,@headline ,@variable-tuple))))
     `(org-level-6 ((t (,@headline ,@variable-tuple))))
     `(org-level-5 ((t (,@headline ,@variable-tuple))))
     `(org-level-4 ((t (,@headline ,@variable-tuple))))
     `(org-level-3 ((t (,@headline ,@variable-tuple))))
     `(org-level-2 ((t (,@headline ,@variable-tuple))))
     `(org-level-1 ((t (,@headline ,@variable-tuple :foregorund "blue"))))
     `(org-document-title ((t (,@headline ,@variable-tuple :height 2.0 :underline nil))))))

  (custom-theme-set-faces
   'user
   '(variable-pitch ((t (:family "ETBembo" :height 200 :weight medium))))
   '(fixed-pitch ((t ( :family "Fira Code Retina" :height 160)))))
  )
(add-hook 'org-mode-hook 'variable-pitch-mode)
(add-hook 'org-mode-hook 'visual-fill-column-mode)
(setq-default visual-fill-column-center-text t)

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
 '(cider-comment-postfix "")
 '(cider-comment-prefix ";; ↪ ")
 '(helm-minibuffer-history-key "M-p")
 '(org-agenda-files
   '("~/GTD/cooking.org" "~/GTD/articles/" "~/GTD/journal" "~/GTD/explore.org" "~/GTD/goals.org" "~/GTD/reading" "~/GTD/tasks.org" "~/GTD/software.org" "~/GTD/fitness.org" "~/GTD/appliances.org" "~/GTD/travel.org" "~/GTD/home.org" "~/GTD/hobbies.org" "~/GTD/coaching.org" "~/GTD/random.org" "~/GTD/relationships.org"))
 '(org-fontify-emphasized-text t)
 '(org-fontify-whole-block-delimiter-line nil)
 '(org-journal-date-format "<%Y-%m-%d %a>")
 '(org-journal-dir "~/GTD/journal/")
 '(org-journal-file-format "%Y-%m-%V.org")
 '(org-journal-file-type 'weekly)
 '(org-src-window-setup 'current-window)
 '(safe-local-variable-values
   '((eval font-lock-add-keywords nil
           `((,(concat "("
                       (regexp-opt
                        '("sp-do-move-op" "sp-do-move-cl" "sp-do-put-op" "sp-do-put-cl" "sp-do-del-op" "sp-do-del-cl")
                        t)
                       "\\_>")
              1 'font-lock-variable-name-face)))
     (elisp-lint-indent-specs
      (if-let* . 2)
      (when-let* . 1)
      (let* . defun)
      (nrepl-dbind-response . 2)
      (cider-save-marker . 1)
      (cider-propertize-region . 1)
      (cider-map-repls . 1)
      (cider--jack-in . 1)
      (cider--make-result-overlay . 1)
      (insert-label . defun)
      (insert-align-label . defun)
      (insert-rect . defun)
      (cl-defun . 2)
      (with-parsed-tramp-file-name . 2)
      (thread-first . 0)
      (thread-last . 0))
     (checkdoc-package-keywords-flag)))
 '(warning-suppress-log-types '((magit)))
 '(warning-suppress-types '((use-package))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(fixed-pitch ((t (:family "Fira Code Retina" :height 160))))
 '(org-block-begin-line ((t (:extend nil :background "gray0" :foreground "gray54" :slant italic :weight ultra-light :height 1.0 :width condensed))))
 '(org-block-end-line ((t (:extend nil :background "#000000" :foreground "gray54" :slant italic :weight ultra-light :height 1.0 :width condensed))))
 '(org-code ((t (:foreground "brown1"))))
 '(org-date ((t (:foreground "Brown" :overline nil :underline t))))
 '(org-document-info-keyword ((t (:foreground "#b9ca4a" :slant normal :width condensed))))
 '(org-document-title ((t (:inherit default :weight bold :foreground "#eaeaea" :font "Lucida Grande" :height 2.0 :underline nil))))
 '(org-level-1 ((t (:inherit default :weight bold :foreground "#eaeaea" :font "Lucida Grande" :foregorund "blue"))))
 '(org-level-2 ((t (:inherit default :weight bold :foreground "#eaeaea" :font "Lucida Grande"))))
 '(org-level-3 ((t (:inherit default :weight bold :foreground "#eaeaea" :font "Lucida Grande"))))
 '(org-level-4 ((t (:inherit default :weight bold :foreground "#eaeaea" :font "Lucida Grande"))))
 '(org-level-5 ((t (:inherit default :weight bold :foreground "#eaeaea" :font "Lucida Grande"))))
 '(org-level-6 ((t (:inherit default :weight bold :foreground "#eaeaea" :font "Lucida Grande"))))
 '(org-level-7 ((t (:inherit default :weight bold :foreground "#eaeaea" :font "Lucida Grande"))))
 '(org-level-8 ((t (:inherit default :weight bold :foreground "#eaeaea" :font "Lucida Grande"))))
 '(org-quote ((t (:inherit org-block :extend nil :background "gray0" :foreground "thistle4" :slant normal :weight normal :width normal :foundry "sans" :family "serif"))))
 '(variable-pitch ((t (:family "ETBembo" :height 200 :weight medium)))))
(put 'narrow-to-region 'disabled nil)

;; https://emacs.stackexchange.com/a/62403/30873
(define-key cider-mode-map (kbd "C-c C-p")
  (lambda ()
    (interactive)
    (let* ((insert-before nil)
           (bounds (cider-last-sexp 'bounds))
           (insertion-point (nth (if insert-before 0 1) bounds))
           (comment-postfix (concat cider-comment-postfix
                                    (if insert-before "\n" ""))))
      (cider-interactive-eval (concat "(with-out-str " (cider-last-sexp) " )")
                              (cider-eval-pprint-with-multiline-comment-handler
                               (current-buffer)
                               (set-marker (make-marker) insertion-point)
                               cider-comment-prefix
                               cider-comment-continued-prefix
                               comment-postfix)
                              bounds
                              (cider--nrepl-print-request-map fill-column)))))


(add-hook 'org-font-lock-hook #'aj/org-indent-quotes)

;; https://emacs.stackexchange.com/a/44153/30873
(defun aj/org-indent-quotes (limit)
  (let ((case-fold-search t))
    (while (search-forward-regexp "^[ \t]*#\\+begin_quote" limit t)
      (let ((beg (1+ (match-end 0))))
        ;; on purpose, we look further than LIMIT
        (when (search-forward-regexp "^[ \t]*#\\+end_quote" nil t)
          (let ((end (1- (match-beginning 0)))
                (indent (propertize "    " 'face 'org-hide)))
            (add-text-properties beg end (list 'line-prefix indent
                                               'wrap-prefix indent))))))))


;; https://www.reddit.com/r/emacs/comments/9oylrh/comment/e7xob8l/
(require 'package)

(add-to-list 'package-archives '("org" . "https://orgmode.org/elpa/"))
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/"))

(setq package-enable-at-startup nil)
(package-initialize)

;; Use variable width font faces in current buffer
(defun my-buffer-face-mode-variable ()
  "Set font to a variable width (proportional) fonts in current buffer"
  (interactive)
  (setq buffer-face-mode-face '(:family "sans-serif" :height 100 :size 25))
  (buffer-face-mode))

;; Use monospaced font faces in current buffer
(defun my-buffer-face-mode-fixed ()
  "Sets a fixed width (monospace) font in current buffer"
  (interactive)
  (setq buffer-face-mode-face '(:family "Inconsolata" :height 100 :size 25))
  (buffer-face-mode))

;; Set default font faces for Info and ERC modes
(add-hook 'org-mode-hook 'my-buffer-face-mode-fixed)
;;(add-hook 'Info-mode-hook 'my-buffer-face-mode-variable)

;; https://lists.gnu.org/archive/html/help-gnu-emacs/2010-07/msg00291.html
;; (cgv/www-get-page-title "https://www.reddit.com/r/emacs/comments/jtoomj/org_docs_get_title/")
(defun cgv/www-get-page-title (url)
  "Get's title of a webpage"
  (let ((title))
    (with-current-buffer (url-retrieve-synchronously url)
      (goto-char (point-min))
      (re-search-forward "<title>\s*\\([^<]*\\)\s*</title>" nil t 1)
      (setq title (match-string 1))
      (goto-char (point-min))
      (decode-coding-string title (intern "latin-1")))))

(defun cgv/replace-spaces (title)
  "replaces the spaces in the title with hyphens"
  (let* ((rep1 (replace-regexp-in-string "\s+" "-" title))
         (rep2 (replace-regexp-in-string "[^a-zA-z0-9\\-]" "" rep1))
         (rep3 (replace-regexp-in-string "-+" "-" rep2)))
    rep3))

;; (cgv/replace-spaces "org docs get #+TITLE: : emacs")

(defun cgv/replace-in-creator-template (template title url creator)
  (let* ((temp (cgv/replace-in-template template title url))
         (out (replace-regexp-in-string "\{creator\}" creator temp)))
    out))

(defun cgv/replace-in-template (template title url)
  (let* ((out1 (replace-regexp-in-string "\{title\}" title template))
         (out2 (replace-regexp-in-string "\{date\}" (format-time-string "<%F %a>" (current-time)) out1))
         (out3 (replace-regexp-in-string "\{source\}" url out2)))
    out3))

                                        ;(cgv/replace-in-template course-template "hello" "url" )
                                        ;(cgv/replace-in-creator-template course-template "hello" "url" "ins")

(setq article-template "#+TITLE: {title}
#+DATE: {date}
#+SOURCE: {source}")

(setq course-template "#+TITLE: {title}
#+DATE: {date}
#+SOURCE: {source}
#+CREATOR: {creator}")

(defun cgv/new-article ()
  "Creates a new article review"
  (interactive)
  (let* ((url (read-string "Link:"))
         (page-title (cgv/www-get-page-title url))
         (article-title (cgv/replace-spaces page-title))
         (path "~/GTD/articles/")
         (filename (concat article-title ".org"))
         (substituted-template (cgv/replace-in-template article-template article-title url))
         )
    (print url)
    (print page-title)
    (print article-title)
    (find-file (concat path filename))
    (with-current-buffer filename (insert substituted-template))
    (evil-insert-newline-below)
    (evil-insert-newline-below)
    ))


;; TODO: Scrape skillshare for courses
;; TODO: query open library for chapters:
;; https://openlibrary.org/dev/docs/api/books, https://stackoverflow.com/questions/27955577/list-chapters-of-a-book-from-a-public-books-api
;; (require 'elquery)
;; (with-current-buffer (url-retrieve-synchronously "https://www.skillshare.com/classes/Mastering-iMovie/1015878170")
;;   (message "%s" (mapcar 'elquery-text (elquery-$ "h1 class-details-header-name title"
;;                                                  (elquery-read-string (buffer-string))))))

(require 'elquery)
(defun cgv/get-html (url)
  "Get the html content of a url"
  (elquery-read-url url))

(defun cgv/get-title (html)
  "Get the webpage title"
  (elquery-full-text (car (elquery-$ "h1" html)) " "))

(defun cgv/get-instructor (html)
  "Get the instructor"
  (elquery-full-text (car (elquery-$ ".class-details-header-teacher" html)) " "))

(defun cgv/get-lessons (html)
  "getting the lesson titles"
  (mapcar (lambda (el) (elquery-full-text el)) (elquery-$ ".session-item" html)))

(defun cgv/new-course-skillshare ()
  "Creates a new skillshare review"
  (interactive)
  (let* ((url (read-string "Link:"))
         (html (cgv/get-html url))
         (page-title (cgv/get-title html))
         (instructor (cgv/get-instructor html))
         (lessons (cgv/get-lessons html))
         (course-title (cgv/replace-spaces page-title))
         (path "~/GTD/courses/")
         (filename (concat course-title ".org"))
         (substituted-template (cgv/replace-in-creator-template course-template course-title url instructor))
         (formatted-lessons (reverse (mapcar (lambda (el) (replace-regexp-in-string "^\\([0-9]+\\)\\." "\\1. " el)) lessons))))
    (find-file (concat path filename))
    (with-current-buffer filename (insert substituted-template))
    (evil-insert-newline-below)
    (evil-insert-newline-below)
    (with-current-buffer filename (insert "* Lessons\n"))
    (with-current-buffer filename (insert (mapconcat 'identity formatted-lessons "\n")))))

;; https://emacs.stackexchange.com/a/5909/30873
(add-hook 'window-setup-hook 'toggle-frame-fullscreen t)

(add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.css?\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.js\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.js\\'" . js2-mode))

(setq-default left-margin-width 10)
(setq-default line-spacing 0.25)

(use-package helm-dash
  :hook
  ;; (python-mode . (lambda () (setq-local helm-dash-docsets '("Python_3"))))
  ;; (emacs-lisp-mode . (lambda () (setq-local helm-dash-docsets '("Emacs_lisp"))))
  (web-mode . (lambda () (setq-local dash-docs-docsets '("HTML" "CSS" "JavaScript"))))
  (js2-mode . (lambda () (setq-local dash-docs-docsets '("HTML" "CSS" "JavaScript")))))

(add-hook 'js2-mode-hook #'lsp-deferred)
(add-hook 'web-mode-hook #'lsp-deferred)
(add-hook 'python-mode #'lsp-deferred)

(add-hook 'js2-mode-hook #'yas-minor-mode-on)
(add-hook 'web-mode-hook #'yas-minor-mode-on)
;; (add-hook 'clojure-mode-hook #'lsp-deferred)
;; (add-hook 'emacs-lisp-mode-hook #'lsp-deferred)

(require 'clj-refactor)

(defun my-clojure-mode-hook ()
  (clj-refactor-mode 1)
  (yas-minor-mode 1) ; for adding require/use/import statements
  ;; This choice of keybinding leaves cider-macroexpand-1 unbound
  (cljr-add-keybindings-with-prefix "C-c C-m")
  (hs-minor-mode)
  (eldoc-mode)
  ;; https://emacs.stackexchange.com/questions/18561/display-function-arguments-in-echo-area
  )

(add-hook 'clojure-mode-hook #'my-clojure-mode-hook)

(exec-path-from-shell-initialize)

(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :hook
  (sh-mode . lsp)
  :init
  :config
  (define-key lsp-mode-map (kbd "M-SPC") #'company-complete)
  (lsp-enable-which-key-integration t))

(setq cljr-warn-on-eval nil)

(setq mac-command-modifier 'control)

(omni-quotes-mode t)

(defun cgv/make-into-test ()
  ;; Need to hijack:
  ;; (defun cider-eval-last-sexp-and-replace ())
  "Evaluate the expression preceding point and replace it with its result."
  (interactive)
  (let ((last-sexp (cider-last-sexp)))
    ;; we have to be sure the evaluation won't result in an error
    (cider-nrepl-sync-request:eval last-sexp)
    ;; seems like the sexp is valid, so we can safely kill it
    (let ((opoint (point)))
      (clojure-backward-logical-sexp)
      (kill-region (point) opoint))
    (cider-interactive-eval last-sexp
                            (cgv/cider-eval-print-handler)
                            nil
                            (cider--nrepl-pr-request-map))))

(defun cgv/cider-eval-print-handler (&optional buffer)
  "Make a handler for evaluating and printing result in BUFFER."
  ;; NOTE: cider-eval-register behavior is not implemented here for performance reasons.
  ;; See https://github.com/clojure-emacs/cider/pull/3162
  (nrepl-make-response-handler (or buffer (current-buffer))
                               (lambda (buffer value)
                                 (with-current-buffer buffer
                                   (insert
                                    (if (derived-mode-p 'cider-clojure-interaction-mode)
                                        (format "\n%s\n" (cgv/substitute-result value))
                                      (cgv/substitute-result value)))))
                               (lambda (_buffer out)
                                 (cider-emit-interactive-eval-output out))
                               (lambda (_buffer err)
                                 (cider-emit-interactive-eval-err-output err))
                               ()))

(setq result-test-template "(testing \"Testing {testname}\"
(is (= {res} {expr})))")

(setq result-test-template-2 "(is (= {res} {expr}))")

;; (defun cgv/expr-testing? ()
;;   (interactive)
;;   (let ((s (sexp-at-point)))
;;     (message s))

(defun cgv/get-function-name (expr)
  (progn
    (string-match "^(\\([a-zA-Z0-9!?_-]+\\)" expr)
    (match-string 1 expr)))

(defun cgv/substitute-result (result)
  (let* ((quoted (replace-regexp-in-string "^(" "'(" result))
         (rep (replace-regexp-in-string "\{res\}" quoted result-test-template))
         (expr (substring-no-properties (car kill-ring)))
         (fn-name (cgv/get-function-name expr))
         (with-test-name (replace-regexp-in-string "\{testname\}" fn-name rep))
         (out (replace-regexp-in-string "\{expr\}" expr with-test-name)))
    out))

(global-set-key (kbd "C-c t") 'cgv/make-into-test)

(global-unset-key (kbd "C-q"))
(define-key evil-normal-state-map (kbd "C-q") 'evil-jump-forward)


;; Limelight mode in vim equivalent
;; Checkout hl-mode with hl-line-range-function

;; For blinking cursor on switching windows
(beacon-mode)

;; For <C-v> to paste globally
(cua-mode)


(load-file (expand-file-name "hide-comnt.el" user-emacs-directory))
(require 'hide-comnt)
