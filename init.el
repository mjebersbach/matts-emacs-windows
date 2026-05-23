;;; General
(setq inhibit-startup-message t)

(scroll-bar-mode -1)
(tool-bar-mode -1)
(tooltip-mode -1)
(menu-bar-mode -1)
(fringe-mode 0)

(setq visual-bell t)

(setq backup-directory-alist `(("." . "~/.emacs.d/backup_files")))

(column-number-mode)
(global-display-line-numbers-mode 1)

(setq-default line-spacing 0.2)

(dolist (mode '(term-mode-hook
		shell-mode-hook
                eshell-mode-hook))
  (add-hook mode (lambda ()
		   (display-line-numbers-mode 0)
		   (define-key shell-mode-map (kbd "C-l") 'comint-clear-buffer))))

(add-hook 'org-mode-hook (lambda ()
			   (display-line-numbers-mode 0)))



(setq search-whitespace-regexp ".*?")

(setq savehist-mode 1)
(setq savehist-additional-variables '(register-alist kill-ring))

;;; Load paths (for non use-package installed packages)
(add-to-list 'load-path "~/.emacs.d/packages")

;;; File and major mode associations
(add-to-list 'auto-mode-alist '("\\.csproj\\'" . nxml-mode))

;;; Useful Keybindings
(keymap-global-set "C-," (lambda ()
			   (interactive)
			   (shrink-window-horizontally 10)))
(keymap-global-set "C-." (lambda ()
			   (interactive)
			   (enlarge-window-horizontally 10)))
(keymap-global-set "M-c" 'duplicate-line)
(keymap-global-set "C-c g" 'consult-ripgrep)
(keymap-global-set "C-c o" 'occur)

;;; Powershell
(setq explicit-shell-file-name "pwsh")

(require 'package)
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
			 ("melpa-stable" . "https://stable.melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;; -> initialize use-package on non linux
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

;;; Buffer Placement
(setq display-buffer-alist
      '(("\\*Occur\\*"
	 ;; list of display functions
	 (display-buffer-reuse-mode-window
	  display-buffer-below-selected)
	 ;; parameters
	 (window-height . fit-window-to-buffer)
	 (dedicated . t)
	 (body-function . (lambda (window) (select-window window)))
	 )))


;;; Fonts
(set-face-attribute 'default nil :font "Fira Code 15")
(set-face-attribute 'fixed-pitch nil :font "Fira Code 14")
(use-package all-the-icons
  :ensure t)
(use-package ligature
  :ensure t
  :config
  ;; Enable the "www" ligature in every possible major mode
  (ligature-set-ligatures 't '("www"))
  ;; Enable traditional ligature support in eww-mode, if the
  ;; `variable-pitch' face supports it
  (ligature-set-ligatures 'eww-mode '("ff" "fi" "ffi"))

  ;; Enable all Cascadia Code ligatures in programming modes
  (setq ligature-list '("|||>" "<|||" "<==>" "<!--" "####" "~~>" "***" "||=" "||>"
                                       ":::" "::=" "=:=" "===" "==>" "=!=" "=>>" "=<<" "=/=" "!=="
                                       "!!." ">=>" ">>=" ">>>" ">>-" ">->" "->>" "-->" "---" "-<<"
                                       "<~~" "<~>" "<*>" "<||" "<|>" "<$>" "<==" "<=>" "<=<" "<->"
                                       "<--" "<-<" "<<=" "<<-" "<<<" "<+>" "</>" "###" "#_(" "..<"
                                       "..." "+++" "/==" "///" "_|_" "www" "&&" "^=" "~~" "~@" "~="
                                       "~>" "~-" "**" "*>" "*/" "||" "|}" "|]" "|=" "|>" "|-" "{|"
                                       "[|" "]#" "::" ":=" ":>" ":<" "$>" "==" "=>" "!=" "!!" ">:"
                                       ">=" ">>" ">-" "-~" "-|" "->" "--" "-<" "<~" "<*" "<|" "<:"
                                       "<$" "<=" "<>" "<-" "<<" "<+" "</" "#{" "#[" "#:" "#=" "#!"
                                       "##" "#(" "#?" "#_" "%%" ".=" ".-" ".." ".?" "+>" "++" "?:"
                                       "?=" "?." "??" ";;" "/*" "/=" "/>" "//" "__" "~~" "(*" "*)"
                                       "\\\\" "://" ";;;"))

   (ligature-set-ligatures 'prog-mode ligature-list)
   (ligature-set-ligatures 'vue-mode ligature-list)

  ;; Enables ligature checks globally in all buffers. You can also do it
  ;; per mode with `ligatureX<-mode'.
  (global-ligature-mode t))

;;; Zen Mode
(use-package olivetti
  :ensure t
  :init
  (add-hook 'olivetti-mode-hook (lambda () (setq olivetti-body-width 100))))
(keymap-global-set "<f9>" 'olivetti-mode)

;;; Themes
(use-package doom-themes
  :ensure t
  :config
  ;; Global settings (defaults)
  (setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
        doom-themes-enable-italic t) ; if nil, italics is universally disabled
  
  (load-theme 'modus-vivendi-deuteranopia t)

  ;; Enable flashing mode-line on errors
  (doom-themes-visual-bell-config))

(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1))

;;; Minibuffer
(use-package vertico
  :ensure t
  :init
  (vertico-mode))

(use-package marginalia
  :ensure t
  :bind(:map minibuffer-local-map
	     ("M-A" . marginalia-cycle))
  :init
  (marginalia-mode))

(use-package orderless
  ;; Wildcard searching
  :ensure t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles partial-completion)))))

(use-package consult
  :ensure t
  :bind
  ("C-x b". consult-buffer)
  :config
  (defvar consult-source-dired
    `(:name "Dired"
	    :narrow   ?D
	    :category buffer
	    :face     consult-buffer
	    :history  buffer-name-history
	    :state    ,#'consult--buffer-state
	    :items ,(lambda ()
		      (consult--buffer-query :mode 'dired-mode :as #'consult--buffer-pair))))

  (defvar consult-source-eshell
    `(:name "Eshell"
	    :narrow   ?E
	    :category buffer
	    :face     consult-buffer
	    :history  buffer-name-history
	    :state    ,#'consult--buffer-state
	    :items ,(lambda ()
		      (consult--buffer-query :mode 'eshell-mode :as #'consult--buffer-pair))))

  (add-to-list 'consult-buffer-sources 'consult-source-dired 'append)
  (add-to-list 'consult-buffer-sources 'consult-source-eshell 'append)
  )

(defun mje/select-text-in-delimiters (delimiter)
  "Select text between the nearest left and right delimiters."
  (interactive)
  
  (let (start end alt-delimiter inclusive)
    (setq-default inclusive t)
    (catch 'bail-out
      (cond
       ((string-equal delimiter "(")
	(setq alt-delimiter ")")
	(setq inclusive nil))
       ((string-equal delimiter "[")
	(setq alt-delimiter "]")
	(setq inclusive nil))
       ((string-equal delimiter "{")
	(setq alt-delimiter "}")
	(setq inclusive nil))
       ((string-equal delimiter ")")
	(setq inclusive t)
	(setq delimiter "(")
	(setq alt-delimiter ")")
	)
       ((string-equal delimiter "]")
	(setq inclusive t)
	(setq delimiter "[")
	(setq alt-delimiter "]")
	)       
       ((string-equal delimiter "}")
	(setq inclusive t)
	(setq delimiter "{")
	(setq alt-delimiter "}")
	)
       (t (progn
	    (message (format "delimiter '%s' not defined" delimiter))
	    (throw 'bail-out "delim not found"))))

      (skip-chars-backward (concat "^" delimiter)) 
      (setq start (point))
      (when inclusive
	(backward-char 1))
      (skip-chars-forward (concat "^" alt-delimiter))
      (setq end (point))
      (when inclusive
	(forward-char 1))
      (set-mark start))))

(keymap-global-set "C-c (" (lambda () (interactive) (mje/select-text-in-delimiters "(")))
(keymap-global-set "C-c [" (lambda () (interactive) (mje/select-text-in-delimiters "[")))
(keymap-global-set "C-c {" (lambda () (interactive) (mje/select-text-in-delimiters "{")))
(keymap-global-set "C-c )" (lambda () (interactive) (mje/select-text-in-delimiters ")")))
(keymap-global-set "C-c ]" (lambda () (interactive) (mje/select-text-in-delimiters "]")))
(keymap-global-set "C-c }" (lambda () (interactive) (mje/select-text-in-delimiters "}")))

(use-package embark
  :ensure t

  :bind
  (("C-c ." . embark-act)         ;; pick some comfortable binding
   ("C-c ;" . embark-dwim)        ;; good alternative: M-.
   ("C-h B" . embark-bindings))   ;; alternative for `describe-bindings'

  :init

  ;; Optionally replace the key help with a completing-read interface
  (setq prefix-help-command #'embark-prefix-help-command)

  ;; Show the Embark target at point via Eldoc. You may adjust the
  ;; Eldoc strategy, if you want to see the documentation from
  ;; multiple providers. Beware that using this can be a little
  ;; jarring since the message shown in the minibuffer can be more
  ;; than one line, causing the modeline to move up and down:

  ;; (add-hook 'eldoc-documentation-functions #'embark-eldoc-first-target)
  ;; (setq eldoc-documentation-strategy #'eldoc-documentation-compose-eagerly)

  ;; Add Embark to the mouse context menu. Also enable `context-menu-mode'.
  ;; (context-menu-mode 1)
  ;; (add-hook 'context-menu-functions #'embark-context-menu 100)

  :config

  ;; Hide the mode line of the Embark live/completions buffers
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none)))))

;; Consult users will also want the embark-consult package.
(use-package embark-consult
  :ensure t) ; only need to install it, embark loads it after consult if found

;;; WGrep (wgrep.el in ~/.emacs.d)
(require 'wgrep)

(require 'org)

(setq org-directory "c:/users/matthew.ebersbach/org"
      org-agenda-files '("c:/users/matthew.ebersbach/org/agendas")
      org-agenda-start-with-log-mode t
      org-log-done 'time
      org-log-into-drawer t)

;;; Org Mode - Resize Headings
(dolist (face '((org-level-1 . 1.35)
		(org-level-2 . 1.3)
		(org-level-3 . 1.2)
		(org-level-4 . 1.1)
		(org-level-5 . 1.0)
		(org-level-6 . 0.9)
		(org-level-7 . 0.8)
		(org-level-8 . 0.7)))
  (set-face-attribute (car face) nil :font "DejaVu Sans Mono" :weight 'bold :height (cdr face)))

;;; Org Mode - Document title larger
(set-face-attribute 'org-document-title nil :font "Cantarell" :weight 'bold :height 1.8)

(require 'org-indent)
(set-face-attribute 'org-indent nil :inherit '(org-hide fixed-pitch))
(set-face-attribute 'org-block nil            :foreground nil :inherit 'fixed-pitch :height 0.85)
(set-face-attribute 'org-code nil             :inherit '(shadow fixed-pitch) :height 0.85)
(set-face-attribute 'org-indent nil           :inherit '(org-hide fixed-pitch) :height 0.85)
(set-face-attribute 'org-verbatim nil         :inherit '(shadow fixed-pitch) :height 0.85)
(set-face-attribute 'org-special-keyword nil  :inherit '(font-lock-comment-face
fixed-pitch))
(set-face-attribute 'org-meta-line nil        :inherit '(font-lock-comment-face fixed-pitch))
(set-face-attribute 'org-checkbox nil         :inherit 'fixed-pitch)

;;; Text beautification
(setq org-adapt-indentation t
      org-hide-leading-stars t
      org-hide-emphasis-markers t
      org-pretty-entities t
      org-ellipsis "  ·")

;;; Show souce using major mode of language
(setq org-src-fontify-natively t
      org-src-tab-acts-natively t
      org-edit-src-content-indentation 0)

;;; Todo States
(setq org-todo-keywords
      '((sequence "TODO" "IN-PROCESS" "NEEDS-INFO" "|" "DONE")))

(use-package org-modern
  :ensure t
  :after org
  :config
  (setq org-modern-star 'replace)
  (setq org-modern-replace-stars '("◉" "▣" "◈" "○" "□" "◇" "▷" "▫")))

(use-package org-modern-indent
  :load-path "~/.emacs.d/packages/org-modern-indent")

;;; Centering / Line Breaks
(add-hook 'org-mode-hook 'visual-line-mode)
(add-hook 'org-mode-hook 'olivetti-mode)
(add-hook 'org-mode-hook 'variable-pitch-mode)
(add-hook 'org-mode-hook 'org-modern-mode)
(add-hook 'org-mode-hook 'org-indent-mode)
(add-hook 'org-mode-hook 'org-modern-indent-mode)

;;; LSP
(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
	       '(csharp-mode . ("csharp-ls"))))
;;; Completion
(use-package corfu
  :ensure t
  :init
  (global-corfu-mode))

(setq corfu-auto t
      corfu-auto-delay 0.2
      corfu-auto-trigger "."
      corfu-quit-no-match 'separator)

(use-package emacs
  :ensure t
  :custom
  (tab-always-indent 'complete)
  (text-mode-ispell-word-completion nil)
  (read-extended-command-predicate #'command-completion-default-include-p))

(defun mje/consult-ripgrep-at-point ()
  "Search for the word at point using consult-ripgrep."
  (interactive)
  (consult-ripgrep nil (thing-at-point 'symbol t)))

(add-hook 'csharp-mode-hook
          (lambda ()
             (define-key csharp-mode-map (kbd "C-c G") 'mje/consult-ripgrep-at-point)))
