;; Package manager
(require 'package)
(package-initialize)

(add-to-list 'package-archives
	     '("melpa" . "http://melpa.milkbox.net/packages/"))
(add-to-list 'package-archives
             '("marmalade" . "http://marmalade-repo.org/packages/") t)

(package-refresh-contents)

(defun install-if-needed (package)
  (unless (package-installed-p package)
    (package-install package)))

(setq to-install
      '(magit
        multi-term
        projectile
        clojure-mode
        cider
        coffee-mode
        inf-ruby
        virtualenvwrapper
        highlight-chars
        color-theme-solarized))

(mapc 'install-if-needed to-install)

;; Have PATH use .zshrc
(defun set-exec-path-from-shell-PATH ()
  (let ((path-from-shell (shell-command-to-string "TERM=xterm-256color $SHELL -i -c 'echo $PATH'")))
    (setenv "PATH" path-from-shell)
    (setq exec-path (split-string path-from-shell path-separator))))

(when window-system (set-exec-path-from-shell-PATH))

;; Color theme
(load-theme 'solarized-light t)

;; Splash screen
(setq inhibit-splash-screen t)

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

;; Highlight tabs and trailing whitespace
(require 'highlight-chars)
(add-hook 'font-lock-mode-hook 'hc-highlight-tabs)
;(add-hook 'font-lock-mode-hook 'hc-highlight-trailing-whitespace)

;; Buffer names
(require 'uniquify)
(setq uniquify-buffer-name-style 'forward)

;; Backup files
(setq make-backup-files t)
(setq backup-directory-alist (quote ((".*" . "~/.emacs_backups/"))))

;; Turn off bell
(setq ring-bell-function 'ignore)

;; IDO mode
(setq ido-enable-flex-matching t)
(setq ido-everywhere t)
(ido-mode 1)

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

;;; CoffeeScript

;; Buffer local
(eval-after-load 'coffee-mode
  '(progn
     (subword-mode +1)
     (setq coffee-tab-width 2)))

;;; Python

;; Virtualenv
(require 'virtualenvwrapper)
(venv-initialize-interactive-shells)
(venv-initialize-eshell)
(setq venv-location "~/.virtualenvs/")

;; Buffer local
(eval-after-load 'python-mode
  '(progn
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


;;; Clojure
