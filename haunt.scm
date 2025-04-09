(use-modules (haunt asset)
             (haunt site)
             (haunt post)
             (haunt builder blog)
             (haunt builder atom)
             (haunt builder assets)
             (haunt builder redirects)
             (haunt reader commonmark)
             (haunt publisher rsync)
             (ice-9 match)
             (srfi srfi-19))

(define blog-prefix "blog")

(define (production)
  (rsync-publisher
    #:destination "docker/easilok-blog/dist"
    #:host "production-blog"))

;; Extracts first paragraph of a post
;; credit to dthompson (https://git.dthompson.us/blog/tree/theme.scm)
(define (first-paragraph post)
  (let loop ((sxml (post-sxml post)))
    (match sxml
      (() '())
      (((and paragraph ('p . _)) . _)
       (list paragraph))
      ((head . tail)
       (cons head (loop tail))))))

;;; Partials
(define easilok-header
  `(header (h1 (a (@ (href "/")) "Luis Pereira (easilok)"))
         (p "Sharing my learning journey on several technological topics.")))

(define (build-tags-list post)
  (map (lambda (tag)
         ; TODO: add a link to a page view of posts by tags
         ; `(a (@ (href ,(string-append "/feeds/tags/" tag ".xml"))
         `(span (@ (class "tag-badge"))
                "#",tag))
       (assq-ref (post-metadata post) 'tags)))

(define easilok-main-theme
  (theme #:name "easilok-main"
         #:layout
         (lambda (site title body)
           `((doctype "html")
             (head
              (meta (@ (charset "utf-8")))
              (meta (@ (name "viewport")
                       (content "width=device-width, initial-scale=1")))
              (link (@ (rel "icon")
                       (type "image/png")
                       (sizes "32x32")
                       (href "/assets/favicon-32x32.png")))
              (link (@ (rel "icon")
                       (type "image/png")
                       (sizes "16x16")
                       (href "/assets/favicon-16x16.png")))
              (title ,(if title
                          (string-append title " :: easilok.dev")
                          (site-title site)))
              ;; css
              (link (@ (rel "stylesheet")
                       (href "/assets/css/normalize-801.css")))
              (link (@ (rel "stylesheet")
                       (href "/assets/css/main.css"))))
             (body
               ,easilok-header
               (hr (@ (class "separator")))
              (div (@ (class "main-content"))
                   ,body)
              ;; Footer for the Craftering webring links
              (footer
                (hr)
                (p (@ (class "copyright")) "© 2025 Luís Pereira")
                (p (em "Checkout the content from the  other "
                       (a (@ (href "https://systemcrafters.net") (target "_blank"))
                          "System Crafters") " webring members:"))
                (div (@ (class "craftering"))
                     (a (@ (href "https://craftering.systemcrafters.net/@easilok/previous")) "←")
                     (a (@ (href "https://craftering.systemcrafters.net/")) "craftering")
                     (a (@ (href "https://craftering.systemcrafters.net/@easilok/next")) "→"))))))
         #:post-template
         (lambda (post)
           `((article
               (h1 (@ (class "post__title"))
                   ,(post-ref post 'title))
               (div (@ (class "post__date"))
                    ,(date->string (post-date post)
                                   "~d ~b, ~Y"))
               (div (@ (class "post__tags"))
                    ,@(build-tags-list post))
               (div (@ (class "post__content"))
                    ,(post-sxml post)))))
         #:collection-template
         (lambda (site title posts prefix)
           (define (post-uri post)
             (string-append prefix "/" (site-post-slug site post) ".html"))
           `((h1 ,title)
             (div (@ (class "feed"))
                  ,(map (lambda (post)
                          (let ((uri (post-uri post)))
                            `(article (@ (class "feed__post"))
                                      (h2 (a (@ (href ,uri))
                                             ,(post-ref post 'title)))
                                      (div (@ (class "feed__post-date"))
                                           ,(date->string (post-date post)
                                                          "~d ~b, ~Y"))
                                      (div (@ (class "feed__post-tags"))
                                           ,@(build-tags-list post))
                                      (div (@ (class "feed__post-summary"))
                                           ,(first-paragraph post))
                                      (a (@ (href ,uri)) "read post →"))))
                        posts))))))


(define (easilok-blog)
  (blog #:theme easilok-main-theme
        #:prefix blog-prefix
        #:collections `(("Blog Posts" "index.html" ,posts/reverse-chronological))))

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
