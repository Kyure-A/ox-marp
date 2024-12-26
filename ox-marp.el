;;; ox-marp.el --- Org export engine for marp  -*- lexical-binding: t; -*-

;; Copyright (C) 2024 Kyure_A

;; Author: Kyure_A <github.com/Kyure-A>
;; Keywords: tools

;; Version: 0.0.1
;; Package-Requires: ((emacs "24.1") (ox))
;; URL: https://github.com/Kyure-A/ox-marp

;; SPDX-License-Identifier: GPL-3.0-or-later

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; Org export engine for marp

;;; Code:

(require 'ox-md)

(defgroup org-export-marp ()
  "Org export engine for marp."
  :group 'tools
  :prefix "org-marp-"
  :link '(url-link "https://github.com/Kyure-A/ox-marp"))

(defconst org-marp-options-alist
  '((:marp-theme "MARPTHEME" nil nil t)
    (:marp-paginate "MARPPAGINATE" nil nil t)
    (:marp-heading-divider "MARPHEADINGDIVIDER" nil nil t)))

(org-export-define-derived-backend 'marp 'md
                                   :menu-entry
                                   '(?M "Export to Marp"
                                        ((?m "To file" org-marp-export-to-file)
                                         (?p "To file and open" org-marp-export-to-file-and-open)))
                                   :options-alist org-marp-options-alist
                                   :translate-alist '((template . org-marp-template)
                                                      (headline . org-marp-headline)
                                                      (link . org-marp-link)
                                                      (src-block . org-marp-src-block)
                                                      (example-block . org-marp-example-block)))

(defun org-marp-template (contents info)
  "Marp 用のヘッダーと CONTENTS を結合して返す."
  (let ((theme (plist-get info :marp-theme))
        (paginate (plist-get info :marp-paginate))
        (heading-divider (plist-get info :marp-heading-divider)))
    (concat
     "---\n"
     (when theme (format "theme: %s\n" theme))
     (when paginate "paginate: true\n")
     (when heading-divider (format "headingDivider: %s\n" heading-divider))
     "---\n\n"
     contents)))

(defun org-marp-headline (headline contents info)
  "HEADLINE を Marp 用スライド形式に変換"
  (let* ((level (org-export-get-relative-level headline info))
         (title (org-export-data (org-element-property :title headline) info))
         (hashes (make-string level ?#))) ;; 見出しレベルに応じた '#' を生成
    (concat
     (format "%s %s\n" hashes title)
     contents)))

;; リンクを Markdown の形式に変換
(defun org-marp-link (link description info)
  "LINK を Markdown のリンク形式に変換"
  (let ((url (org-element-property :raw-link link))
        (link-type (org-element-property :type link)))
    (if (equal link-type "file")
        (format "![%s](%s)" (or description url) url)
      (format "[%s](%s)" (or description url) url))))

;; ソースコードブロックを Marp のコードブロックに変換
(defun org-marp-src-block (src-block contents info)
  "SRC-BLOCK を Markdown のコードフェンス形式に変換"
  (let ((lang (org-element-property :language src-block))
        (value (org-element-property :value src-block)))
    (format "```%s\n%s\n```\n" (or lang "") value)))

;; 実例ブロックをそのままコードフェンスで囲む
(defun org-marp-example-block (example-block contents info)
  "EXAMPLE-BLOCK を Markdown のコードフェンス形式に変換"
  (let ((value (org-element-property :value example-block)))
    (format "```\n%s\n```\n" value)))

;; エクスポート用の関数
(defun org-marp-export-to-file (&optional async subtreep visible-only body-only ext-plist)
  "現在の Org バッファを Marp 用 Markdown ファイルにエクスポート"
  (interactive)
  (let ((outfile (org-export-output-file-name ".md" subtreep)))
    (org-export-to-file 'marp outfile
                        async subtreep visible-only body-only ext-plist)))

(defun org-marp-export-to-file-and-open (&optional async subtreep visible-only body-only ext-plist)
  "現在の Org バッファを Marp 用 Markdown ファイルにエクスポートし開く"
  (interactive)
  (let ((outfile (org-marp-export-to-file async subtreep visible-only body-only ext-plist)))
    (when outfile
      (browse-url-of-file outfile))))

(provide 'ox-marp)
;;; ox-marp.el ends here
