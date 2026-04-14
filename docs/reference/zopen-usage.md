# zopen-usage

# ZOPEN-USAGE

[NAME](#NAME)

[SYNOPSIS](#SYNOPSIS)

[DESCRIPTION](#DESCRIPTION)

[OPTIONS](#OPTIONS)

[EXAMPLES](#EXAMPLES)

[AUTHOR](#AUTHOR)

[REPORTING BUGS](#REPORTING BUGS)


---



NAME




zopen-usage
- manual page for zopen-usage 0.8.4

SYNOPSIS





**zopen-usage**
[*OPTION*] [*ZOPEN_ROOTFS*]
[*PARAMETERS*]...

DESCRIPTION





zopen-usage
is a utility to display the file system usage by a zopen
environment

OPTIONS




<table width="100%" border="0" rules="none" frame="void"
       cellspacing="0" cellpadding="0">





**--pie**




generate a pie chart showing
space hogs




**-h**,
**--help**, -?

display this help and exit.

**-v**,
**--verbose**

run in verbose mode.


**--version**

print version

EXAMPLES




zopen usage

list the file system usage for
the environment

zopen usage --pie
/mnt/zopen

list the file system usage for
the zopen environment at the mount point /mnt/zopen


**Notes:**

Values might not add to 100%
due to rounding during calculations; use the reported values
as guidance, rounding up for capacity planning for
example.

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
