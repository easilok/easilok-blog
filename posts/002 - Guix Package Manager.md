title: Trying Guix Package Manager
date: 2025-02-23 00:00
tags: guix, workflow
---

From debian, it is possible to install the guix package manager from `apt`. This will install whatever version is
present on the repositories. But after installation, a simple `guix pull` will update it to the latest version (although
it can take some time to finish depending on the difference to the newest version)

After that it's pretty much just follow the guix startup documentation, starting with the [application
setup](https://guix.gnu.org/manual/en/html_node/Application-Setup.html).

### Locales
Starting with the locales installation, I opted to reduce the number of locales installed for my usage, which resulted
in this `my-locales.scm` file:

```scheme
(use-modules (gnu packages base))

(make-glibc-utf8-locales
  glibc
  #:locales (list "en_US" "pt_PT")
  #:name "glibc-my-utf8-locales")
```

And then run the `guix package --install-from-file=./my-locales.scm` will install this trimmed version of the used
locales. The environment variable `GUIX_LOCPATH` referred on the installation guide was already set by the debian
installation by the `/etc/profile.d/guix.sh`.

### SSL certs

Applications like `git` uses SSL encrypted connections, which requires the presence of the Certificate Authorities in
the system. [On Guix](https://guix.gnu.org/manual/en/html_node/X_002e509-Certificates.html) this is accomplished with
the `nss-certs` and it's required or the following error will appear when using git:

```
server certificate verification failed. cafile: none crlfile: none guix
```

After that, each application uses a different environment variable to set where to look for those certificates. For
`git` and `curl` the following was set (along with a general used one):

```shell
export SSL_CERT_DIR="$HOME/.guix-profile/etc/ssl/certs"
export SSL_CERT_FILE="$HOME/.guix-profile/etc/ssl/certs/ca-certificates.crt"
export GIT_SSL_CAINFO="$SSL_CERT_FILE"
export CURL_CA_BUNDLE="$SSL_CERT_FILE"
```

These environment variables need to be always available on the shell used by GUIX, so they are normally set on the
`.bashrc`, `.zshrc` or, eventually, on your `.profile` if the file is loaded by your shell. 

I prefer a more organized way to handle those, which I'll present later on this post.

### Installing applications 

Following the [getting started](https://guix.gnu.org/manual/en/html_node/Getting-Started.html), applications can be
installed on the system with `guix install <package>`. 

However, in order to follow the advantage of the GUIX declarative setup features, as well as it's reproducibility, I
setup [custom profiles](https://guix.gnu.org/cookbook/en/html_node/Basic-setup-with-manifests.html) and use a manifest
file to install the applications that I required.

For this custom profile approach to work, there is 3 steps that I setup:

##### 1. Custom profile load

This basically follows an [official guide](https://guix.gnu.org/cookbook/en/html_node/Basic-setup-with-manifests.html)
for profiles, where it loads every profile folder located in a specific location.

In this example, the location `$HOME/.guix-extra-profiles` will contain folders corresponding a different profiles. GUIX
populates a `/etc/profile` file, inside each profile folder, that can be sourced to update all shell environment
variables to include what it provides.

```bash
GUIX_EXTRA_PROFILES=$HOME/.guix-extra-profiles
for i in $GUIX_EXTRA_PROFILES/*; do
  profile=$i/$(basename "$i")
  if [ -f "$profile"/etc/profile ]; then
    GUIX_PROFILE="$profile"
    . "$GUIX_PROFILE"/etc/profile
  fi
  unset profile
done
```
##### 2. Create manifests files

Each custom profile is then ruled by a `manifest` file which contains the packages it should contain. 

The following example can be a `development.scm` manifest file:

```scheme
;; -*- mode: guix-scheme-*-

(specifications->manifest
  '(
    "neovim"
    "zsh"
    "zsh-autosuggestions"
    "zsh-syntax-highlighting"
    "zsh-completions"
    "ripgrep"
    "git"
  ))
```

##### 3. Activate and update custom profile

The presented GUIX guide also instructs how to create a profile based on a manifest file. Taking the `development`
example previous presented (the inner folder with the same name is required):

```bash
mkdir -p $HOME/.guix-extra-profiles/development
guix package --manifest=development.scm --profile=$HOME/.guix-extra-profiles/development/development 
```

As any other workflow, this could be automatized, so I created (or practically steal it from
[benoitj](https://blog.benoitj.ca/) from System Crafters) a script that:

- Called without any arguments will search for all manifest files in `$HOME/.config/.guix/manifests` and activate a
  profile based on the file name, installing or updating all specified dependencies.
- Called with a any number of arguments, will try to find a manifest file, for each argument, at the same folder and
  activate the profile with the same name.
- Activating a profile means to create the folder, if it does not exist, and install ou update all specified
  applications to the latest known version to the system.

The script has also some colorful outputs of what it is doing.

```bash
#!/usr/bin/env bash

GREEN='\033[1;32m'
RED='\033[1;30m'
NC='\033[0m'

profiles=$*
if [[ $# -eq 0 ]]; then
    manifests="$HOME/.config/guix/manifests/*.scm";
    newProfiles=()
    for manifest in $manifests; do
        filename=$(basename $manifest)
        filename="${filename%.*}"
        newProfiles+=($filename)
    done
    profiles=${newProfiles[*]}
fi

echo
echo -e "${GREEN}Using profiles: "$profiles" ${NC}"
echo

for profile in $profiles; do
  profileName=$(basename $profile)
  profilePath="$GUIX_EXTRA_PROFILES/$profileName"
  manifestPath=$HOME/.config/guix/manifests/$profile.scm

  if [ -f $manifestPath ]; then
    echo
    echo -e "${GREEN}Activating profile:" $manifestPath "${NC}"
    echo

    mkdir -p $profilePath
    guix package --manifest=$manifestPath --profile="$profilePath/$profileName"

    # Source the new profile
    GUIX_PROFILE="$profilePath/$profileName"
    if [ -f $GUIX_PROFILE/etc/profile ]; then
        . "$GUIX_PROFILE"/etc/profile
    else
        echo -e "${RED}Couldn't find profile:" $GUIX_PROFILE/etc/profile "${NC}"
    fi
  else
    echo "No profile found at path" $profilePath
  fi
done

```


### Conclusions

With this approach I now have a functional guix setup, at least as package manager on any Linux distro, where I can
group packages in manifest files and reuse them as needed in different computers, and started using it already on my
work computer and remote development server.

Next step will be to include [home configuration](https://guix.gnu.org/manual/en/html_node/Home-Configuration.html) in
my setup and migrate at least some of my personal configurations to it.
