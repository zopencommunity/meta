# zopen-install

# ZOPEN-INSTALL

[NAME](#NAME)

[SYNOPSIS](#SYNOPSIS)

[DESCRIPTION](#DESCRIPTION)

[OPTIONS](#OPTIONS)

[AUTHOR](#AUTHOR)


---



NAME




zopen-install
- manual page for zopen-install 0.8.4

SYNOPSIS





**zopen-install**
[*OPION*] [*PACKAGE*]

DESCRIPTION





zopen-install
is a utility to download/install a zopen community
package.

[PACKAGE] is a
package to install. Multiple packages can be specified.

OPTIONS




<table width="100%" border="0" rules="none" frame="void"
       cellspacing="0" cellpadding="0">





**--all**




download/install all zopen
community packages.





**--cache-only**

do not install
dependencies.


**--download-only**

download package to current
directory.

<table width="100%" border="0" rules="none" frame="void"
       cellspacing="0" cellpadding="0">





**--help**




print this help.





**--install-or-upgrade**

installs the package if not
installed, or upgrades the package if installed.


**--bypass-prereq-checks**

Ignores pre-req
checks


**--local-install**

download and unpackage to
current directory.


**--no-deps**

do not install
dependencies.


**--no-set-active**

do not change the pinned
version.


**--nosymlink**

do not integrate into
filesystem through symlink redirection.

**-r**,
**--reinstall**

reinstall already installed
zopen community packages.

<table width="100%" border="0" rules="none" frame="void"
       cellspacing="0" cellpadding="0">






**--release-line**
[stable, dev] the release line to build off of.


**--select**

select a version to
install.


**--skip-upgrade**

do not upgrade.

**--force**

force install, bypassing
locks.

**-u**,
**--update**,
**--upgrade**

updates installed zopen
community packages.

**-v**,
**--verbose**

print verbose messages.


**--version**

print version.

**-y**,
**--yes**

automatically answer yes to
prompts.

This is free
software: you are free to change and redistribute it under
the terms of the Apache License, Version 2.0.
&lt;https://www.apache.org/licenses/LICENSE-2.0.html&gt;
There is NO WARRANTY, to the extent permitted by law.

AUTHOR




Written by
contributors to the zopen community.
&lt;https://github.com/zopencommunity/meta/graphs/contributors&gt;
---
