(setq gc-cons-threshold 1000000000
      gc-cons-percentage 0.6)

(add-hook 'after-init-hook
          (lambda ()
            (setq gc-cons-threshold 800000
                  gc-cons-percentage 0.1)))

(defvar defaults/file-name-handler-alist file-name-handler-alist
  "Save default value for file-name-handler-alist")

(add-hook 'emacs-startup-hook
          (lambda ()
            (setq file-name-handler-alist defaults/file-name-handler-alist)))

(setq file-name-handler-alist nil)

(defvar emacs-dir (expand-file-name user-emacs-directory)
  "The path to this emacs.d directory.")

(defvar local-dir (concat emacs-dir "local/")
  "Root directory for local Emacs files.")

(defvar cache-dir (concat local-dir "cache/")
  "Where volatile files are storaged.")

(defun load-directory (dir)
  (let ((load-it (lambda (f) (load-file (concat (file-name-as-directory dir) f)))))
    (mapc load-it (directory-files dir nil "\\.el$"))))

(load-directory "~/.emacs.d/lisp")

(setq custom-file (concat cache-dir "custom.el"))

(require 'package)
(setq package-enable-at-startup nil)

(setenv "LC_ALL" "en_US.UTF-8")

;; MELPA repos for packages.
(setq package-archives
      '(("gnu"          . "http://elpa.gnu.org/packages/")
        ("melpa"        . "https://melpa.org/packages/")
        ("melpa-stable" . "https://stable.melpa.org/packages/")))

(setq package-archive-priorities
      '(("gnu"          . 10)
        ("melpa"        . 20)
        ("melpa-stable" . 0)))

(package-initialize)

;; Bootstrap 'straight.el

(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(straight-use-package 'use-package)

(straight-use-package 'el-patch)

(use-package mule
  :ensure nil
  :config
  (when (fboundp 'set-charset-priority)
    (set-charset-priority 'unicode))
  (prefer-coding-system        'utf-8)
  (set-terminal-coding-system  'utf-8)
  (set-keyboard-coding-system  'utf-8)
  (set-selection-coding-system 'utf-8)
  (setq locale-coding-system   'utf-8)
  (setq-default buffer-file-coding-system 'utf-8))

(use-package frame
  :ensure nil
  :bind ("C-z" . nil))

(use-package emacs
  :ensure nil
  :bind ("C-c C-c" . comment-or-uncomment-region-or-line)
  :custom
  (make-backup-files nil)
  (c-basic-offset 2)
  (tab-width 2)
  (tab-always-indent nil)
  (indent-tabs-mode nil)
  (show-paren-mode t)
  (electric-pair-mode t)
  (delete-selection-mode t)
  (global-auto-revert-mode t)
  (custom-file null-device "Do not store customizations")
                                        ; Smooth scrolling
  (redisplay-dont-pause t)
  (scroll-margin 5)
  (scroll-step 1)
  (scroll-conservatively 10000)
  (scroll-preserve-screen-position t)
  :config
  (put 'downcase-region 'disabled nil)
  (fset 'yes-or-no-p 'y-or-n-p)
  (load (concat user-emacs-directory "localrc.el") 'noerror))

(use-package simple
  :ensure nil
  :hook (before-save . delete-trailing-whitespace)
  :custom
  (column-number-mode t)
  (global-visual-line-mode t))

(use-package recentf
  :ensure nil
  :config
  (add-to-list 'recentf-exclude (format "%selpa.*" emacs-dir))
  :custom
  (recentf-save-file (concat cache-dir "recentf")))

(use-package all-the-icons
  :commands (all-the-icons-faicon))

(use-package doom-themes
  :demand t
  :custom
  (doom-themes-enable-bold t)
  (doom-themes-enable-italic t)
  :config
  (load-theme 'doom-one t)
  (doom-themes-org-config))

(use-package dashboard
  :demand
  :if (< (length command-line-args) 2)
  :bind (:map dashboard-mode-map
              ("U" . auto-package-update-now)
              ("R" . restart-emacs)
              ("K" . kill-emacs))
  :custom
  (dashboard-startup-banner 'logo)
  (dashboard-banner-logo-title "The One True Editor, Emacs")
  (dashboard-set-heading-icons t)
  (dashboard-set-file-icons t)
  (dashboard-set-init-info nil)
  (dashboard-set-navigator t)
  (dashboard-navigator-buttons
   `(
     ((,(and (display-graphic-p)
             (all-the-icons-faicon "gitlab" :height 1.2 :v-adjust -0.1))
       "Homepage"
       "Browse Homepage"
       (lambda (&rest _) (browse-url homepage)))
      (,(and (display-graphic-p)
             (all-the-icons-material "update" :height 1.2 :v-adjust -0.24))
       "Update"
       "Update emacs"
       (lambda (&rest _) (auto-package-update-now)))
      (,(and (display-graphic-p)
             (all-the-icons-material "autorenew" :height 1.2 :v-adjust -0.15))
       "Restart"
       "Restar emacs"
       (lambda (&rest _) (restart-emacs))))))
  (dashboard-set-footer t)
  (dashboard-footer (format "Powered by JesusMtnez, %s" (format-time-string "%Y")))
  (dashboard-footer-icon (cond ((display-graphic-p)
                                (all-the-icons-faicon "code" :height 1.5 :v-adjust -0.1 :face 'error))
                               (t (propertize ">" 'face 'font-lock-doc-face))))
  :config
  (defun dashboard-load-packages (list-size)
    (insert (make-string (ceiling (max 0 (- dashboard-banner-length 38)) 2) ? )
            (format "[%d packages loaded in %s]" (length package-activated-list) (emacs-init-time))))

  (add-to-list 'dashboard-item-generators '(packages . dashboard-load-packages))

  (setq dashboard-items '((packages)
                          (projects . 10)
                          (recents . 10)))
  (dashboard-setup-startup-hook))

(use-package scroll-bar
  :ensure nil
  :config (scroll-bar-mode -1))

(use-package menu-bar
  :ensure nil
  :bind ("C-x C-k" . kill-this-buffer)
  :config (menu-bar-mode -1))

(use-package tool-bar
  :ensure nil
  :config (tool-bar-mode -1))

(use-package whitespace
  :diminish global-whitespace-mode
  :hook (after-init . global-whitespace-mode)
  :custom
  (whitespace-style '(face tabs trailing)))

(use-package rainbow-mode)

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package display-line-numbers
  :hook ((prog-mode text-mode) . display-line-numbers-mode))

(use-package zoom-window
  :bind (("C-x C-z" . zoom-window-zoom))
  :custom
  (zoom-window-mode-line-color "DarkRed" "Modeline color when enabled"))

(use-package ace-window
  :bind (("M-o" . ace-window))
  :custom
  (aw-dispatch-always t "Issue read-char even for one window")
  (ace-window-display-mode t)
  :config
  (push " *NeoTree*" aw-ignored-buffers)
  (push "*which-key*" aw-ignored-buffers))

(use-package faces
  :ensure nil
  :config
  (when (member "PragmataPro Mono Liga" (font-family-list))
    (set-face-attribute 'default nil :font "PragmataPro Mono Liga 14"))
  (when (member "Hack" (font-family-list))
    (set-face-attribute 'default nil :font "Hack 9"))
  (when (member "FontAwesome" (font-family-list))
    (set-fontset-font t 'unicode "FontAwesome" nil 'prepend)))

(use-package projectile
  :config
  (projectile-global-mode)
  (setq projectile-mode-line
        '(:eval (format " [%s]" (projectile-project-name))))
  (setq projectile-remember-window-configs t)
  (setq projectile-completion-system 'ivy))

(use-package ivy
  :diminish ivy-mode
  :bind (("C-x C-b" . ivy-switch-buffer))
  :config
  (setq ivy-use-virtual-buffers t
        ivy-count-format "%d/%d "
        ivy-re-builders-alist '((swiper . ivy--regex-plus))))

(use-package flx)

(use-package counsel
  :bind (("M-x"     . counsel-M-x)
         ([f9]      . counsel-load-theme))
  :config
  (setq ivy-initial-inputs-alist nil))

(use-package counsel-projectile
  :bind (("C-c a g" . counsel-ag)
         ("C-x C-f" . counsel-find-file)
         ("C-c p h" . counsel-projectile)
         ("C-c p r" . projectile-replace)
         ("C-c p v" . projectile-vc)
         ("C-c p p" . counsel-projectile-switch-project)))

(use-package swiper
  :bind (("C-s" . swiper)
         ("M-l" . swiper-avy)))

(use-package ivy-posframe
  :after ivy
  :config
  (setq ivy-posframe-display-functions-alist '((t . ivy-posframe-display-at-frame-center)))
  (setq ivy-posframe-parameters '((left-fringe . 15)
                                  (right-fringe . 15)
                                  (top-fringe . 15)
                                  (bottom-fringe . 15)))
  (ivy-posframe-mode 1))

(use-package char-menu
  :ensure t
  :bind ("M-p" . char-menu)
  :custom
  (char-menu '("—" "‘’" "“”" "…" "«»" "–"
               ("Typography" "•" "©" "†" "‡" "°" "·" "§" "№" "★")
               ("Mathematical Operators"
                "∀" "∁" "∂" "∃" "∄" "∅" "∆" "∇" "∈" "∉" "∊" "∋" "∌" "∍" "∎" "∏"
                "∐" "∑" "−" "∓" "∔" "∕" "∖" "∗" "∘" "∙" "√" "∛" "∜" "∝" "∞" "∟"
                "∠" "∡" "∢" "∣" "∤" "∥" "∦" "∧" "∨" "∩" "∪" "∫" "∬" "∭" "∮" "∯"
                "∰" "∱" "∲" "∳" "∴" "∵" "∶" "∷" "∸" "∹" "∺" "∻" "∼" "∽" "∾" "∿"
                "≀" "≁" "≂" "≃" "≄" "≅" "≆" "≇" "≈" "≉" "≊" "≋" "≌" "≍" "≎" "≏"
                "≐" "≑" "≒" "≓" "≔" "≕" "≖" "≗" "≘" "≙" "≚" "≛" "≜" "≝" "≞" "≟"
                "≠" "≡" "≢" "≣" "≤" "≥" "≦" "≧" "≨" "≩" "≪" "≫" "≬" "≭" "≮" "≯"
                "≰" "≱" "≲" "≳" "≴" "≵" "≶" "≷" "≸" "≹" "≺" "≻" "≼" "≽" "≾" "≿"
                "⊀" "⊁" "⊂" "⊃" "⊄" "⊅" "⊆" "⊇" "⊈" "⊉" "⊊" "⊋" "⊌" "⊍" "⊎" "⊏"
                "⊐" "⊑" "⊒" "⊓" "⊔" "⊕" "⊖" "⊗" "⊘" "⊙" "⊚" "⊛" "⊜" "⊝" "⊞" "⊟"
                "⊠" "⊡" "⊢" "⊣" "⊤" "⊥" "⊦" "⊧" "⊨" "⊩" "⊪" "⊫" "⊬" "⊭" "⊮" "⊯"
                "⊰" "⊱" "⊲" "⊳" "⊴" "⊵" "⊶" "⊷" "⊸" "⊹" "⊺" "⊻" "⊼" "⊽" "⊾" "⊿"
                "⋀" "⋁" "⋂" "⋃" "⋄" "⋅" "⋆" "⋇" "⋈" "⋉" "⋊" "⋋" "⋌" "⋍" "⋎" "⋏"
                "⋐" "⋑" "⋒" "⋓" "⋔" "⋕" "⋖" "⋗" "⋘" "⋙" "⋚" "⋛" "⋜" "⋝" "⋞" "⋟"
                "⋠" "⋡" "⋢" "⋣" "⋤" "⋥" "⋦" "⋧" "⋨" "⋩" "⋪" "⋫" "⋬" "⋭" "⋮" "⋯"
                "⋰" "⋱" "⋲" "⋳" "⋴" "⋵" "⋶" "⋷" "⋸" "⋹" "⋺" "⋻" "⋼" "⋽" "⋾" "⋿")
               ("Superscripts & Subscripts"
                "⁰" "ⁱ"   "⁴" "⁵" "⁶" "⁷" "⁸" "⁹" "⁺" "⁻" "⁼" "⁽" "⁾" "ⁿ"
                "₀" "₁" "₂" "₃" "₄" "₅" "₆" "₇" "₈" "₉" "₊" "₋" "₌" "₍₎"
                "ₐ" "ₑ" "ₒ" "ₓ" "ₔ" "ₕ" "ₖ" "ₗ" "ₘ" "ₙ" "ₚ" "ₛ" "ₜ")
               ("Arrows"     "←" "→" "↑" "↓" "⇐" "⇒" "⇑" "⇓")
               ("Greek"      "α" "β" "Y" "δ" "ε" "ζ" "η" "θ" "ι" "κ" "λ" "μ"
                "ν" "ξ" "ο" "π" "ρ" "σ" "τ" "υ" "φ" "χ" "ψ" "ω")
               ("Enclosed Alphanumerics"
                "①" "②" "③" "④" "⑤" "⑥" "⑦" "⑧" "⑨" "Ⓐ" "Ⓑ" "Ⓒ" "Ⓓ" "Ⓔ" "Ⓕ" "Ⓖ"
                "Ⓗ" "Ⓘ" "Ⓙ" "Ⓚ" "Ⓛ" "Ⓜ" "Ⓝ" "Ⓞ" "Ⓟ" "Ⓠ" "Ⓡ" "Ⓢ" "Ⓣ" "Ⓤ" "Ⓥ" "Ⓦ"
                "Ⓧ" "Ⓨ" "Ⓩ" "ⓐ" "ⓑ" "ⓒ" "ⓓ" "ⓔ" "ⓕ" "ⓖ" "ⓗ" "ⓘ" "ⓙ" "ⓚ" "ⓛ" "ⓜ"
                "ⓝ" "ⓞ" "ⓟ" "ⓠ" "ⓡ" "ⓢ" "ⓣ" "ⓤ" "ⓥ" "ⓦ" "ⓧ" "ⓨ" "ⓩ" "⓪")
               ("Annotations"
                "      " "      " "     " "     " "        " "    " "      " "      "
                "      " "     " "    " "     " "     " "     "))))

(use-package exec-path-from-shell
  :ensure t
  :if (memq window-system '(mac ns x))
  :config
  (setq exec-path-from-shell-variables '("PATH" "GOPATH" "LC_COLLATE" "LC_MESSAGES" "LC_MONETARY" "LC_NUMERIC" "LC_TIME"))
  (exec-path-from-shell-initialize))

(use-package expand-region
  :ensure t
  :bind (("C-@" . er/expand-region)))

(use-package multiple-cursors
  :ensure t
  :bind (("C->" . mc/mark-next-like-this)
         ("C-<" . mc/mark-previous-like-this)
         ("C-c C-<" . mc/mark-all-like-this)))

(use-package forge
  :straight t)
