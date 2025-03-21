title: Haunting this Blog
date: 2025-03-23 00:00
tags: blog, scheme, haunt
---

Aligning with the previous posts, what better way is there to build this blog that using guile scheme? Well, maybe a lot, but we're here for the fun in learning new approaches, so I'm committed to build this blog using [haunt](https://files.dthompson.us/docs/haunt/latest/Introduction.html), an *"hackable static site generator written in Guile Scheme"*.

My main goal on this journey is to start small, right from the beginning. This means that, at the time of this post, the blog is using a very simple haunt configuration, without any theme customization, making it really raw. 

Whenever new customizations are added to the blog (and deployed), I'll ensure that a new post is created explaining what I've done. So in practice, the reader will be walking this path with me, and hopefully learning something along the way.

At any checkpoint, including this one, I'll leave a couple of images showing any relevant layout that was available at the moment, providing visual guidelines of the impact of the changes I made.

My initial haunt configuration is very trivial and only defines:

- Website [name and domain](https://files.dthompson.us/docs/haunt/latest/Sites.html);
- Default post author name;
- Readers for parsing the content (using [commonmark](https://files.dthompson.us/docs/haunt/latest/CommonMark.html) for markdown);
- Build output and [assets source](https://files.dthompson.us/docs/haunt/latest/Static-Assets.html) directories;
- Builders for [blog](https://files.dthompson.us/docs/haunt/latest/Blog.html), and [atom feed](https://files.dthompson.us/docs/haunt/latest/Atom.html)
- Some redirects to ensure proper user navigation.

So let's walk this learning path together and sorry for any bad UI parts at the moment. I will definitely improve it 😉.

**Next step:** probably adapt my old [personal website](https://luiscarlospereira.pt) theme for this blog, which eventually will replace the whole site.

## Theme screenshots

- [Blog homepage](/assets/img/2025-03-25_homepage.jpg)
- [This post](/assets/img/2025-03-25_haunt_post.jpg)
