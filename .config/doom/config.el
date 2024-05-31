(setq doom-font (font-spec :family "Fira Code" :size 21 :weight 'medium)
doom-big-font (font-spec :family "Fira Code" :size 32)
doom-variable-pitch-font (font-spec :family "Fira Code" :size 18))
(setq doom-theme 'doom-one)

(setq doom-theme 'doom-one)

(setq display-line-numbers-type `relative)

(after! doom-modeline (setq doom-modeline-height 45))

(after! org
  (add-hook! 'org-mode-hook #'(lambda () (display-line-numbers-mode 0)))
  (setq org-ellipsis " ▾"))

(after! tree-sitter
  (global-tree-sitter-mode)
  (add-hook! 'tree-sitter-after-on-hook #'tree-sitter-hl-mode))

(after! lsp-mode
  (setq lsp-ui-peek-always-show t)
  (setq lsp-headerline-breadcrumb-enable t)
  (setq lsp-headerline-breadcrumb-icons-enable t)
  (setq lsp-inlay-hint-enable t))

(defvar-local my/flycheck-local-cache nil)

(defun my/flycheck-checker-get (fn checker property)
  (or (alist-get property (alist-get checker my/flycheck-local-cache))
      (funcall fn checker property)))

(after! syntax
  (advice-add 'flycheck-checker-get :around 'my/flycheck-checker-get)
  (add-hook 'lsp-managed-mode-hook
            (lambda ()
              (when (derived-mode-p 'python-mode)
                (setq my/flycheck-local-cache '((lsp . ((next-checkers . (python-ruff)))))))))
  (add-hook 'lsp-managed-mode-hook
            (lambda ()
              (when (derived-mode-p 'sh-mode)
                (setq my/flycheck-local-cache '((lsp . ((next-checkers . (sh-posix-bash))))))))))

(advice-add 'flycheck-checker-get :around 'my/flycheck-checker-get)

(after! format
  (require 'apheleia)
  (setf (alist-get 'ruff apheleia-formatters)
        '("ruff" "format" "--silent" "-"))
  (setf (alist-get 'ruff-isort apheleia-formatters)
        '("ruff" "check" "--fix" "--select" "I" "-"))
  (setf (alist-get 'python-mode apheleia-mode-alist)
        '(ruff ruff-isort))
  (setf (alist-get 'python-ts-mode apheleia-mode-alist)
        '(ruff ruff-isort)))
