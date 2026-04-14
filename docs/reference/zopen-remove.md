# zopen-remove

# ZOPEN-REMOVE

[NAME](#NAME)

[SYNOPSIS](#SYNOPSIS)

[DESCRIPTION](#DESCRIPTION)

[OPTIONS](#OPTIONS)

[EXAMPLES](#EXAMPLES)

[AUTHOR](#AUTHOR)

[REPORTING BUGS](#REPORTING BUGS)


---



NAME




zopen-remove
- manual page for zopen-remove 0.8.4

SYNOPSIS





**zopen-remove**
[*OPTION*] [*PACKAGE*] ...

DESCRIPTION





zopen-remove
is a utility for zopen community to remove an installed
package or packages.

OPTIONS





**-h**,
**--help**, -?

display this help and exit.

**-p**,
**--purge**

remove package, the versioned
directory, and any cached files.

**-v**,
**--verbose**

run in verbose mode.


**--version**

print version.

**-y**,
**--yes**

automatically answer yes to
prompts.

EXAMPLES




zopen remove
foo bar

interactively remove the foo
and bar packages if installed

zopen remove --yes
foo bar

remove the foo and bar packages
if installed, without asking for confirmation

AUTHOR




Written by
contributors to the zopen community.
&lt;https://github.com/zopencommunity/meta/graphs/contributors&gt;

REPORTING BUGS




Report bugs at
https://github.com/zopencommunity/meta/issues .

This is free
software: you are free to change and redistribute it under
the terms of the Apache License, Version 2.0.
&lt;https://www.apache.org/licenses/LICENSE-2.0.html&gt;


There is NO WARRANTY, to the extent permitted by law.
---
