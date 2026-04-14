# zopen-alt

# ZOPEN-ALT

[NAME](#NAME)

[SYNOPSIS](#SYNOPSIS)

[DESCRIPTION](#DESCRIPTION)

[OPTIONS](#OPTIONS)

[EXAMPLES](#EXAMPLES)

[AUTHOR](#AUTHOR)

[REPORTING BUGS](#REPORTING BUGS)


---



NAME




zopen-alt
- manual page for zopen-alt 0.8.4

SYNOPSIS





**zopen-alt**
[*OPTION*] [*PACKAGE*] [*PARAMETERS*]...

DESCRIPTION





zopen-alt
is a utility for zopen community to switch package versions
for currently installed packages.

OPTIONS





**-h**,
**--help**, -?

display this help and exit.

**--select**
[PACKAGE]

select the active version for
PACKAGE from a list.

**-s**,
**--set** [PACKAGE] [VERSION]

set the active version for
PACKAGE to VERSION.

**-v**,
**--verbose**

run in verbose mode.


**--version**

print version

EXAMPLES




zopen alt
foo

list the available alternatives
for package &rsquo;foo&rsquo;

zopen alt --select
foo

list the available alternatives
for package &rsquo;foo&rsquo; and allow the user to select
an alternative version

zopen alt --set foo
foo-1.2.3.19700101_012345.zos

set the active version of
package &rsquo;foo&rsquo; to version
foo-1.2.3.19700101_012345.zos if available

AUTHOR




Written by
contributors to the zopen community.
&lt;https://github.com/zopencommunity/meta/graphs/contributors&gt;

REPORTING BUGS




Report bugs at
https://github.com/zopencommunity/meta/issues

This is free
software: you are free to change and redistribute it under
the terms of the Apache License, Version 2.0.
&lt;https://www.apache.org/licenses/LICENSE-2.0.html&gt;


There is NO WARRANTY, to the extent permitted by law.
---
