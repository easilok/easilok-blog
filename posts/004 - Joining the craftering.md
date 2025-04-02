title: Joining the Craftering
date: 2025-04-02 00:00:00
tags: blog, community, haunt
---
It's official 🎉, this blog is now part of the [SystemCrafters community webring](https://craftering.systemcrafters.net), which is a mark of great importance to me. Not only because it makes it more real, adding the responsibility on myself of keeping it alive from now on, but also because it was added to the ring on its first anniversary, as the twentieth member. This event also deserved a better reading experience, so I'm deploying my own carefully crafted theme.

### But what is a webring?

In simple terms, a webring is a group of sites that are linked together in a circular navigation approach. Each site have links to two other sites, the previous and the next on the circular ring (in this blog the links are located at the footer of every page). Assuming that all sites in the webring are somehow related in content, this enables visitors to quickly discover other sites that could be of their interest.

But, to be honest, there is no best way to learn more about this than reading the article from [***shom***](https://shom.dev), the [creator of the craftering](https://shom.dev/posts/20240417_starting-a-webring-in-2024/).

### Why did I join?

I came across the SystemCrafters community some years ago, on my journey to learn a little more about emacs and LISP based languages, and found a very dynamic and helpful community. [David Wilson's](https://systemcrafters.net/) streams were (and still are to this day) very real and funny (special when debugging issues), which very quickly became a real pleasure to watch and take part on the community discussions going on the IRC channel. SystemCrafters also arrived at a time I was really needing a shift on my professional career to find pleasure and fun on what I was doing on my day to day, which all of them, unknowingly, made a real difference.

Ironically, that career shift really happened and, due to the new learnings and personal improvements it required, pushed me to become a distant follower of the community for sometime.

But this transition settled and my interest in the LISP universe found its way back on my head, proving that the time to get close to the community has arrived. I'm now becoming more active, very happy for the way it has evolved and the new people I met, hoping to eventually contribute for what they are doing. I'm learning my way through [guile](https://www.gnu.org/software/guile/), [guix](https://guix.gnu.org/) and even [common lisp](https://gigamonkeys.com/book/), and have some ongoing projects on this direction and decided to start my contributions with joining the craftering promising to document my journey and learnings, not only for any visitor who find them useful but also for me to know the path that I personally have traveled.

### Improving the blog UI

After the [initial release](/blog/haunting-this-blog.html) of this blog, I promised an UI improvement for the reader to enjoy my content. Joining the craftering made me want to speed this implementation as more people would be able to reach the site and I wanted to give a good reading experience and keep the new visitors interested in my next writings.

So diving again in the [haunt](https://dthompson.us/projects/haunt.html), and using [glenneth's](https://glenneth.srht.site/) and [dthompson's](https://dthompson.us/) own sites as examples, I refactored my `haunt` configuration to adapt my previous site layout.

The first step was to create my [haunt theme](https://files.dthompson.us/docs/haunt/latest/Blog.html#index-theme), which basically consists in creating the [`sxml`](https://www.gnu.org/software/guile/manual/html_node/SXML.html) structure that will produce the `html` that represents each of the static pages generated. This is accomplished by setting three procedure keys:

- `#:layout`, which holds the template definition of the whole HTML page, and where the body of the page is supplied on the `body` argument;
- `#:post-template`, that holds the template that builds the HTML of the content of a blog post. For example, using [commonmark](https://files.dthompson.us/docs/haunt/latest/CommonMark.html) as the source of content, this template defines how that parsed content is rendered on the page;
- `#:collection-template`, which configures, for example, how a list of existing posts is rendered on the page.

I used these procedures to organize the page content as I wanted, introducing some CSS classes when needed. The result was actually very clean and simple, which really surprised me, but also remembered me that we can go pretty far and really quick if the focus is on what it really matters. This site is basically built using the following configuration:

```scheme
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
                       (href "/assets/css/main.css")))
             (body
               ,easilok-header
               (hr (@ (class "separator")))
              (div (@ (class "main-content"))
                   ,body)))))
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
                   posts)))))

                   
```

Naturally there are CSS definitions behind (and some other additions for the craftering to work), but those are not that much complicated and can be better viewed [at the code](https://codeberg.org/easilok/easilok-blog/src/commit/09e239b338c0b083bed6d4e7d5009b1d2e0ea8f9).

**Notes:**

- As I saw different behavior of the UI on different browsers, I decided to use [normalize.css](https://necolas.github.io/normalize.css/) to improve standardization.
- Although most of the layout was migrated from my previous site, I tried to experiment with a new color set which I took inspiration from the [paperheartdesign](https://paperheartdesign.com/blog/color-palette-top-10-of-2020).

### Conclusions

First and most important, happy birthday to the craftering and thanks to the SystemCrafters community for making me want to write about what I'm doing and learning.

I'm really enjoying my path and learnings, and I'll soon release some articles of what I was capable of doing with `guile` and in `guix`. Making this site with `haunt` has been a breeze and I'm already planning the next additions like a **proper frontpage** with introduction for my self and **post filtering by tag**.

See you soon crafters.
