title: Lisp is Contagious
date: 2025-08-21 00:00:00
tags: blog, lisp
---

I'm a very curious person and whenever I discover new concepts I'm heavily driven to learn and understand how they work, sometimes quite like obsessions. That's actually what made me follow electrical engineering, trying to better understand what makes technology work how it works. The same applies to programming and I'm frequently fascinated to gather knowledge around tools, approaches and languages, specially to make computers do something I need or want. Buckle up and let me take you on my journey on the most recent subject of this obsession: the Lisp family of languages. 

Well, in reality I've been on and off this thematic for some years now, depending on what's going on on my life, but in the last couple of months I've been diving very deep in it and getting a lot of fun in the process. 

## How it started

My very first contact with the Lisp Family was around 2013, when I worked as a electrical panel designer using AutoCAD, a software that can be extended using its own Lisp implementation (I even got a [book to learn it](/assets/img/2025-08-21_autolisp_book.webp)). But I only worked a year in that job (as an intern), so I never got to learn anything useful at the time. Then, around 2021, I found [clojure](https://clojure.org/). I don't quite remember how it came to my attention, but I remember seeing some of the Rich Hickey's talks which was enough for me to get a copy of [clojure for the brave and true](https://www.braveclojure.com/), a very well praised book in the matters.

At the time my daily job was around embedded firmware and some small software applications to configure those embedded systems so, not only did I not know what lisp was, I also had never heard about functional programming or immutability. What I learn completely changed how I coded and how I though about coding. I even started to implement some of those approaches on my work in firmware development (unfortunately for my coworkers that did not understand what I was doing). But, as I'm more of a hands on the field type of person, I actually didn't finished the book, as time was scarce then, but started to make small day to day tools that improved my workflow using my learnings, until this curiosity lead me to emacs and the [SystemCrafters community](https://systemcrafters.net)

It was around that time that I learned about emacs lisp, moved my workflow from vim, and migrated some of the tools I had developed in clojure to run inside emacs, using its own language. It was a whole new and fun experience, where the knowledge I was collecting was being reinvested in improving my workflow, so I never felt as the time was lost. I even tipped my toes on [guix](https://guix.gnu.org/) trying to have my whole OS driven by a Lisp dialect (in this case, guile scheme). Then, middle 2022, my professional path made a heavy turn and I moved to web development at a new company.

This was my first time doing this type of work professionally (I was already doing some stuff as hobby) and I really wanted to focus and quickly become a trustworthy team member. So I took some time of this Lisp journey, in favor of a more stable workflow. In fact I even used VS Code for a couple of months, until I felt more comfortable and fully migrated to Neovim again.

## How it's going

Fast forward to 2025, I'm comfortable at my work and started feeling the rush to getting back to my fun moments with Lisp. This time, remembering my guix experiences, I wanted to try out developing with guile scheme and started reading its documentation. I also rejoined SystemCrafters and, funny enough, David was working on a web application in that same language. 

#### Guile Scheme Arc

To start getting my hands dirty, I thought of a great project to try it out: at work, we use [Confluence](https://www.atlassian.com/software/confluence) as our internal documentation tool. And I hate it! It's web based (I can't use my editor to add documentation), it's slow and full of quirks. I'm also against not being able to use the documentation (or even loose it) if the service goes down for some reason. So I set on making [confluencing-markdown](https://codeberg.org/easilok/confluencing-markdown), a CLI application that fetches a document from Atlassian's API and parses each content block into its markdown equivalent, effectively producing its markdown version of the document. 

A fun project that taught me how to make http requests, recursive transverse a data tree, and generate a new textual representation of it. I also learn the guile scheme module system and how to create an advanced and organized project. Although not finished, the project is currently on hold because I found some difficulties that require more investigation into Atlassian's API document structure, and I wanted to try common lisp 😅.

But it is working as intended for simple documents without images and external links.

#### Common Lisp Arc

After finally coding an application in scheme, I felt the desire to check the differences for Common Lisp (CL). For what I had already seen, it seemed a little more complex than scheme, but also more powerful. It was older, more mature, full of libraries and could be used for pretty much anything. It also can produce binaries, something I find really useful for the kind of personal projects I normally do when testing languages. ***Fade*** from SystemCrafters and [Gavin Freeborn](https://youtube.com/@GavinFreeborn) gave me the first contact with the language, feeding my interest, and I ended up getting the most respected [book for learning CL](https://gigamonkeys.com/book/) which I start to devour, much like when I found clojure. 

While I was reading it, I also wanted to play with the language and I found a good use case: I use trains as my work commute transport and, in my country, it has a lot of issues keeping the schedule. To increase its users frustration, there is no good way to be informed in advance with suppressions and heavy delays, although they have an API with that information. This gave birth to [latemate](https://codeberg.org/easilok/latemate), a Common Lisp web application where I can see the next trains for the stations I configure and how they are on their schedule. It *will* also include a notification system that periodic checks for delays and notifies me, so I'm not surprised with hours of delays when I need to get home at the end of the day. 

This project made me really fall in love with the Lisp way. I learn a lot, from data fetching, to processing into new data structures, and feed it to the web. It taught me how too structure the code, how to use the module system and think how to do a adaptable application. The project is far from finished and has great potential to be a great source of knowledge. I have a lot plans and ideas to this project and the approaches it took until now showed me better ways to do it, like using classes, multi threading and so on.

In the mean time, a simpler and more useful project appeared for applying my new CL skills, which made me take a little detour.

#### Common Lisp Arc - Detour

I found it very hard to organize my daily work. Not because of procrastination or lack of work to do, but because I have a lot of small tasks that get in the middle of my main work and delay everything. So I'm constantly trying tools to improve this, have proper track of what is delaying me, what I spent my time on and how to improve it. This search eventually lead me to [taskwarrior](https://taskwarrior.org/docs/) which is helping a lot into scheduling my day.

But I miss having a list of the tasks I have planned for the day be sent to me earlier in the morning, so I can prepare myself for the work ahead and eventually adjust something. This was a great excuse to start [notifwarrior](https://codeberg.org/easilok/notifwarrior), an application that reads taskwarrior tasks matching a filter, parses them, and sends a nice notification listing them to me in different channels ([NTFY](https://docs.ntfy.sh/) and email for now). This also allows me to create a more contained experiment on a notification system that can then be re-used in the *latemate* project.

This application taught me how to issue shell commands, make http requests and using SMTP. I also learned how to parse command line arguments and configuration files, and I properly produced a binary that can be run on any system. It is already being used for its initial purpose, and works flawlessly. I have new use cases for it, that will enable me to iterate on what I've already built so it can send me a list of tasks I completed at the end of the day for my raising my ego a little bit. This means: same application, different command options for selecting the report, effectively turning it into a configurable notification application for taskwarrior.

## Conclusions

It is very clear that Lisp languages have really grown on me and I'm having a lot of fun playing with them. S-expressions make the though process of how to implement something easier, as everything has the same logic so we naturally know how to do something. The REPL driving development is just awesome! The *notifwarrior* application was coded through several weeks, on a remote dev server, which was the REPL running during the whole development, with me just making incremental evaluations. 

I know I am still in my early steps and there is must to learn in this subject (like macros and OOP) but I'm very happy with the results of this journey. Having this use cases, specially ones that I'm really using daily, helps driving my focus and persistence to advance and produce something that at least just works.

I want to keep Lisp a permanent presence on my daily workflow, which means that my personal projects and tools will probably be using it whenever possible. I already have some ongoing changes that align with this mindset:

- Contrary to most Lisp enjoyers, I use Neovim not Emacs. I'm happy with it and it is well tailored to my hands now. This does not mean that I can't lisp it as I'm moving my [configuration to fennel](https://codeberg.org/easilok/nvim-config). Specially after seeing Gregory Anders, a Neovim core maintainer, talking about fennel in this [Neovim vs Emacs](https://www.youtube.com/watch?v=SnhcXR9CKno) discussion and later on [his own interview](https://www.youtube.com/watch?v=Nq2T28_ILxc).
- I'm also trying out [babashka](https://babashka.org/) for small script automations in my workflow (this one I blame [trev](https://trevdev.ca/) for presenting it to me).
- And in the near future, I'm really thinking on trying if I can Lisp a personal project that requires embedded firmware on a micro-controller.
