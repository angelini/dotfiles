;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Package Manager

(require 'package)
(package-initialize)

(add-to-list 'package-archives
             '("melpa" . "http://melpa.milkbox.net/packages/"))
(add-to-list 'package-archives
             '("marmalade" . "http://marmalade-repo.org/packages/") t)

(defun filter (condp lst)
  (delq nil
        (mapcar (lambda (x) (and (funcall condp x) x)) lst)))

(defun not-installed-p (p)
  (not (package-installed-p p)))

(setq package-list
      '(ag
        magit
        multi-term
        projectile
        flx-ido
        clojure-mode
        cider
        coffee-mode
        inf-ruby
        jedi
        virtualenvwrapper
        pytest
        color-theme-solarized))

(setq to-install (filter 'not-installed-p package-list))

(when to-install
  (package-refresh-contents)
  (mapc 'package-install to-install))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Default configs

;; Have PATH use .zshrc
(defun set-exec-path-from-shell-PATH ()
  (let ((path-from-shell (shell-command-to-string "TERM=xterm-256color $SHELL -i -c 'echo $PATH'")))
    (setenv "PATH" path-from-shell)
    (setq exec-path (split-string path-from-shell path-separator))))

(when window-system (set-exec-path-from-shell-PATH))

;; Increase GC threshold
(setq gc-cons-threshold 20000000)

;; Color theme
(load-theme 'solarized-light t)

;; Meta and alt keys
(setq mac-command-modifier 'meta)
(setq mac-option-modifier 'super)

;; Copy & paste
(global-set-key (kbd "M-c") 'clipboard-kill-ring-save)
(global-set-key (kbd "M-w") 'clipboard-kill-region)
(global-set-key (kbd "M-v") 'clipboard-yank)

;; Projectile
(projectile-global-mode)

;; Splash screen
(setq inhibit-splash-screen t)

;; Magit
(global-set-key (kbd "C-c m") 'magit-status)

;; Symlinks
(setq vc-follow-symlinks t)

;; Default mode
(setq default-major-mode 'text-mode)

;; Indentation settings
(setq standard-indent 2)
(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)
(setq-default tab-stop-list (number-sequence 4 120 4))
(define-key global-map (kbd "RET") 'newline-and-indent)

;; Buffer names
(require 'uniquify)
(setq uniquify-buffer-name-style 'forward)

;; Backup files
(setq make-backup-files nil)
(setq auto-save-default nil)

;; Turn off bell
(setq ring-bell-function 'ignore)

;; IDO mode
(require 'flx-ido)
(ido-mode 1)
(ido-everywhere 1)
(flx-ido-mode 1)
(setq ido-enable-flex-matching t)
(setq ido-use-faces nil)

;; Window move
(windmove-default-keybindings 'shift)

;; Paren mode
(show-paren-mode t)

;; Hide toolbar
(tool-bar-mode -1)

;; Multi-term
(require 'multi-term)
(setq multi-term-program "/bin/bash")

;; Line wrapping
(set-default 'truncate-lines t)

;; Prompts
(fset 'yes-or-no-p 'y-or-n-p)
(setq confirm-nonexistent-file-or-buffer nil)
(setq ido-create-new-buffer 'always)

;; Remove trailing whitespace
(add-hook 'before-save-hook 'delete-trailing-whitespace)

;; Default folder
(cd "~/src/starscream")

;; Disable scroll bars
(scroll-bar-mode -1)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Ruby

;; Add other file types as ruby files
(add-to-list 'auto-mode-alist '("\\.rake\\'" . ruby-mode))
(add-to-list 'auto-mode-alist '("Rakefile\\'" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.gemspec\\'" . ruby-mode))
(add-to-list 'auto-mode-alist '("Gemfile\\'" . ruby-mode))
(add-to-list 'auto-mode-alist '("Vagrantfile\\'" . ruby-mode))

;; Buffer local
(eval-after-load 'ruby-mode
  '(progn
     (subword-mode +1)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; CoffeeScript

;; Buffer local
(eval-after-load 'coffee-mode
  '(progn
     (subword-mode +1)
     (setq coffee-tab-width 2)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Python

;; Virtualenv
(require 'virtualenvwrapper)
(venv-initialize-interactive-shells)
(venv-initialize-eshell)
(setq venv-location "~/.virtualenvs/")
(venv-workon "sc")

;; Venv eshell-prompt
(setq eshell-prompt-function
      (lambda ()
        (concat "(" venv-current-name ") "
                ((lambda (d-list)
                   (concat
                    (mapconcat (lambda (d) (if (string= "" d) "" (substring d 0 1)))
                               (butlast d-list)
                               "/")
                    "/"
                    (car (last d-list))))
                 (split-string (eshell/pwd) "/"))
                " $ ")))

;; Venv mode line
(setq-default mode-line-format
              (cons '(:exec venv-current-name) mode-line-format))

;; Buffer local
(eval-after-load 'python-mode
  '(progn
     (hc-highlight-trailing-whitespace t)
     (setq python-indent-offset 4)
     (setq python-indent 4)
     (subword-mode +1)))

;; IPython
(setq python-shell-interpreter "ipython"
      python-shell-interpreter-args ""
      python-shell-prompt-regexp "In \\[[0-9]+\\]: "
      python-shell-prompt-output-regexp "Out\\[[0-9]+\\]: "
      python-shell-completion-setup-code "from IPython.core.completerlib import module_completion"
      python-shell-completion-module-string-code "';'.join(module_completion('''%s'''))\n"
      python-shell-completion-string-code "';'.join(get_ipython().Completer.all_completions('''%s'''))\n")

;; Jedi
(add-hook 'python-mode-hook 'jedi:setup)
(setq jedi:complete-on-dot t)
(setq jedi:get-in-function-call-delay 10000)

;; py.test
(require 'pytest)
(setq pytest-global-name "py.test")
(add-hook 'python-mode-hook
          (lambda ()
            (local-set-key (kbd "C-c m") 'pytest-module)
            (local-set-key (kbd "C-c .") 'pytest-one)))
