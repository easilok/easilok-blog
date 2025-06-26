title: Moving to Nix
date: 2025-06-26 00:00:00
tags: blog, nix, guix, linux
---

After trying out to move my [workflows and systems to Guix](/blog/trying-guix-package-manager.html), without major breakthroughs, I decided to take a different path and make a small stop on Nix. My end goal here is to be able to completely move my mindset, and *obsolete* years of Linux usage knowledge, so I can fully grasp these new system implementations that seem to be the future. But why did I change my path? Let's take a ride.

## Nix and Guix

*Recently* there have been new wave of Linux package managers, that matured to become whole Linux distributions, promising full system reproducibility across time and different machines. This means that anywhere, anytime and with a couple of commands, it's possible to get a system online pretty much exactly the same as it was in another machine.

This approach is basically accomplished by configuring the whole system in code, following a specific language, that is then compiled to a new immutable *generation* of the system they represent. I won't go in details about how this works behind the curtains (that would be better explained in any of their official documentation) but, from my perspective, the biggest advantages these approaches have are:

- **Programmatic reproducible systems**, where not only I can be sure my configuration as code always produces a running system, the same configuration can be environment aware and produce different setups on different conditions. It is, after all, written in a programming language and later compiled;
- **Native rollbacks**, accomplished by the reproducible builds. Each new build is completely isolated and the previous one is kept stored, accessible from a single command (or even from the bootloader);
- **Full declarative setup**, from system configurations, to user packages and application configurations, all is done through code, meaning that the current setup is always documented and instantly deployed;
- **Native setup for isolated development environments**, leveraging the declarative approach, I can have a configuration file, with specific development requirements, and temporarily deploy it on a current shell without polluting the whole system. 

## Why I'm still not using them?

I have been running Linux systems for some years now. And I'm kind of an explorer, specially for gathering knowledge, so I have experimented with almost every major distro, from Ubuntu to Arch, with quick stops in Void, MX linux and even Gentoo, for desktop and server usage.

Parallel to this, my whole system is heavily customized with a traditional dotfiles repository. I built an Ansible playbook that quickly deploys my system, specially my work setup, from a single command. This playbook is prepared to deploy on Mint and Debian, the two distros I am primarily using nowadays for work, and even Open Suse, that I intended to give a try in my personal laptop recently.

Today, I know my way around a traditional installation, I compile some programs from source, either to have the latest versions or to get around their absence on distro package managers, and have my own customizations of a lot of programs, services and even system behaviors. Making this change requires a lot of learnings, migrate a lot of my own crafted configuration/scripts/services to the Nix/Guix way and, most of all, time.

So I've been doing it slow and careful.

## Why am I moving now?

So it's clear I have quite a bit of work invested in improving my system deploys and it actually works pretty great. But it also gets outdated quickly, either because years have passed since I required to do a full deploy and somethings change in latest distro versions, or because I added packages or moved to other applications, which are normally done locally and never reach the playbook. 

So, normally, when it's time for a new deploy, I need to spin a virtual machine, test my playbook on the target distro, make some fixes and arrangements, and only then it is ready to be used in *"production"*.

From what I've already research and saw from other people, the [Nix](https://nixos.org/)/[Guix](https://guix.gnu.org/) way seems like a great match for me. It will allow me to properly define all my systems with code, as well as my configurations. It is a rolling release system with a feeling of stability, allowing advanced customizations and, maybe the most important reason, it is a great source of new knowledge. 

With the [home manager](https://nixos.wiki/wiki/Home_Manager)/[home configuration](https://guix.gnu.org/manual/devel/en/html_node/Home-Configuration.html) it is possible to conditional setup application configurations and integrations quickly, possible handling obsoletion automatically, without requiring me to always be up to date with changes of all my applications.

And... I need a new installation on my personal laptop, which as of today, forces me to drop all excuses to avoid this migration.

## Why Nix and not Guix?

Well, I really like Guix. I prefer the language, the structure and some of the decisions they made, but I think the lock on GNU is both a bless and a curse. It's great too force their mentality, and makes you choose GNU projects by default, but that reduces a lot of the available packages. They're strict approach, although more efficient, makes some software difficult to package. I know the [Nonguix](https://gitlab.com/nonguix/nonguix) project reduces that obstacles a lot, but it is really an workaround of the official project.

This is essentially what was slowing my migration. Although I could get around to use it personally, it's impossible to use it for work as of today, because I require some non GNU software, which I need to package myself. Guix also has a smaller community, so much of what I accomplished was by exploring and reading their code, with only a couple of examples. I set a lot of time, during my experiences with it, making my own package definitions, trying to replicate my setup and contributing back. Unfortunately I currently don't have the time that this approach was requiring.

Nix, on the other hand, has a vast community and a lot of documentation (many is obsolete or conflicting, but is enough for me to get around). There are also a lot of configurations spread across the internet, from beginner to advanced, and good tutorials. Their language is not the most useful one, as it only serves this purpose, and has its quirks. But I don't mind messing around with different languages.

So I made the decision of trying out Nix first, try to get around this new kind of systems with the resources they provide, and eventually start a new migration from there to Guix.  After all, they [can coexist perfectly](https://search.nixos.org/options?channel=25.05&show=services.guix.enable&from=0&size=50&sort=relevance&type=packages&query=Guix).

## Final thoughts

I am already very deep on this migration as of today. In fact, I've already migrated a development server I have on the cloud; some of my personal configurations on my work Debian instance; and my personal laptop in a basic installation. 

Maybe it was due to what I've been researching and testing on this subject up until now, or maybe Nix is, after all, more understandable than I thought, but I'm very surprised by the speed it took to arrive at the state I'm at. 

In the next days I'll share the steps I took to reach this proof-of-concept situation and some of the major difficulties I faced. 
