(global-set-key [remap keyboard-quit] #'doom/escape)

;; ACTUAL START
(setq inhibit-startup-message t)

(scroll-bar-mode -1) ; Disable scroll bar
(tool-bar-mode -1) ; Disable tool bar
(tooltip-mode -1) ; Disable tool tips
(set-fringe-mode -1) ; Give some breathing room

;; (menu-bar-mode -1) ; Disable menu bar

;; Vim like scroll
(setq scroll-step 1)
(setq scroll-margin 0)

;; Font
(set-face-attribute 'default nil :font "MartianMono Nerd Font" :height 200)

(load-theme 'tango-dark)

;; Make ESC quit prompts
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

;; Initialize package sources
(require 'package)

(setq package-archives '(("melpa". "https://melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;; Initialize use-package on non-Linux platforms
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

(column-number-mode)
(global-display-line-numbers-mode t)

;; Disable for some modes
(dolist (mode '(org-mode-hook term-mode-hook eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

(use-package ivy
  :diminish
  :bind (("C-s" . swiper)
         :map ivy-minibuffer-map
         ("TAB" . ivy-alt-done)
         ("C-l" . ivy-alt-done)
         ("C-j" . ivy-next-line)
         ("C-k" . ivy-previous-line)
         :map ivy-switch-buffer-map
         ("C-k" . ivy-previous-line)
         ("C-l" . ivy-done)
         ("C-d" . ivy-switch-buffer-kill)
         :map ivy-reverse-i-search-map
         ("C-k" . ivy-previous-line)
         ("C-d" . ivy-reverse-i-search-kill))
  :config
  (ivy-mode 1))

(ivy-mode 1)

(use-package counsel
  :after (ivy)
  :bind (("M-x" . counsel-M-x)
         ("C-x b" . counsel-ibuffer)
         ("C-x f" . counsel-find-file))
  :config
  (setq ivy-initial-inputs-alist nil))

(use-package swiper
  :after (ivy))

(counsel-mode)

(use-package nerd-icons)

(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :custom ((doom-modeline-height 65)))

(use-package doom-themes
  :config
  ;; Global settings (defaults)
  (setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
        doom-themes-enable-italic t) ; if nil, italics is universally disabled
  (load-theme 'doom-one t)

  ;; Enable flashing mode-line on errors
  (doom-themes-visual-bell-config)
  ;; Enable custom neotree theme (all-the-icons must be installed!)
  (doom-themes-neotree-config)
  ;; or for treemacs users
  (setq doom-themes-treemacs-theme "doom-atom") ; use "doom-colors" for less minimal icon theme
  (doom-themes-treemacs-config)
  ;; Corrects (and improves) org-mode's native fontification.
  (doom-themes-org-config))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 0.3))

(use-package ivy-rich
  :init
  (ivy-rich-mode 1))

(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-C-i-jump nil)
  :config
  (evil-mode 1)

  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal))
(evil-select-search-module 'evil-search-module 'evil-search)
(unless noninteractive
  (setq save-silently t)
  (add-hook 'after-save-hook
            (defun +evil-display-vimlike-save-message-h ()
              "Shorter, vim-esque save messages."
              (message "\"%s\" %dL, %dC written"
                       (if buffer-file-name
                           (file-relative-name (file-truename buffer-file-name))
                         (buffer-name))
                       (count-lines (point-min) (point-max))
                       (buffer-size)))))
(defun custom-evil-force-normal-state ()
  "Delegate to evil-force-normal-state but also clear search highlighting"
  (interactive)
  (evil-force-normal-state)
  (when (evil-ex-hl-active-p 'evil-ex-search)
    (evil-ex-nohighlight)))

(define-key evil-normal-state-map (kbd "<escape>") 'custom-evil-force-normal-state)

(use-package evil-nerd-commenter)

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(use-package helpful
  :custom
  (counsel-describe-function-function #'helpful-callable)
  (counsel-describe-variable-function #'helpful-variable)
  :bind
  ([remap describe-function] . counsel-describe-function)
  ([remap describe-command] . helpful-command)
  ([remap describe-variable] . counsel-describe-variable)
  ([remap describe-key] . helpful-key))


(use-package general)
(require 'general)
(general-create-definer my/leader-keys
  :keymaps '(normal insert visual emacs)
  :prefix "SPC"
  :non-normal-prefix "M-SPC")

;; Global bindings
(require 'evil-nerd-commenter)
(my/leader-keys
 "fz" '(swiper :which-key "Search in buffer")
 "/" '(evilnc-comment-or-uncomment-lines :which-key "Comment/Uncomment")
 "ffg" '(counsel-find-file :which-key "Find file globally")
 ":" '(counsel-M-x :which-key "M-x")
 "fb" '(counsel-switch-buffer :which-key "Switch buffer")
 "," '(counsel-projectile-switch-to-buffer :which-key "Switch buffer")
 "." '(counsel-projectile-find-file :which-key "Find file in project")
 "bk" '(kill-current-buffer :which-key "Kill buffer")
 "bn" '(next-buffer :which-key "Next buffer")
 "bp" '(previous-buffer :which-key "Previous buffer"))

(use-package projectile
  :diminish projectile-mode
  :config (projectile-mode)
  :custom ((projectile-completion-system 'ivy))
  :bind-keymap
  ("C-c p" . projectile-command-map))
;;:init
;; NOTE: Set this to the folder where you keep your Git repos!
;;(when (file-directory-p "~/Projects/Code")
;; (setq projectile-project-search-path '("~/Projects/Code")))
;; (setq projectile-switch-project-action #'projectile-dired))
(define-key evil-normal-state-map (kbd "SPC p") 'projectile-command-map)

(use-package counsel-projectile
  :config (counsel-projectile-mode))

(use-package magit)

;; NOTE: Make sure to configure a GitHub token before using this package!
;; - https://magit.vc/manual/forge/Token-Creation.html#Token-Creation
;; - https://magit.vc/manual/ghub/Getting-Started.html#Getting-Started
(use-package forge)

(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :init
  (setq lsp-keymap-prefix "SPC l")
  :config
  (lsp-enable-which-key-integration t))

(use-package lsp-pyright
  :hook (python-mode . (lambda ()
                         (require 'lsp-pyright)
                         (lsp-deferred))))  ; or lsp-deferred


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(counsel-projectile general evil-commentary doom-modeline counsel)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
