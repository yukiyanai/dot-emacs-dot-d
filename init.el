;; ===================================
;; ~/.emacs.d/init.el
;; Emacs init file
;; Created on 2015-01-19 Yuki Yanai
;; Modified on 2015-01-27 YY
;;             2016-12-26 YY
;;             2016-12-27 YY
;;             2017-07-11 YY
;;             2018-04-23 YY
;;             2018-06-13 YY
;;             2018-12-10 YY
;; ===================================

(require 'cask "/usr/local/opt/cask/cask.el") ; for Mac
;; For Ubuntu
;(when (or (require 'cask "~/.cask/cask.el" t)
;          (require 'cask nil t))
;  (cask initialize))


;; load environment value
(load-file (expand-file-name "~/.emacs.d/shellenv.el"))
(dolist (path (reverse (split-string (getenv "PATH") ":")))
  (add-to-list 'exec-path path))

(load-theme 'wombat t)


;; ========================================
;; preference over character encoding
;; ========================================
(prefer-coding-system 'utf-8)
(setq default-file-name-coding-system 'utf-8)
(setq file-name-coding-system 'utf-8)
(setq buffer-file-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(setq coding-system-for-read 'utf-8)
(setq coding-system-for-write 'utf-8)
;(set-language-environment "utf-8") 
(set-language-environment "Japanese")
(set-locale-environment "utf-8")
(setenv "LANG" "en_US.UTF-8")




;; =========================
;; Global key settings
;; =========================
;; set C-h as Backspace
(global-set-key "\C-h" 'backward-delete-char-untabify)
;; move to next window, when no other window, open a new one and move
(defun other-window-or-split ()
  (interactive)
  (when (one-window-p) (split-window-horizontally))
  (other-window 1))
(global-set-key (kbd "C-t") 'other-window-or-split)


;; Editor Appearance
;; color the current line
(global-hl-line-mode t)
;; suppress the annoying tool bar
(tool-bar-mode 0)
;; suppress the scroll bar
(scroll-bar-mode 0)
;; turn on font-lock mode to color text in certain modes
(global-font-lock-mode t)
;; enables parenthesis matching
(show-paren-mode t)
;; flash the display in place of beep
(setq visible-bell t)
;; set tab width to 2 spaces
(setq-default tab-width 2)
;; make sure spaces are used when indenting code
(setq-default indent-tabs-mode nil)
;; display line and column numbers
(line-number-mode t)
(column-number-mode t)
;; parentheses matching
(show-paren-mode t)
;; enables word-count-mode
(autoload 'word-count-mode "word-count"
  "Minor mode to count words." t nil)
(global-set-key "\M-+" 'word-count-mode)
;; show time in the modeline
(display-time)
;; change GC for faster processing
(setq gc-cons-threshold (* 10 gc-cons-threshold))
;; increase the number of lines to be logged
(setq message-log-max 10000)
;; make it possible to call mini-buffers recursively
(setq enable-recursive-minibuffers t)
;; disable dialogue boxes
(setq use-dialog-box nil)
(defalias 'message-box 'message)
;; save more histories
(setq history-length 1000)
;; promptly display keystrokes in echo area
(setq echo-keystrokes 0.1)
;; Warn when try to open a large file
;; default size is 10MB: increase to 25MB
(setq large-file-warning-threshold (* 25 1024 1024))

;;==================================
;; handle buffers and files better
;;==================================
(ffap-bindings)
;; set buffer name in the form of finlename<dir>
(setq uniquify-buffer-name-style 'post-forward-angle-brackets)
;; exceptions are buffere surrounded by *
(setq uniquify-ignore-buffers-re "*[^*]+*")
(ido-mode 1)
(ido-everywhere 1)

;;==================================
;; recentf-ext.el
;;==================================
(setq recentf-max-saved-items 500)
;; files not to be saved in the history
(setq recentf-exlude '("/TAGS$" "/var/tmp/"))

;;=========================
;; flymake
;;=========================
(require 'tramp-cmds)
(when (load "flymake" t)
  (defun flymake-pyflakes-init ()
     ; Make sure it's not a remote buffer or flymake would not work
     (when (not (subsetp (list (current-buffer)) (tramp-list-remote-buffers)))
      (let* ((temp-file (flymake-init-create-temp-buffer-copy
                         'flymake-create-temp-inplace))
             (local-file (file-relative-name
                          temp-file
                          (file-name-directory buffer-file-name))))
        (list "pyflakes" (list local-file)))))
  (add-to-list 'flymake-allowed-file-name-masks
               '("\\.py\\'" flymake-pyflakes-init)))
(add-hook 'python-mode-hook
          (lambda ()
            (flymake-mode t)))


;============================
;; YaTeX setting
;;============================
(add-to-list 'load-path "~/.emacs.d/.cask/26.1/elpa/yatex-20180601.2357")
(autoload 'yatex-mode "yatex" "Yet Another LaTeX mode" t)

(setq auto-mode-alist
      (append '(("\\.tex$" . yatex-mode)
                ("\\.ltx$" . yatex-mode)
                ("\\.cls$" . yatex-mode)
                ("\\.sty$" . yatex-mode)
                ("\\.clo$" . yatex-mode)
                ("\\.bbl$" . yatex-mode)) auto-mode-alist))

(with-eval-after-load 'yatex
  (setq YaTeX-inhibit-prefix-letter t)
  (setq YaTeX-kanji-code nil)
  (setq YaTeX-use-LaTeX2e t)
  (setq YaTeX-use-AMS-LaTeX t)
  (setq YaTeX-dvi2-command-ext-alist
        '(("Preview\\|TeXShop\\|TeXworks\\|Skim\\|mupdf\\|xpdf\\|Firefox\\|Adobe" . ".pdf")))
  (setq tex-command "/Library/TeX/texbin/ptex2pdf -u -l -ot '-synctex=1'")
  (setq bibtex-command (cond ((string-match "uplatex\\|-u" tex-command) "/Library/TeX/texbin/upbibtex")
                             ((string-match "platex" tex-command) "/Library/TeX/texbin/pbibtex")
                             ((string-match "lualatex\\|luajitlatex\\|xelatex" tex-command) "/Library/TeX/texbin/bibtexu")
                             ((string-match "pdflatex\\|latex" tex-command) "/Library/TeX/texbin/bibtex")
                             (t "/Library/TeX/texbin/pbibtex")))
  (setq makeindex-command (cond ((string-match "uplatex\\|-u" tex-command) "/Library/TeX/texbin/mendex")
                                ((string-match "platex" tex-command) "/Library/TeX/texbin/mendex")
                                ((string-match "lualatex\\|luajitlatex\\|xelatex" tex-command) "/Library/TeX/texbin/texindy")
                                ((string-match "pdflatex\\|latex" tex-command) "/Library/TeX/texbin/makeindex")
                                (t "/Library/TeX/texbin/mendex")))
  ;; (setq dvi2-command "/usr/bin/open -a Preview")
  (setq dvi2-command "/usr/bin/open -a Skim")
  (setq dviprint-command-format "/usr/bin/open -a \"Adobe Acrobat\" `echo %s | sed -e \"s/\\.[^.]*$/\\.pdf/\"`")
  (auto-fill-mode -1)
  (reftex-mode 1))
(defvar YaTeX-dvi2-command-ext-alist
  '(("[agx]dvi\\|dviout\\|emacsclient" . ".dvi")
   ("ghostview\\|gv" . ".ps")
   ("acroread\\|pdf\\|Preview\\|TeXShop\\|Skim\\|evince\\|apvlv" . ".pdf")))



;=======================
;; python-mode
;;=======================
(setq auto-mode-alist (cons '("\\.py$" . python-mode) auto-mode-alist))
(setq interpreter-mode-alist (cons '("python" . python-mode)
                                   interpreter-mode-alist))
(autoload 'python-mode "python-mode" "Python editing mode." t)
(setq ipython-command "/Users/yuki/.pyenv/shims/ipython")
;(require 'ipython)

(add-hook 'python-mode-hook
          (lambda ()
            (define-key python-mode-map (kbd "\C-m") 'newline-and-indent)
            (define-key python-mode-map (kbd "RET") 'newline-and-indent)))


;; http://w.livedoor.jp/whiteflare503/d/Emacs%20%A5%A4%A5%F3%A5%C7%A5%F3%A5%C8
;;共通設定(?)
(setq-default c-basic-offset 4     ;;基本インデント量4
              tab-width 4          ;;タブ幅4
               indent-tabs-mode nil)  ;;インデントをタブでするかスペースでするか

;; C++ style
(defun add-c++-mode-conf ()
  (c-set-style "stroustrup")  ;;スタイルはストラウストラップ
  (show-paren-mode t))        ;;カッコを強調表示する
(add-hook 'c++-mode-hook 'add-c++-mode-conf)

;; C style
(defun add-c-mode-common-conf ()
  (c-set-style "stroustrup")                  ;;スタイルはストラウストラップ
  (show-paren-mode t)                         ;;カッコを強調表示する
  )
(add-hook 'c-mode-common-hook 'add-c-mode-common-conf)

;;=====================
;; markdown-mode
;;=====================
(autoload 'markdown-mode "markdown-mode"
  "Major mode for editing Markdown files" t)
(add-to-list 'auto-mode-alist '("\\.md" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.markdown" . markdown-mode))

;;===============================================
;; Emacs Speaks Statistics (ESS)  settings 
;;===============================================
(add-to-list 'load-path "~/.emacs.d/.cask/26.1/elpa/ess-20180524.1000")
;(require 'ess-site)
;(setq ess-askfor-ess-directory nil)
(setq ess-directory "~/")
(setq auto-mode-alist
    (cons (cons "\\.r$" 'R-mode) auto-mode-alist))
(autoload 'R-mode "ess-site" "Emacs Speaks Statistics mode" t)
(setq default-process-coding-system '(utf-8 . utf-8))
(autoload 'ess-rdired "ess-rdired" "View *R* objects in a dired-like buffer." t)
;(require 'ess-jags-d)

;; ==========
;; poly-mode
;; ==========
(defun rmd-mode ()
  "ESS Markdown mode for rmd files"
  (interactive)
  (require 'poly-R)
  (require 'poly-markdown)     
  (poly-markdown+r-mode))

;;; MARKDOWN
(add-to-list 'auto-mode-alist '("\\.md" . poly-markdown-mode))

;;; R modes
(add-to-list 'auto-mode-alist '("\\.Snw" . poly-noweb+r-mode))
(add-to-list 'auto-mode-alist '("\\.Rnw" . poly-noweb+r-mode))
(add-to-list 'auto-mode-alist '("\\.Rmd" . poly-markdown+r-mode))

;;=================
;; ispell -> aspell
;;=================
(setq-default ispell-program-name "aspell")
(eval-after-load "ispell"
  '(add-to-list 'ispell-skip-region-alist '("[^\000-\377]+")))
(setq-default ispell-program-name "/usr/local/bin/aspell")
;; run spell chaeck when closing the file in YaTeX mode
(defun ispell-before-save-if-needed ()
  (when (memq major-mode
              '(yatex-mode)) 
    (ispell)))
(add-hook 'before-save-hook 'ispell-before-save-if-needed)
;; use flyspell-mode only in YaTeX mode
(mapc
 (lambda (hook)(add-hook hook '(lambda () (flyspell-mode 1))))
 '(yatex-mode-hook))

(defun set-exec-path-from-shell-PATH ()
  "Set up Emacs' `exec-path' and PATH environment variable to match that used by the user's shell.
This is particularly useful under Mac OSX, where GUI apps are not started from a shell."
  (interactive)
  (let ((path-from-shell (replace-regexp-in-string "[ \t\n]*$" "" (shell-command-to-string "$SHELL --login -i -c 'echo $PATH'"))))
    (setenv "PATH" path-from-shell)
    (setq exec-path (split-string path-from-shell path-separator))))

(set-exec-path-from-shell-PATH)

;; FONT SETTINGS
(set-face-attribute 'default nil :family "Menlo" :height 140)
(set-fontset-font (frame-parameter nil 'font)
                  'japanese-jisx0208
                  (font-spec :family "Hiragino Kaku Gothic ProN"))
(add-to-list 'face-font-rescale-alist
             '(".*Hiragino Kaku Gothic ProN.*" . 1.2))

;; use command keys as meta keys 
(setq ns-command-modifier (quote meta))
;; use option keys as super keys
(setq ns-alternate-modifier (quote super))


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages (quote (package-build shut-up epl git commander f dash s))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
