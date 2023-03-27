
(defun cxy/get-latex-content ()
  "get the content between \begin{document} ... \end{document}.
This process has 2 functions:
(1) save the latex content to a .txt file.
(2) return the latex content as a STRING."
  (save-excursion
    (goto-char (point-min))
    (re-search-forward "\\\\begin{document}")
    (let ((start-point (+ (point) 1)))
      (goto-char (point-max))
      (re-search-backward "\\\\end{document}")
      (let ((end-point (- (point) 1)))
        (write-region start-point end-point (format "%s.txt" (file-name-base)))
        (buffer-substring-no-properties start-point end-point)))))

(defun cxy/pdf-to-clipboard ()
  "set the clipboard of macOS to the 'pdf ouput' of the current buffer"
  (shell-command (format "gs -q -dNOPAUSE -dTextAlphaBits=4 -dGraphicsAlphaBits=4 -sCompression=lzw -sDEVICE=tiffscaled24 -sOutputFile=%s.tiff %s.pdf -c quit && osascript ~/.emacs.d/macOS/applescripts/tiff2clipboard.scpt %s.tiff" (file-name-base) (file-name-base) (file-name-base))))

(defun cxy/new-skim-anchor-note (title)
  "make a new anchor note in skim
@para STRING title, the title of the note

(1) The user of this function should first input the title for the note.
(2) Then, they need to make sure that \\begin{document} and \\end{document}
    exist in the current buffer.
(2) Also, they need to make sure that the pdf output of the current buffer
    exists (should have the same name, i.e. XXX.tex <=> XXX.pdf).
(3) Finally, they need to make sure that the document where they want to add
    the note is the frontmost document of Skim.

If any of the conditions mentioned above is not satisfied, the result may be unexpected."
  (interactive
   (list (read-string "Title: " "" nil nil)))
  (cxy/pdf-to-clipboard)
  (cxy/get-latex-content)
  (shell-command (format "osascript ~/.emacs.d/macOS/applescripts/newSkimNote.scpt '%s' '%s'" title (format "%s.txt" (file-name-base)))))


;; set XeTeX mode in TeX/LaTeX
(add-hook 'LaTeX-mode-hook
          (lambda()
            (add-to-list 'TeX-command-list '("XeLaTeX" "%`xelatex --synctex=1%(mode)%' %t" TeX-run-TeX nil t))
            (add-to-list 'TeX-command-list '("ClipBoard" "(cxy/pdf-to-clipboard)" TeX-run-function nil t))
            (add-to-list 'TeX-command-list '("SkimAnchorNote" "(call-interactively 'cxy/new-skim-anchor-note)" TeX-run-function nil t))
            (add-to-list 'TeX-command-list '("LuaLaTeX" "%`lualatex --synctex=1%(mode)%' %t" TeX-run-TeX nil t))))

(add-hook 'TeX-after-compilation-finished-functions #'TeX-revert-document-buffer)

;;将AucTex的默认PDF阅读器设置为SKIM (以下代码来自于SKIM官网)

(setq TeX-PDF-mode t)

;; EMACS TO SKIM
;; The following only works with AUCTeX loaded
;(require 'tex-site)
;(add-hook 'TeX-mode-hook
;          (lambda ()
;            (add-to-list 'TeX-output-view-style
;                         '("^pdf$" "."
;                           "/Applications/Skim.app/Contents/SharedSupport/displayline %n %o %b")))
;          )

;; Use PDF mode by default
(setq-default TeX-PDF-mode t)
;; Make emacs aware of multi-file projects
(setq-default TeX-master nil)

(setq TeX-view-program-selection '((output-pdf "PDF Viewer")))
(setq TeX-view-program-list
      '(("PDF Viewer" "/Applications/Skim.app/Contents/SharedSupport/displayline -b -g %n %o %b")))

(custom-set-variables
 '(TeX-source-correlate-method 'synctex)
 '(TeX-source-correlate-mode t)
 '(TeX-source-correlate-start-server t))
(server-force-delete)

;; Auto-raise Emacs on activation
;;(defun raise-emacs-on-aqua()
;;  (shell-command "osascript -e 'tell application \"Emacs\" to activate' &"))
;;(add-hook 'server-switch-hook 'raise-emacs-on-aqua)

(provide 'init-auctex)
