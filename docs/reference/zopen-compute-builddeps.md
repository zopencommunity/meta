# zopen-compute-builddeps

# ZOPEN-COMPUTE-BUILDDEPS

[NAME](#NAME)

[SYNOPSIS](#SYNOPSIS)

[DESCRIPTION](#DESCRIPTION)

[OPTIONS](#OPTIONS)

[EXAMPLES](#EXAMPLES)

[AUTHOR](#AUTHOR)


---



NAME





zopen-compute-builddeps
- manual page for zopen-compute-builddeps 0.8.4

SYNOPSIS





**zopen-compute-builddeps**
[*OPTION*] [*tool*]

DESCRIPTION





zopen-compute-builddeps
- print out build dependencies (transitive closure)
for a given tool.

NOTE: This tool
will clone several repositories into a temporary directory
for this computation.

OPTIONS




<table width="100%" border="0" rules="none" frame="void"
       cellspacing="0" cellpadding="0">





**--help**




display this help and exit.





**--version**

print version.

EXAMPLES




Print out the
tools required to build git.


zopen-compute-builddeps
git

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
