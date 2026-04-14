# zopen-clean

# ZOPEN-CLEAN

[NAME](#NAME)

[SYNOPSIS](#SYNOPSIS)

[DESCRIPTION](#DESCRIPTION)

[OPTIONS](#OPTIONS)

[EXAMPLES](#EXAMPLES)

[AUTHOR](#AUTHOR)

[REPORTING BUGS](#REPORTING BUGS)


---



NAME




zopen-clean
- manual page for zopen-clean 0.8.4

SYNOPSIS





**zopen-clean**
[*OPTION*] [*PACKAGE*]

DESCRIPTION





zopen-clean
is a utility for zopen community to remove uneeded resources
from the system to save space and prevent clutter.

OPTIONS




<table width="100%" border="0" rules="none" frame="void"
       cellspacing="0" cellpadding="0">





**--deep**




deep clean - run all
cleanup operations







**--all**




apply cleanup command to all applicable packages.




**-c**,
**--cache**

[PACKAGE ...] cleans the
downloaded package cache; packages will be
re-downloaded if needed.

**-d**,
**--dangling**

removes dangling symlinks from
the zopen file system in case of issues during package
maintenance.

**-h**,
**--help**, -?

display this help and exit.

**-m**,
**--metadata**

cleans and refreshes the
metadata for zopen.

**-u**,
**--unused** [PACKAGE ...]

remove versions of PACKAGEs
that are available as alternatives, leaving only the
currently active version.


**--nostats**

do not output statistics from
the clean operation(s)

**-v**,
**--verbose**

run in verbose mode.


**--version**

print version.

EXAMPLES




zopen clean
-c

clear the package download
cache

zopen clean -d

analyse the zopen file system
and remove dangling symlinks

zopen clean -u
[PACKAGE]

remove unused versions for
PACKAGE

zopen clean -u
--all

remove all unused packages
within the zopen environment

zopen clean
--deep

AUTHOR




Written by
contributors to the zopen community.
&lt;https://github.com/zopencommunity/meta/graphs/contributors&gt;

REPORTING BUGS




Report bugs at
https://github.com/zopencommunity/meta/issues.

This is free
software: you are free to change and redistribute it under
the terms of the Apache License, Version 2.0.
&lt;https://www.apache.org/licenses/LICENSE-2.0.html&gt;


There is NO WARRANTY, to the extent permitted by law.
---
