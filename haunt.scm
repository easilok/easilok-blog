(use-modules (haunt asset)
             (haunt site)
             (haunt post)
             (haunt builder blog)
             (haunt builder atom)
             (haunt builder assets)
             (haunt builder redirects)
             (haunt reader commonmark)
             (haunt publisher rsync))

(define blog-prefix "blog")

(define (production)
  (rsync-publisher
    #:destination "docker/easilok-blog/dist"
    #:host "production-blog"))

;;; Partials
(define easilok-header
  `(header (h1 (a (@ (href "/")) "Luís Pereira (easilok)"))
         (p "Sharing my learning journey on several technological topics.")))

(define easilok-main-theme
  (theme #:name "easilok-main"
         #:layout
         (lambda (site title body)
           `((doctype "html")
             (head
              (meta (@ (charset "utf-8")))
              (title ,(if title
                          (string-append title " :: easilok.dev")
                          (site-title site)))
              ;; css
              (link (@ (rel "stylesheet")
                       (href "/assets/css/normalize-801.css")))
              (link (@ (rel "stylesheet")
                       (href "/assets/css/main.css")))
             (body
               ,easilok-header
               (hr (@ (class "separator")))
              (div (@ (class "main-content"))
                   ,body)
              ;; Footer for the Craftering webring links
              (footer
                (hr)
                (p (em "Checkout the content from the  other "
                       (a (@ (href "https://systemcrafters.net") (target "_blank"))
                          "System Crafters") " webring members:"))
                (div (@ (class "craftering"))
                     (a (@ (href "https://craftering.systemcrafters.net/@easilok/previous")) "←")
                     (a (@ (href "https://craftering.systemcrafters.net/")) "craftering")
                     (a (@ (href "https://craftering.systemcrafters.net/@easilok/next")) "→")))))))))


(define (easilok-blog)
  (blog #:theme easilok-main-theme
        #:prefix blog-prefix
        #:collections `(("Recent Posts" "index.html" ,posts/reverse-chronological))))

(site #:title "Easilok Blog"
      #:domain "luispereira.dev"
      #:default-metadata
      '((author . "Luis Pereira"))
      #:readers (list commonmark-reader)
      #:build-directory "dist"
      #:builders (list (easilok-blog)
                       (static-directory "assets")
                       (atom-feed)
                       (atom-feeds-by-tag))
      #:publishers (list (production)))
