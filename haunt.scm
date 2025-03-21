(use-modules (haunt asset)
             (haunt site)
             (haunt post)
             (haunt builder blog)
             (haunt builder atom)
             (haunt builder assets)
             (haunt builder redirects)
             (haunt reader commonmark))

(define blog-prefix "blog")

(define (easilok-blog)
  (blog #:prefix blog-prefix
        #:collections `(("Recent Posts" "blog.html" ,posts/reverse-chronological))))

(define (easilok-redirects)
  (redirects `(("/index.html" "/blog.html")
               (,(string-append blog-prefix "/index.html") "/blog.html"))))


(site #:title "Easilok Blog"
      #:domain "luispereira.dev"
      #:default-metadata
      '((author . "Luis Pereira"))
      #:readers (list commonmark-reader)
      #:build-directory "dist"
      #:builders (list (easilok-blog)
                       (static-directory "assets")
                       (atom-feed)
                       (atom-feeds-by-tag)
                       (easilok-redirects)))
