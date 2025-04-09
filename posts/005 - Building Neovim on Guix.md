title: Building Neovim on Guix
date: 2025-04-09 00:00:00
tags: blog, guix, neovim
---

As I lean deeper in migrating my workflow to [guix](https://guix.gnu.org/en/) (as a package manager for now), I wanted to reach a configuration that fully deploys all my terminal development setup. When I start adding packages to my [development profile](/blog/trying-guix-package-manager.html) I soon found the first obstacle: only `neovim@0.9.5` was available on official repository, which was way behind the one I was using, making some configuration and plugins incompatible. So I set on defining my own build for `neovim@0.10.4` and even `neovim@0.11.0`, which was release during this work. 

This article presents the steps I took to successfully build both versions as well as the issues I need to solve through the process. As a bonus, I also skim over how I setup my own channel for anyone to use with the results.

## Custom packages setup

From my previous adventures with `guix`, I had already prepared a location for my own defined packages. They were located at `~/.config/guix/packages`, where a `lp`  subfolder dictates the namespace used for their guile modules (`lp` standing for my name initials). With this setup I can run any `guix` command with the `-L` option pointing to that path, and build or install any package declared on the module files.

## Building neovim@0.10.4

The first step I tried to build this version, and the obvious one I must say, was to create a new package definition for the version, inheriting the definition used by the current version on the `guix` repository, only changing the `git tag` and its `SHA256`:

```scheme
(define-public nvim-0.10.4
               (package (inherit neovim)
                        (name "neovim")
                        (version "0.10.4")
                        (source (origin
                                  (method git-fetch)
                                  (uri (git-reference
                                         (url "https://github.com/neovim/neovim")
                                         (commit (string-append "v" version))))
                                  (file-name (git-file-name name version))
                                  (sha256
                                    (base32 "007v6aq4kdwcshlp8csnp12cx8c0yq8yh373i916ddqnjdajn3z3"))))))

```

This would instruct `guix` to fetch the tag with the desired version, whose content should match the desired `SHA256`. This can be obtained by locally cloning the repository, checking out the desired tag, and running the following command inside the cloned folder:

```bash
guix hash -x --serializer=nar .
```

This package definition is enough to try my first build of the version:

```shell
guix build -L ~/.config/guix/packages neovim@0.10.4
```

Which, after some building steps, produced the following error:

```
/tmp/guix-build-neovim-0.10.4.drv-0/source/src/nvim/lua/treesitter.c:1176:(.text+0x359a): undefined reference to `ts_query_cursor_set_max_start_depth'

collect2: error: ld returned 1 exit status
```

Clearly there is something missing in the `guix` repository version of the `tree-sitter` package that is required for this new Neovim version to build. In order to advance, I also needed to build an updated `tree-sitter` version. Following the same approach I defined the package:

```scheme
(define-public tree-sitter-0.24.7
               (package
                 (inherit tree-sitter)
                 (name "tree-sitter")
                 (version "0.24.7")
                 (source (origin
                           (method git-fetch)
                           (uri (git-reference
                                  (url "https://github.com/tree-sitter/tree-sitter")
                                  (commit (string-append "v" version))))
                           (file-name (git-file-name name version))
                           (sha256
                                  (base32 "1shg4ylvshs9bf42l8zyskfbkpzpssj6fhi3xv1incvpcs2c1fcw"))))))
```

This definition built without issues, and so the new `neovim@0.10.4`, as soon as I updates its inputs to use this `tree-sitter` version instead of the inherited one. This was accomplished by the `modify-inputs` macro:

```scheme
(inputs (modify-inputs
          (package-inputs neovim)
          (replace "tree-sitter" tree-sitter-0.24.7)))
```

The final package definition for `neovim@0.10.4` resulted in:

```scheme
(define-public nvim-0.10.4
               (package (inherit neovim)
                        (name "neovim")
                        (version "0.10.4")
                        (source (origin
                                  (method git-fetch)
                                  (uri (git-reference
                                         (url "https://github.com/neovim/neovim")
                                         (commit (string-append "v" version))))
                                  (file-name (git-file-name name version))
                                  (sha256
                                    (base32 "007v6aq4kdwcshlp8csnp12cx8c0yq8yh373i916ddqnjdajn3z3"))))
                        (inputs (modify-inputs
                                  (package-inputs neovim)
                                  (replace "tree-sitter" tree-sitter-0.24.7)))))
```

## Building neovim@0.11.0

Life was going well, work being delivered thanks to my working Neovim stable version. I even started to migrate my new packages to my own channel to make it more reusable, when news got in: Neovim's team finally released version `0.11.0`.

> *"I can't have an outdated version now after all this work."* - My head

So I restarted the progress again, and you already know the first step:

```scheme
(define-public nvim-0.11.0
               (package
                 (inherit neovim)
                 (name "neovim")
                 (version "0.11.0")
                 ;; (...)
                 ))
```

Another error, even using `tree-sitter@0.24.7` that I had setup for the `neovim@0.10.4`. After some quick research, I noticed that there was also a new `tree-sitter@0.25.3`, and you should have already guessed:

```scheme
(define-public tree-sitter-0.25.3
               (package
                 (inherit tree-sitter)
                 (name "tree-sitter")
                 (version "0.25.3")
                 ;; (...)
                 ))
```

Updated the `neovim@0.11.0` package definition to use this `tree-sitter` version, and it's time for another round of package build, which resulted in a new error:

```
CMake Error at /gnu/store/2lxfijiqqljxdxr2ppqqrn5czkh4r1rq-cmake-minimal-3.24.2/share/cmake-3.24/Modules/FindPackageHandleStandardArgs.cmake:230 (message):

Could NOT find UTF8proc (missing: UTF8PROC_LIBRARY UTF8PROC_INCLUDE_DIR)
```

This Neovim version has a new dependency and the build fails as it was not included in the package inputs. Searching the `guix` package repository by the `utf8proc` reference quickly showed that a package with that exact name was available, which I added to the build:

```scheme
(inputs (modify-inputs
          (package-inputs neovim)
          (replace "tree-sitter" tree-sitter-0.25.3)
          (append utf8proc-2.7.0)))
```

Time for a new round of building the `neovim@0.11.0` package, with this new definition, and I got a new fail:

```
/tmp/guix-build-neovim-0.11.0.drv-0/source/src/nvim/mbyte.c:479:29: 

error: ‘utf8proc_property_t’ {aka ‘const struct utf8proc_property_struct’} has no member named ‘ambiguous_width’
```

After checking the source code of the `utf8proc` package, it was clear that the `ambiguous_width` property was only added on the [version 2.10.0](https://github.com/JuliaStrings/utf8proc/blob/v2.10.0/utf8proc.h#L295). At this point the rules are well know: create a new package definition, inheriting the existing one, with the proper version as a checkout tag. This time, the approach was not as straight forward as with `tree-sitter`, which generated a lot of new knowledge.

## Building utf8proc@2.10.0

As expected, the initial approach to build a new version of this package was to just inherit the definition of the existing repository version (`2.7.0` was the most recent available version on its own symbol):

```scheme
(define-public utf8proc-2.10.0
               (package
                 (inherit utf8proc-2.7.0)
                 (name "utf8proc")
                 (version "2.10.0")
                 (source
                   (origin
                     (method git-fetch)
                     (uri (git-reference
                            (url "https://github.com/JuliaStrings/utf8proc")
                            (commit (string-append "v" version))))
                     (file-name (git-file-name name version))
                     (sha256
                       (base32 "1n1k67x39sk8xnza4w1xkbgbvgb1g7w2a7j2qrqzqaw1lyilqsy2"))))))
```

The first build produced a clear error: `julia: command not found`. Using the previous Neovim package definitions as example, this error should be fixed with adding the `julia` package to its `native-inputs` (differences between `inputs` and `native-inputs` are explained on the [official guix documentation](https://guix.gnu.org/manual/en/html_node/package-Reference.html#index-inputs_002c-of-packages)):

```scheme
(native-inputs
  (modify-inputs
    (package-native-inputs utf8proc-2.7.0)
    (append julia)))
```

A new round of package building produced a new error:

```
line 0: failed !iscase(10fc) in data/Lowercase.txt
```

This one took some time to solve, as finding the reason behind it was rather quick, but proper fixing proved more difficult that it seemed. Investigation on both the package codebase and the `guix` definition of previous versions, raised a probable suspect:

The package build process fetched some required files whose URL was composed from a defined `UNICODE_VERSION` local variable. The inherited package version set it to version **14.0**, while the `Makefile` of the new `utf8proc` version required the `UNICODE_VERSION` to be **16.0**. The initial suspicion was then proved after a successfully build of the new package version within a `guix shell` with its dependencies.

The file that was causing the error was the `DerivedCoreProperties.txt`, so I applied the `modify-inputs` procedure, like before, to replace that dependency with the new definition using the correct `UNICODE_VERSION` updated. I won't present the code here, as that approach didn't stuck on me. During the investigation on the current `guix` package definition I noticed that, although the build was successful, the other required files were still being fetched from the original package definition, which used the unicode version **13.0**. With that realization, I decided to declare a new list of `native-inputs`, for this new version, with all the required dependencies updated:

```scheme
   (native-inputs
      (let ((UNICODE_VERSION "16.0.0"))
        `(("DerivedCoreProperties.txt"
           ,(origin
              (method url-fetch)
              (uri (string-append "https://www.unicode.org/Public/"
                                  UNICODE_VERSION "/ucd/DerivedCoreProperties.txt"))
              (sha256
                (base32 "1gfsq4vdmzi803i2s8ih7mm4fgs907kvkg88kvv9fi4my9hm3lrr"))))
          ("NormalizationTest.txt"
          ,(origin
             (method url-fetch)
             (uri (string-append "https://www.unicode.org/Public/"
                                 UNICODE_VERSION "/ucd/NormalizationTest.txt"))
             (sha256
              (base32 "1cffwlxgn6sawxb627xqaw3shnnfxq0v7cbgsld5w1z7aca9f4fq"))))
         ("GraphemeBreakTest.txt"
          ,(origin
             (method url-fetch)
             (uri (string-append "https://www.unicode.org/Public/"
                                 UNICODE_VERSION
                                 "/ucd/auxiliary/GraphemeBreakTest.txt"))
             (sha256
              (base32 "1d9w6vdfxakjpp38qjvhgvbl2qx0zv5655ph54dhdb3hs9a96azf"))))
          ;; For tests
          ("perl" ,perl)
          ("ruby" ,ruby)
          ("julia" ,julia))))
```

With this final [utf8proc package definition](https://codeberg.org/easilok/guix-lp/src/commit/bce64a1efbf875243c74132c898acdb73678da7d/.guix/modules/lp/packages/textutils.scm#L10), `neovim@0.11.0` finally built successfully and became ready to be used.

Although it seems like it was actually not that much difficult to built this package definition, aside all the code reading and researching to reach the final result, there was a big obstacle that also brought some knowledge with it:

To move faster, when defining the `native-inputs` of this package, I was just building it with the updated `git tag`, hoping that it failed to verify the provided hash. `guix` gives the expected hash when this type of verification fails, so I can update it on the package definition and move on.

```
sha256 hash mismatch for /gnu/store/q9822pzv9s7rb8acgfm1b7vhp2nppfc5-DerivedCoreProperties.txt:

expected hash: 0gfsq4vdmzi803i2s8ih7mm4fgs907kvkg88kvv9fi4my9hm3lrr                                                                 

actual hash:   1gfsq4vdmzi803i2s8ih7mm4fgs907kvkg88kvv9fi4my9hm3lrr

```

However I didn't noticed that, as the naming of the files were the same for all versions, `guix` saved them in its store with the provided hash as part off the generated store name. With my laziness of reusing the hash of the previous versions, the build process just kept using the file it already fetched for the original package, and the error kept happening. Only after a long debug and bug searching process I reached this conclusion, changed a random character on the declared hash, and the verification failed with my long awaited expected value to use.

## Moving to a personal channel

After all this work and learning, and having a fully functional build for `neovim@0.11.0`, I decided that it deserved to be on a personal `guix` channel, which could then be used by other people. This would also enable future me to use the same approach on other applications and quickly reuse the work on any machine by only issuing `guix pull` (provided that the channel is configured).

Creating a channel was extremely easy by following the [official documentation](https://guix.gnu.org/manual/en/html_node/Channels.html). All the package definitions are guile modules with the `lp packages` namespace. The channel content is located under the `.guix/modules` sub-directory so it's possible to use the channel repository for other functions in the future.

The end result can be found on [codeberg](https://codeberg.org/easilok/guix-lp/src/commit/bce64a1efbf875243c74132c898acdb73678da7d/) and the channel can be added to any channel list.
## Conclusions

This was, without a doubt, a great adventure. It enabled me to learned more about the `guix` build process, its package definitions and how to extend an existing definition to build different versions. It also taught me how to interpret `guix` errors, which I'm sure will become handy really soon, and iterate over them. 

Creating valid `guix` package definitions proved that the knowledge I've been gathering on the guile scheme language is also very useful to dynamically customize my systems.

The work done here was just to upgrade existing packages, but it made me more confident to eventually make the same for new ones, where the build process would need to be defined from scratch.

I also have my own channel now, which will be very useful for testing builds on my own systems and even make my own software available through it. And I believe it will help a lot when I decide to try to deploy my own substitute channel.

But the work done here shouldn't be only available for me of for whoever uses my channel, so the obvious next step is to understand how to contribute to `guix` and try to make this available to everyone on the main channel.
