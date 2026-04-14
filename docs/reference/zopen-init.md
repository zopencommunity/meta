# zopen-init

# ZOPEN-INIT

[NAME](#NAME)

[SYNOPSIS](#SYNOPSIS)

[DESCRIPTION](#DESCRIPTION)

[OPTIONS](#OPTIONS)

[EXAMPLES](#EXAMPLES)

[AUTHOR](#AUTHOR)

[REPORTING BUGS](#REPORTING BUGS)


---



NAME




zopen-init
- manual page for zopen-init 0.8.4

SYNOPSIS




**zopen**
*init* [*OPTION*] [*PARAMETERS*]...

DESCRIPTION




zopen init is a
utility for zopen community to generate a zopen environment,
bootstrapping initial tools and creating a configuration
file

OPTIONS










**--append-to-profile** 




appends
sourcing of zopen-config to current user's
.profile







**--[no]enable-stats** 




Toggle enabling
collection of usage statistics







**--[no]override-zos-tools** 




Toggle default
mode for overriding z/OS */bin* tools in the
zopen-config. Default is
**--nooverride-zos-tools**







**--bypass-prereq-checks** 




Bypasses
pre-requisite checks






**-f**,
**--fs-layout** &lt;LAYOUT&gt;




The filesystem
structure to use for installed packages on disk; packages
will be installed to this location under &lt;zopen
rootfs&gt;.

&lt;LAYOUT&gt;
should be one of:

usrlclz:
*/usr/local/zopen* (default), zopen: */usr/zopen*,
prod: legacy zopen standard location, ibm: */usr/lpp*,
fhs: File Hierarchical Standard (*/opt*), usrlcl:
usr/local






**-h**, -?,
**--help** 




display this
help and exit







**--re-init** 





Re-initializes
a previous zopen environment or create a new environment
using current tooling. Re-initializing over a previous
installation will re-use existing package structures
and configuration and regenerate configuration files. select
the active version for PACKAGE from a list







**--refresh** 




Refreshes the
zopen-config file







**--releaseline-dev** 




globally
configure the release line for package installs to enable
Development (DEV) packages; the default is for a system to
use STABLE packages






**-v**,
**--verbose** 




run in verbose
mode






**-y**,
**--yes** 




automatically
answer 'yes' to prompts

EXAMPLES




zopen init

interactively
bootstrap a zopen environment

zopen init
--releaseline-dev

interactively
bootstrap a zopen environment that will use Development
Releaseline packages

zopen init
--yes
--append-to-profile
--fs-layout fhs /zopen


non-interactively
create a zopen environment at location '/zopen'
on disk, with packages installed to
'/zopen/opt'. The user's .profile will be
updated to source the configuration file at
'/zopen/etc/zopen-config' when new
terminal sessions start

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
