;;; org-compat.el --- Compatibility Code for Older Emacsen -*- lexical-binding: t; -*-

;; Copyright (C) 2004-2019 Free Software Foundation, Inc.

;; Author: Carsten Dominik <carsten at orgmode dot org>
;; Keywords: outlines, hypermedia, calendar, wp
;; Homepage: https://orgmode.org
;;
;; This file is part of GNU Emacs.
;;
;; GNU Emacs is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <https://www.gnu.org/licenses/>.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;; Commentary:

;; This file contains code needed for compatibility with older
;; versions of GNU Emacs and integration with other packages.

;;; Code:

(require 'cl-lib)
(require 'org-macs)

(declare-function org-agenda-diary-entry "org-agenda")
(declare-function org-agenda-maybe-redo "org-agenda" ())
(declare-function org-agenda-remove-restriction-lock "org-agenda" (&optional noupdate))
(declare-function org-align-tags "org" (&optional all))
(declare-function org-at-heading-p "org" (&optional ignored))
(declare-function org-at-table.el-p "org" ())
(declare-function org-element-at-point "org-element" ())
(declare-function org-element-context "org-element" (&optional element))
(declare-function org-element-lineage "org-element" (blob &optional types with-self))
(declare-function org-element-type "org-element" (element))
(declare-function org-element-property "org-element" (property element))
(declare-function org-end-of-subtree "org" (&optional invisible-ok to-heading))
(declare-function org-get-heading "org" (&optional no-tags no-todo no-priority no-comment))
(declare-function org-get-tags "org" (&optional pos local))
(declare-function org-link-display-format "org" (s))
(declare-function org-link-set-parameters "org" (type &rest rest))
(declare-function org-log-into-drawer "org" ())
(declare-function org-make-tag-string "org" (tags))
(declare-function org-reduced-level "org" (l))
(declare-function org-show-context "org" (&optional key))
(declare-function org-table-end "org-table" (&optional table-type))
(declare-function outline-next-heading "outline" ())
(declare-function speedbar-line-directory "speedbar" (&optional depth))
(declare-function table--at-cell-p "table" (position &optional object at-column))

(defvar calendar-mode-map)
(defvar org-complex-heading-regexp)
(defvar org-agenda-diary-file)
(defvar org-agenda-overriding-restriction)
(defvar org-agenda-restriction-lock-overlay)
(defvar org-table-any-border-regexp)
(defvar org-table-dataline-regexp)
(defvar org-table-tab-recognizes-table.el)
(defvar org-table1-hline-regexp)


;;; Emacs < 27.1 compatibility

(unless (fboundp 'pcomplete-uniquify-list)
  ;; The misspelled variant was made obsolete in Emacs 27.1
  (defalias 'pcomplete-uniquify-list 'pcomplete-uniqify-list))


;;; Emacs < 26.1 compatibility

(if (fboundp 'line-number-display-width)
    (defalias 'org-line-number-display-width 'line-number-display-width)
  (defun org-line-number-display-width (&rest _) 0))


;;; Emacs < 25.1 compatibility

(when (< emacs-major-version 25)
  (defalias 'outline-hide-entry 'hide-entry)
  (defalias 'outline-hide-sublevels 'hide-sublevels)
  (defalias 'outline-hide-subtree 'hide-subtree)
  (defalias 'outline-show-branches 'show-branches)
  (defalias 'outline-show-children 'show-children)
  (defalias 'outline-show-entry 'show-entry)
  (defalias 'outline-show-subtree 'show-subtree)
  (defalias 'xref-find-definitions 'find-tag)
  (defalias 'format-message 'format)
  (defalias 'gui-get-selection 'x-get-selection))

(unless (fboundp 'directory-name-p)
  (defun directory-name-p (name)
    "Return non-nil if NAME ends with a directory separator character."
    (let ((len (length name))
	  (lastc ?.))
      (if (> len 0)
	  (setq lastc (aref name (1- len))))
      (or (= lastc ?/)
	  (and (memq system-type '(windows-nt ms-dos))
	       (= lastc ?\\))))))

;; `string-collate-lessp' is new in Emacs 25.
(if (fboundp 'string-collate-lessp)
    (defalias 'org-string-collate-lessp
      'string-collate-lessp)
  (defun org-string-collate-lessp (s1 s2 &rest _)
    "Return non-nil if STRING1 is less than STRING2 in lexicographic order.
Case is significant."
    (string< s1 s2)))


;;; Obsolete aliases (remove them after the next major release).

;;;; XEmacs compatibility, now removed.
(define-obsolete-function-alias 'org-activate-mark 'activate-mark "Org 9.0")
(define-obsolete-function-alias 'org-add-hook 'add-hook "Org 9.0")
(define-obsolete-function-alias 'org-bound-and-true-p 'bound-and-true-p "Org 9.0")
(define-obsolete-function-alias 'org-decompose-region 'decompose-region "Org 9.0")
(define-obsolete-function-alias 'org-defvaralias 'defvaralias "Org 9.0")
(define-obsolete-function-alias 'org-detach-overlay 'delete-overlay "Org 9.0")
(define-obsolete-function-alias 'org-file-equal-p 'file-equal-p "Org 9.0")
(define-obsolete-function-alias 'org-float-time 'float-time "Org 9.0")
(define-obsolete-function-alias 'org-indent-line-to 'indent-line-to "Org 9.0")
(define-obsolete-function-alias 'org-indent-to-column 'indent-to-column "Org 9.0")
(define-obsolete-function-alias 'org-looking-at-p 'looking-at-p "Org 9.0")
(define-obsolete-function-alias 'org-looking-back 'looking-back "Org 9.0")
(define-obsolete-function-alias 'org-match-string-no-properties 'match-string-no-properties "Org 9.0")
(define-obsolete-function-alias 'org-propertize 'propertize "Org 9.0")
(define-obsolete-function-alias 'org-select-frame-set-input-focus 'select-frame-set-input-focus "Org 9.0")
(define-obsolete-function-alias 'org-file-remote-p 'file-remote-p "Org 9.2")

(defmacro org-re (s)
  "Replace posix classes in regular expression S."
  (declare (debug (form))
           (obsolete "you can safely remove it." "Org 9.0"))
  s)

;;;; Functions from cl-lib that Org used to have its own implementation of.
(define-obsolete-function-alias 'org-count 'cl-count "Org 9.0")
(define-obsolete-function-alias 'org-every 'cl-every "Org 9.0")
(define-obsolete-function-alias 'org-find-if 'cl-find-if "Org 9.0")
(define-obsolete-function-alias 'org-reduce 'cl-reduce "Org 9.0")
(define-obsolete-function-alias 'org-remove-if 'cl-remove-if "Org 9.0")
(define-obsolete-function-alias 'org-remove-if-not 'cl-remove-if-not "Org 9.0")
(define-obsolete-function-alias 'org-some 'cl-some "Org 9.0")
(define-obsolete-function-alias 'org-floor* 'cl-floor "Org 9.0")

(defun org-sublist (list start end)
  "Return a section of LIST, from START to END.
Counting starts at 1."
  (cl-subseq list (1- start) end))
(make-obsolete 'org-sublist
               "use cl-subseq (note the 0-based counting)."
               "Org 9.0")


;;;; Functions available since Emacs 24.3
(define-obsolete-function-alias 'org-buffer-narrowed-p 'buffer-narrowed-p "Org 9.0")
(define-obsolete-function-alias 'org-called-interactively-p 'called-interactively-p "Org 9.0")
(define-obsolete-function-alias 'org-char-to-string 'char-to-string "Org 9.0")
(define-obsolete-function-alias 'org-delete-directory 'delete-directory "Org 9.0")
(define-obsolete-function-alias 'org-format-seconds 'format-seconds "Org 9.0")
(define-obsolete-function-alias 'org-link-escape-browser 'url-encode-url "Org 9.0")
(define-obsolete-function-alias 'org-no-warnings 'with-no-warnings "Org 9.0")
(define-obsolete-function-alias 'org-number-sequence 'number-sequence "Org 9.0")
(define-obsolete-function-alias 'org-pop-to-buffer-same-window 'pop-to-buffer-same-window "Org 9.0")
(define-obsolete-function-alias 'org-string-match-p 'string-match-p "Org 9.0")

;;;; Functions and variables from previous releases now obsolete.
(define-obsolete-function-alias 'org-element-remove-indentation
  'org-remove-indentation "Org 9.0")
(define-obsolete-variable-alias 'org-latex-create-formula-image-program
  'org-preview-latex-default-process "Org 9.0")
(define-obsolete-variable-alias 'org-latex-preview-ltxpng-directory
  'org-preview-latex-image-directory "Org 9.0")
(define-obsolete-function-alias 'org-table-p 'org-at-table-p "Org 9.0")
(define-obsolete-function-alias 'org-on-heading-p 'org-at-heading-p "Org 9.0")
(define-obsolete-function-alias 'org-at-regexp-p 'org-in-regexp "Org 8.3")
(define-obsolete-function-alias 'org-image-file-name-regexp
  'image-file-name-regexp "Org 9.0")
(define-obsolete-function-alias 'org-completing-read-no-i
  'completing-read "Org 9.0")
(define-obsolete-function-alias 'org-icompleting-read
  'completing-read "Org 9.0")
(define-obsolete-function-alias 'org-iread-file-name 'read-file-name "Org 9.0")
(define-obsolete-function-alias 'org-days-to-time
  'org-time-stamp-to-now "Org 8.2")
(define-obsolete-variable-alias 'org-agenda-ignore-drawer-properties
  'org-agenda-ignore-properties "Org 9.0")
(define-obsolete-function-alias 'org-preview-latex-fragment
  'org-toggle-latex-fragment "Org 8.3")
(define-obsolete-function-alias 'org-export-get-genealogy
  'org-element-lineage "Org 9.0")
(define-obsolete-variable-alias 'org-latex-with-hyperref
  'org-latex-hyperref-template "Org 9.0")
(define-obsolete-variable-alias 'hfy-optimisations 'hfy-optimizations "Org 9.0")
(define-obsolete-variable-alias 'org-export-htmlized-org-css-url
  'org-org-htmlized-css-url "Org 8.2")
(define-obsolete-function-alias 'org-list-parse-list 'org-list-to-lisp "Org 9.0")
(define-obsolete-function-alias 'org-agenda-todayp
  'org-agenda-today-p "Org 9.0")
(define-obsolete-function-alias 'org-babel-examplize-region
  'org-babel-examplify-region "Org 9.0")
(define-obsolete-variable-alias 'org-babel-capitalize-example-region-markers
  'org-babel-uppercase-example-markers "Org 9.1")

(define-obsolete-function-alias 'org-babel-trim 'org-trim "Org 9.0")
(define-obsolete-variable-alias 'org-html-style 'org-html-head "24.4")
(define-obsolete-function-alias 'org-insert-columns-dblock
  'org-columns-insert-dblock "Org 9.0")
(define-obsolete-variable-alias 'org-export-babel-evaluate
  'org-export-use-babel "Org 9.1")
(define-obsolete-function-alias 'org-activate-bracket-links
  'org-activate-links "Org 9.0")
(define-obsolete-function-alias 'org-activate-plain-links 'ignore "Org 9.0")
(define-obsolete-function-alias 'org-activate-angle-links 'ignore "Org 9.0")
(define-obsolete-function-alias 'org-remove-double-quotes 'org-strip-quotes "Org 9.0")
(define-obsolete-function-alias 'org-get-indentation
  'current-indentation "Org 9.2")
(define-obsolete-function-alias 'org-capture-member 'org-capture-get "Org 9.2")
(define-obsolete-function-alias 'org-remove-from-invisibility-spec
  'remove-from-invisibility-spec "Org 9.2")

(define-obsolete-variable-alias 'org-effort-durations 'org-duration-units
  "Org 9.2")

(defun org-in-fixed-width-region-p ()
  "Non-nil if point in a fixed-width region."
  (save-match-data
    (eq 'fixed-width (org-element-type (org-element-at-point)))))
(make-obsolete 'org-in-fixed-width-region-p
               "use `org-element' library"
               "Org 9.0")

(defun org-compatible-face (inherits specs)
  "Make a compatible face specification.
If INHERITS is an existing face and if the Emacs version supports
it, just inherit the face.  If INHERITS is not given and SPECS
is, use SPECS to define the face."
  (declare (indent 1))
  (if (facep inherits)
      (list (list t :inherit inherits))
    specs))
(make-obsolete 'org-compatible-face "you can remove it." "Org 9.0")

(defun org-add-link-type (type &optional follow export)
  "Add a new TYPE link.
FOLLOW and EXPORT are two functions.

FOLLOW should take the link path as the single argument and do whatever
is necessary to follow the link, for example find a file or display
a mail message.

EXPORT should format the link path for export to one of the export formats.
It should be a function accepting three arguments:

  path    the path of the link, the text after the prefix (like \"http:\")
  desc    the description of the link, if any
  format  the export format, a symbol like `html' or `latex' or `ascii'.

The function may use the FORMAT information to return different values
depending on the format.  The return value will be put literally into
the exported file.  If the return value is nil, this means Org should
do what it normally does with links which do not have EXPORT defined.

Org mode has a built-in default for exporting links.  If you are happy with
this default, there is no need to define an export function for the link
type.  For a simple example of an export function, see `org-bbdb.el'.

If TYPE already exists, update it with the arguments.
See `org-link-parameters' for documentation on the other parameters."
  (org-link-set-parameters type :follow follow :export export)
  (message "Created %s link." type))

(make-obsolete 'org-add-link-type "use `org-link-set-parameters' instead." "Org 9.0")

;;;; Functions unused in Org core.
(defun org-table-recognize-table.el ()
  "If there is a table.el table nearby, recognize it and move into it."
  (when (and org-table-tab-recognizes-table.el (org-at-table.el-p))
    (beginning-of-line)
    (unless (or (looking-at org-table-dataline-regexp)
                (not (looking-at org-table1-hline-regexp)))
      (forward-line)
      (when (looking-at org-table-any-border-regexp)
        (forward-line -2)))
    (if (re-search-forward "|" (org-table-end t) t)
        (progn
          (require 'table)
          (if (table--at-cell-p (point)) t
            (message "recognizing table.el table...")
            (table-recognize-table)
            (message "recognizing table.el table...done")))
      (error "This should not happen"))))

;; Not used since commit 6d1e3082, Feb 2010.
(make-obsolete 'org-table-recognize-table.el
               "please notify Org mailing list if you use this function."
               "Org 9.0")

(defmacro org-preserve-lc (&rest body)
  (declare (debug (body))
	   (obsolete "please notify Org mailing list if you use this function."
		     "Org 9.2"))
  (org-with-gensyms (line col)
    `(let ((,line (org-current-line))
	   (,col (current-column)))
       (unwind-protect
	   (progn ,@body)
	 (org-goto-line ,line)
	 (org-move-to-column ,col)))))

(defun org-version-check (version &rest _)
  "Non-nil if VERSION is lower (older) than `emacs-version'."
  (declare (obsolete "use `version<' or `fboundp' instead."
		     "Org 9.2"))
  (version< version emacs-version))

(defun org-remove-angle-brackets (s)
  (org-unbracket-string "<" ">" s))
(make-obsolete 'org-remove-angle-brackets 'org-unbracket-string "Org 9.0")

(defcustom org-publish-sitemap-file-entry-format "%t"
  "Format string for site-map file entry.
You could use brackets to delimit on what part the link will be.

%t is the title.
%a is the author.
%d is the date formatted using `org-publish-sitemap-date-format'."
  :group 'org-export-publish
  :type 'string)
(make-obsolete-variable
 'org-publish-sitemap-file-entry-format
 "set `:sitemap-format-entry' in `org-publish-project-alist' instead."
 "Org 9.1")

(defvar org-agenda-skip-regexp)
(defun org-agenda-skip-entry-when-regexp-matches ()
  "Check if the current entry contains match for `org-agenda-skip-regexp'.
If yes, it returns the end position of this entry, causing agenda commands
to skip the entry but continuing the search in the subtree.  This is a
function that can be put into `org-agenda-skip-function' for the duration
of a command."
  (declare (obsolete "use `org-agenda-skip-if' instead." "Org 9.1"))
  (let ((end (save-excursion (org-end-of-subtree t)))
	skip)
    (save-excursion
      (setq skip (re-search-forward org-agenda-skip-regexp end t)))
    (and skip end)))

(defun org-agenda-skip-subtree-when-regexp-matches ()
  "Check if the current subtree contains match for `org-agenda-skip-regexp'.
If yes, it returns the end position of this tree, causing agenda commands
to skip this subtree.  This is a function that can be put into
`org-agenda-skip-function' for the duration of a command."
  (declare (obsolete "use `org-agenda-skip-if' instead." "Org 9.1"))
  (let ((end (save-excursion (org-end-of-subtree t)))
	skip)
    (save-excursion
      (setq skip (re-search-forward org-agenda-skip-regexp end t)))
    (and skip end)))

(defun org-agenda-skip-entry-when-regexp-matches-in-subtree ()
  "Check if the current subtree contains match for `org-agenda-skip-regexp'.
If yes, it returns the end position of the current entry (NOT the tree),
causing agenda commands to skip the entry but continuing the search in
the subtree.  This is a function that can be put into
`org-agenda-skip-function' for the duration of a command.  An important
use of this function is for the stuck project list."
  (declare (obsolete "use `org-agenda-skip-if' instead." "Org 9.1"))
  (let ((end (save-excursion (org-end-of-subtree t)))
	(entry-end (save-excursion (outline-next-heading) (1- (point))))
	skip)
    (save-excursion
      (setq skip (re-search-forward org-agenda-skip-regexp end t)))
    (and skip entry-end)))

(define-obsolete-function-alias 'org-minutes-to-clocksum-string
  'org-duration-from-minutes "Org 9.1")

(define-obsolete-function-alias 'org-hh:mm-string-to-minutes
  'org-duration-to-minutes "Org 9.1")

(define-obsolete-function-alias 'org-duration-string-to-minutes
  'org-duration-to-minutes "Org 9.1")

(make-obsolete-variable 'org-time-clocksum-format
  "set `org-duration-format' instead." "Org 9.1")

(make-obsolete-variable 'org-time-clocksum-use-fractional
  "set `org-duration-format' instead." "Org 9.1")

(make-obsolete-variable 'org-time-clocksum-fractional-format
  "set `org-duration-format' instead." "Org 9.1")

(make-obsolete-variable 'org-time-clocksum-use-effort-durations
  "set `org-duration-units' instead." "Org 9.1")

(define-obsolete-function-alias 'org-babel-number-p
  'org-babel--string-to-number "Org 9.0")

(define-obsolete-variable-alias 'org-usenet-links-prefer-google
  'org-gnus-prefer-web-links "Org 9.1")

(define-obsolete-variable-alias 'org-texinfo-def-table-markup
  'org-texinfo-table-default-markup "Org 9.1")

;; The function was made obsolete by commit 65399674d5 of 2013-02-22.
;; This make-obsolete call was added 2016-09-01.
(make-obsolete 'org-capture-import-remember-templates
	       "use the `org-capture-templates' variable instead."
	       "Org 9.0")

(defun org-show-block-all ()
  "Unfold all blocks in the current buffer."
  (interactive)
  (remove-overlays nil nil 'invisible 'org-hide-block))

(make-obsolete 'org-show-block-all
	       "use `org-show-all' instead."
	       "Org 9.2")

(define-obsolete-function-alias 'org-get-tags-at 'org-get-tags "Org 9.2")

(defun org-get-local-tags ()
  "Get a list of tags defined in the current headline."
  (declare (obsolete "use `org-get-tags' instead." "Org 9.2"))
  (org-get-tags nil 'local))

(defun org-get-local-tags-at (&optional pos)
  "Get a list of tags defined in the current headline."
  (declare (obsolete "use `org-get-tags' instead." "Org 9.2"))
  (org-get-tags pos 'local))

(defun org-get-tags-string ()
  "Get the TAGS string in the current headline."
  (declare (obsolete "use `org-make-tag-string' instead." "Org 9.2"))
  (org-make-tag-string (org-get-tags nil t)))

(define-obsolete-function-alias 'org-set-tags-to 'org-set-tags "Org 9.2")

(defun org-align-all-tags ()
  "Align the tags in all headings."
  (declare (obsolete "use `org-align-tags' instead." "Org 9.2"))
  (org-align-tags t))

(defmacro org-with-silent-modifications (&rest body)
  (declare (obsolete "use `with-silent-modifications' instead." "Org 9.2")
	   (debug (body)))
  `(with-silent-modifications ,@body))

(define-obsolete-function-alias 'org-babel-strip-quotes
  'org-strip-quotes "Org 9.2")

;;;; Obsolete link types

(eval-after-load 'org
  '(progn
     (org-link-set-parameters "file+emacs") ;since Org 9.0
     (org-link-set-parameters "file+sys"))) ;since Org 9.0



;;; Miscellaneous functions

(defun org-get-x-clipboard (value)
  "Get the value of the X or Windows clipboard."
  (cond ((and (eq window-system 'x)
              (fboundp 'gui-get-selection)) ;Silence byte-compiler.
         (org-no-properties
          (ignore-errors
            (or (gui-get-selection value 'UTF8_STRING)
                (gui-get-selection value 'COMPOUND_TEXT)
                (gui-get-selection value 'STRING)
                (gui-get-selection value 'TEXT)))))
        ((and (eq window-system 'w32) (fboundp 'w32-get-clipboard-data))
         (w32-get-clipboard-data))))

;; `set-transient-map' is only in Emacs >= 24.4
(defalias 'org-set-transient-map
  (if (fboundp 'set-transient-map)
      'set-transient-map
    'set-temporary-overlay-map))


;;; Region compatibility

(defvar org-ignore-region nil
  "Non-nil means temporarily disable the active region.")

(defun org-region-active-p ()
  "Non-nil when the region active.
Unlike to `use-region-p', this function also checks
`org-ignore-region'."
  (and (not org-ignore-region) (use-region-p)))

(defun org-cursor-to-region-beginning ()
  (when (and (org-region-active-p)
             (> (point) (region-beginning)))
    (exchange-point-and-mark)))


;;; Invisibility compatibility

(defun org-in-invisibility-spec-p (arg)
  "Is ARG a member of `buffer-invisibility-spec'?"
  (when (consp buffer-invisibility-spec)
    (member arg buffer-invisibility-spec)))

(defun org-move-to-column (column &optional force _buffer)
  "Move to column COLUMN.
Pass COLUMN and FORCE to `move-to-column'."
  (let ((buffer-invisibility-spec
         (if (listp buffer-invisibility-spec)
             (remove '(org-filtered) buffer-invisibility-spec)
           buffer-invisibility-spec)))
    (move-to-column column force)))

(defmacro org-find-library-dir (library)
  `(file-name-directory (or (locate-library ,library) "")))

(defun org-count-lines (s)
  "How many lines in string S?"
  (let ((start 0) (n 1))
    (while (string-match "\n" s start)
      (setq start (match-end 0) n (1+ n)))
    (when (and (> (length s) 0) (= (aref s (1- (length s))) ?\n))
      (setq n (1- n)))
    n))

(defun org-kill-new (string &rest args)
  (remove-text-properties 0 (length string) '(line-prefix t wrap-prefix t)
                          string)
  (apply 'kill-new string args))

;; `font-lock-ensure' is only available from 24.4.50 on
(defalias 'org-font-lock-ensure
  (if (fboundp 'font-lock-ensure)
      #'font-lock-ensure
    (lambda (&optional _beg _end)
      (with-no-warnings (font-lock-fontify-buffer)))))

;; `file-local-name' was added in Emacs 26.1.
(defalias 'org-babel-local-file-name
  (if (fboundp 'file-local-name)
      'file-local-name
    (lambda (file)
      "Return the local name component of FILE."
      (or (file-remote-p file 'localname) file))))

;;;###autoload
(defmacro org-check-version ()
  "Try very hard to provide sensible version strings."
  (let* ((org-dir        (org-find-library-dir "org"))
         (org-version.el (concat org-dir "org-version.el"))
         (org-fixup.el   (concat org-dir "../mk/org-fixup.el")))
    (if (require 'org-version org-version.el 'noerror)
        '(progn
           (autoload 'org-release     "org-version.el")
           (autoload 'org-git-version "org-version.el"))
      (if (require 'org-fixup org-fixup.el 'noerror)
          '(org-fixup)
        ;; provide fallback definitions and complain
        (warn "Could not define org version correctly.  Check installation!")
        '(progn
           (defun org-release () "N/A")
           (defun org-git-version () "N/A !!check installation!!"))))))



;;; Functions for Emacs < 24.4 compatibility

(defun org-define-error (name message)
  "Define NAME as a new error signal.
MESSAGE is a string that will be output to the echo area if such
an error is signaled without being caught by a `condition-case'.
Implements `define-error' for older emacsen."
  (if (fboundp 'define-error) (define-error name message)
    (put name 'error-conditions
         (copy-sequence (cons name (get 'error 'error-conditions))))))

(unless (fboundp 'string-suffix-p)
  ;; From Emacs subr.el.
  (defun string-suffix-p (suffix string  &optional ignore-case)
    "Return non-nil if SUFFIX is a suffix of STRING.
If IGNORE-CASE is non-nil, the comparison is done without paying
attention to case differences."
    (let ((start-pos (- (length string) (length suffix))))
      (and (>= start-pos 0)
           (eq t (compare-strings suffix nil nil
                                  string start-pos nil ignore-case))))))

(unless (fboundp 'proper-list-p)
  ;; `proper-list-p' was added in Emacs 27.1.  The function below is
  ;; taken from Emacs subr.el 200195e824b^.
  (defun proper-list-p (object)
    "Return OBJECT's length if it is a proper list, nil otherwise.
A proper list is neither circular nor dotted (i.e., its last cdr
is nil)."
    (and (listp object) (ignore-errors (length object)))))


;;; Integration with and fixes for other packages

(defgroup org-imenu-and-speedbar nil
  "Options concerning imenu and speedbar in Org mode."
  :tag "Org Imenu and Speedbar"
  :group 'org-structure)

(defcustom org-imenu-depth 2
  "The maximum level for Imenu access to Org headlines.
This also applied for speedbar access."
  :group 'org-imenu-and-speedbar
  :type 'integer)

;;;; Imenu

(defvar-local org-imenu-markers nil
  "All markers currently used by Imenu.")

(defun org-imenu-get-tree ()
  "Produce the index for Imenu."
  (dolist (x org-imenu-markers) (move-marker x nil))
  (setq org-imenu-markers nil)
  (org-with-wide-buffer
   (goto-char (point-max))
   (let* ((re (concat "^" (org-get-limited-outline-regexp)))
	  (subs (make-vector (1+ org-imenu-depth) nil))
	  (last-level 0))
     (while (re-search-backward re nil t)
       (let ((level (org-reduced-level (funcall outline-level)))
	     (headline (org-no-properties
			(org-link-display-format (org-get-heading t t t t)))))
	 (when (and (<= level org-imenu-depth) (org-string-nw-p headline))
	   (let* ((m (point-marker))
		  (item (propertize headline 'org-imenu-marker m 'org-imenu t)))
	     (push m org-imenu-markers)
	     (if (>= level last-level)
		 (push (cons item m) (aref subs level))
	       (push (cons item
			   (cl-mapcan #'identity (cl-subseq subs (1+ level))))
		     (aref subs level))
	       (cl-loop for i from (1+ level) to org-imenu-depth
			do (aset subs i nil)))
	     (setq last-level level)))))
     (aref subs 1))))

(eval-after-load "imenu"
  '(progn
     (add-hook 'imenu-after-jump-hook
	       (lambda ()
		 (when (derived-mode-p 'org-mode)
		   (org-show-context 'org-goto))))
     (add-hook 'org-mode-hook
	       (lambda ()
		 (setq imenu-create-index-function 'org-imenu-get-tree)))))

;;;; Speedbar

(defvar org-speedbar-restriction-lock-overlay (make-overlay 1 1)
  "Overlay marking the agenda restriction line in speedbar.")
(overlay-put org-speedbar-restriction-lock-overlay
	     'face 'org-agenda-restriction-lock)
(overlay-put org-speedbar-restriction-lock-overlay
	     'help-echo "Agendas are currently limited to this item.")
(delete-overlay org-speedbar-restriction-lock-overlay)

(defun org-speedbar-set-agenda-restriction ()
  "Restrict future agenda commands to the location at point in speedbar.
If there is already a restriction lock at the location, remove it.

To get rid of the restriction, use `\\[org-agenda-remove-restriction-lock]'."
  (interactive)
  (require 'org-agenda)
  (let (p m tp np dir txt)
    (cond
     ((setq p (text-property-any (point-at-bol) (point-at-eol)
				 'org-imenu t))
      (setq m (get-text-property p 'org-imenu-marker))
      (with-current-buffer (marker-buffer m)
	(goto-char m)
	(if (and org-agenda-overriding-restriction
		 (member org-agenda-restriction-lock-overlay
			 (overlays-at (point))))
	    (org-agenda-remove-restriction-lock 'noupdate)
	  (org-agenda-set-restriction-lock 'subtree))))
     ((setq p (text-property-any (point-at-bol) (point-at-eol)
				 'speedbar-function 'speedbar-find-file))
      (setq tp (previous-single-property-change
		(1+ p) 'speedbar-function)
	    np (next-single-property-change
		tp 'speedbar-function)
	    dir (speedbar-line-directory)
	    txt (buffer-substring-no-properties (or tp (point-min))
						(or np (point-max))))
      (with-current-buffer (find-file-noselect
			    (let ((default-directory dir))
			      (expand-file-name txt)))
	(unless (derived-mode-p 'org-mode)
	  (user-error "Cannot restrict to non-Org mode file"))
	(org-agenda-set-restriction-lock 'file)))
     (t (user-error "Don't know how to restrict Org mode agenda")))
    (move-overlay org-speedbar-restriction-lock-overlay
		  (point-at-bol) (point-at-eol))
    (setq current-prefix-arg nil)
    (org-agenda-maybe-redo)))

(defvar speedbar-file-key-map)
(declare-function speedbar-add-supported-extension "speedbar" (extension))
(eval-after-load "speedbar"
  '(progn
     (speedbar-add-supported-extension ".org")
     (define-key speedbar-file-key-map "<" 'org-speedbar-set-agenda-restriction)
     (define-key speedbar-file-key-map "\C-c\C-x<" 'org-speedbar-set-agenda-restriction)
     (define-key speedbar-file-key-map ">" 'org-agenda-remove-restriction-lock)
     (define-key speedbar-file-key-map "\C-c\C-x>" 'org-agenda-remove-restriction-lock)
     (add-hook 'speedbar-visiting-tag-hook
	       (lambda () (and (derived-mode-p 'org-mode) (org-show-context 'org-goto))))))

;;;; Add Log

(defun org-add-log-current-headline ()
  "Return current headline or nil.
This function ignores inlinetasks.  It is meant to be used as
`add-log-current-defun-function' value."
  (org-with-limited-levels (org-get-heading t t t t)))

;;;; Flyspell

(defun org--flyspell-object-check-p (element)
  "Non-nil when Flyspell can check object at point.
ELEMENT is the element at point."
  (let ((object (save-excursion
		  (when (looking-at-p "\\>") (backward-char))
		  (org-element-context element))))
    (cl-case (org-element-type object)
      ;; Prevent checks in links due to keybinding conflict with
      ;; Flyspell.
      ((code entity export-snippet inline-babel-call
	     inline-src-block line-break latex-fragment link macro
	     statistics-cookie target timestamp verbatim)
       nil)
      (footnote-reference
       ;; Only in inline footnotes, within the definition.
       (and (eq (org-element-property :type object) 'inline)
	    (< (save-excursion
		 (goto-char (org-element-property :begin object))
		 (search-forward ":" nil t 2))
	       (point))))
      (otherwise t))))

(defun org-mode-flyspell-verify ()
  "Function used for `flyspell-generic-check-word-predicate'."
  (if (org-at-heading-p)
      ;; At a headline or an inlinetask, check title only.  This is
      ;; faster than relying on `org-element-at-point'.
      (and (save-excursion (beginning-of-line)
			   (and (let ((case-fold-search t))
				  (not (looking-at-p "\\*+ END[ \t]*$")))
				(let ((case-fold-search nil))
				  (looking-at org-complex-heading-regexp))))
	   (match-beginning 4)
	   (>= (point) (match-beginning 4))
	   (or (not (match-beginning 5))
	       (< (point) (match-beginning 5))))
    (let* ((element (org-element-at-point))
	   (post-affiliated (org-element-property :post-affiliated element)))
      (cond
       ;; Ignore checks in all affiliated keywords but captions.
       ((< (point) post-affiliated)
	(and (save-excursion
	       (beginning-of-line)
	       (let ((case-fold-search t)) (looking-at "[ \t]*#\\+CAPTION:")))
	     (> (point) (match-end 0))
	     (org--flyspell-object-check-p element)))
       ;; Ignore checks in LOGBOOK (or equivalent) drawer.
       ((let ((log (org-log-into-drawer)))
	  (and log
	       (let ((drawer (org-element-lineage element '(drawer))))
		 (and drawer
		      (eq (compare-strings
			   log nil nil
			   (org-element-property :drawer-name drawer) nil nil t)
			  t)))))
	nil)
       (t
	(cl-case (org-element-type element)
	  ((comment quote-section) t)
	  (comment-block
	   ;; Allow checks between block markers, not on them.
	   (and (> (line-beginning-position) post-affiliated)
		(save-excursion
		  (end-of-line)
		  (skip-chars-forward " \r\t\n")
		  (< (point) (org-element-property :end element)))))
	  ;; Arbitrary list of keywords where checks are meaningful.
	  ;; Make sure point is on the value part of the element.
	  (keyword
	   (and (member (org-element-property :key element)
			'("DESCRIPTION" "TITLE"))
		(save-excursion
		  (search-backward ":" (line-beginning-position) t))))
	  ;; Check is globally allowed in paragraphs verse blocks and
	  ;; table rows (after affiliated keywords) but some objects
	  ;; must not be affected.
	  ((paragraph table-row verse-block)
	   (let ((cbeg (org-element-property :contents-begin element))
		 (cend (org-element-property :contents-end element)))
	     (and cbeg (>= (point) cbeg) (< (point) cend)
		  (org--flyspell-object-check-p element))))))))))
(put 'org-mode 'flyspell-mode-predicate 'org-mode-flyspell-verify)

(defun org-remove-flyspell-overlays-in (beg end)
  "Remove flyspell overlays in region."
  (and (bound-and-true-p flyspell-mode)
       (fboundp 'flyspell-delete-region-overlays)
       (flyspell-delete-region-overlays beg end)))

(defvar flyspell-delayed-commands)
(eval-after-load "flyspell"
  '(add-to-list 'flyspell-delayed-commands 'org-self-insert-command))

;;;; Bookmark

(defun org-bookmark-jump-unhide ()
  "Unhide the current position, to show the bookmark location."
  (and (derived-mode-p 'org-mode)
       (or (org-invisible-p)
	   (save-excursion (goto-char (max (point-min) (1- (point))))
			   (org-invisible-p)))
       (org-show-context 'bookmark-jump)))

;; Make `bookmark-jump' shows the jump location if it was hidden.
(eval-after-load "bookmark"
  '(if (boundp 'bookmark-after-jump-hook)
       ;; We can use the hook
       (add-hook 'bookmark-after-jump-hook 'org-bookmark-jump-unhide)
     ;; Hook not available, use advice
     (defadvice bookmark-jump (after org-make-visible activate)
       "Make the position visible."
       (org-bookmark-jump-unhide))))

;;;; Calendar

(defcustom org-calendar-to-agenda-key 'default
  "Key to be installed in `calendar-mode-map' for switching to the agenda.

The command `org-calendar-goto-agenda' will be bound to this key.

When set to `default', bind the function to `c', but only if it is
available in the Calendar keymap.  This is the default choice because
`c' can then be used to switch back and forth between agenda and calendar.

When nil, `org-calendar-goto-agenda' is not bound to any key."
  :group 'org-agenda
  :type '(choice
	  (const :tag "Bind to `c' if available" default)
	  (key-sequence :tag "Other binding")
	  (const :tag "No binding" nil))
  :safe (lambda (v) (or (symbolp v) (stringp v)))
  :package-version '(Org . "9.2"))

(defcustom org-calendar-insert-diary-entry-key [?i]
  "The key to be installed in `calendar-mode-map' for adding diary entries.
This option is irrelevant until `org-agenda-diary-file' has been configured
to point to an Org file.  When that is the case, the command
`org-agenda-diary-entry' will be bound to the key given here, by default
`i'.  In the calendar, `i' normally adds entries to `diary-file'.  So
if you want to continue doing this, you need to change this to a different
key."
  :group 'org-agenda
  :type 'sexp)

(defun org--setup-calendar-bindings ()
  "Bind Org functions in Calendar keymap."
  (pcase org-calendar-to-agenda-key
    (`nil nil)
    ((and key (pred stringp))
     (local-set-key (kbd key) #'org-calendar-goto-agenda))
    ((guard (not (lookup-key calendar-mode-map "c")))
     (local-set-key "c" #'org-calendar-goto-agenda))
    (_ nil))
  (unless (eq org-agenda-diary-file 'diary-file)
    (local-set-key org-calendar-insert-diary-entry-key
		   #'org-agenda-diary-entry)))

(eval-after-load "calendar"
  '(add-hook 'calendar-mode-hook #'org--setup-calendar-bindings))

;;;; Saveplace

;; Make sure saveplace shows the location if it was hidden
(eval-after-load "saveplace"
  '(defadvice save-place-find-file-hook (after org-make-visible activate)
     "Make the position visible."
     (org-bookmark-jump-unhide)))

;;;; Ecb

;; Make sure ecb shows the location if it was hidden
(eval-after-load "ecb"
  '(defadvice ecb-method-clicked (after esf/org-show-context activate)
     "Make hierarchy visible when jumping into location from ECB tree buffer."
     (when (derived-mode-p 'org-mode)
       (org-show-context))))

;;;; Simple

(defun org-mark-jump-unhide ()
  "Make the point visible with `org-show-context' after jumping to the mark."
  (when (and (derived-mode-p 'org-mode)
	     (org-invisible-p))
    (org-show-context 'mark-goto)))

(eval-after-load "simple"
  '(defadvice pop-to-mark-command (after org-make-visible activate)
     "Make the point visible with `org-show-context'."
     (org-mark-jump-unhide)))

(eval-after-load "simple"
  '(defadvice exchange-point-and-mark (after org-make-visible activate)
     "Make the point visible with `org-show-context'."
     (org-mark-jump-unhide)))

(eval-after-load "simple"
  '(defadvice pop-global-mark (after org-make-visible activate)
     "Make the point visible with `org-show-context'."
     (org-mark-jump-unhide)))

;;;; Session

;; Make "session.el" ignore our circular variable.
(defvar session-globals-exclude)
(eval-after-load "session"
  '(add-to-list 'session-globals-exclude 'org-mark-ring))

(provide 'org-compat)

;;; org-compat.el ends here
