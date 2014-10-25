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
        color-theme-solarized))

(mapc 'install-if-needed to-install)

;; Have PATH use .zshrc
(defun set-exec-path-from-shell-PATH ()
  (let ((path-from-shell (shell-command-to-string "TERM=vt100 $SHELL -i -c 'echo $PATH'")))
    (setenv "PATH" path-from-shell)
    (setq exec-path (split-string path-from-shell path-separator))))

(when window-system (set-exec-path-from-shell-PATH))

;; Color theme
(load-theme 'solarized-light t)

;; Indentation settings
(setq standard-indent 2)
(setq-default indent-tabs-mode nil)
(define-key global-map (kbd "RET") 'newline-and-indent)

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
