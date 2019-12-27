(setq
 user-mail-address "pepe@pepegar.com"
 user-full-name "Pepe García"
 gnus-select-method '(nnnil)
 gnus-secondary-select-methods
 '((nnmaildir "pepegar" (directory "~/Mail/pepegar/"))
   (nnmaildir "47deg" (directory "~/Mail/47deg/"))
   (nntp "news.gmane.org")))


(setq-default
 gnus-summary-line-format "%U%R%z %(%&user-date;  %-15,15f %* %B%s%)\n"
 gnus-user-date-format-alist '((t . "%d.%m.%Y %H:%M"))
 gnus-summary-thread-gathering-function 'gnus-gather-threads-by-references
 gnus-thread-sort-functions '(gnus-thread-sort-by-date)
 gnus-sum-thread-tree-false-root ""
 gnus-sum-thread-tree-leaf-with-other "├► "
 gnus-sum-thread-tree-indent "   "
 gnus-sum-thread-tree-root "● "
 gnus-sum-thread-tree-single-leaf "╰► "
 gnus-sum-thread-tree-vertical "│  "
 gnus-sum-thread-tree-single-indent "◎ "
 line-spacing 0)

(gnus-add-configuration
 '(article
   (horizontal 1.0
               (vertical 40
                         (group 1.0))
               (vertical 1.0
                         (summary 0.35 point)
                         (article 1.0))))
 )

(gnus-add-configuration
 '(summary
   (horizontal 1.0
               (vertical 40
                         (group 1.0))
               (vertical 1.0
                         (summary 1.0 point))))
 )

(with-eval-after-load "mm-decode"
  (add-to-list 'mm-discouraged-alternatives "text/html")
  (add-to-list 'mm-discouraged-alternatives "text/richtext"))
