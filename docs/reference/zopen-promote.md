# zopen-promote

# ZOPEN-VERSION

[NAME](#NAME)

[SYNOPSIS](#SYNOPSIS)

[DESCRIPTION](#DESCRIPTION)

[OPTIONS](#OPTIONS)

[EXAMPLES](#EXAMPLES)

[AUTHOR](#AUTHOR)

[REPORTING BUGS](#REPORTING BUGS)


---



NAME




zopen-version
- manual page for zopen-version 0.8.4

SYNOPSIS




**zopen**
*promote* [*OPTION*] [*DESTINATION*]...

DESCRIPTION





zopen-promote
is a utility for zopen community to generate a clone of an
existing zopen environment. For example, a user can install
to a test area, validate the behavior, and promote to a
production area.

OPTIONS





**-cp**,
**--configperms** [PERMISSIONS]

Update the permissions for the
configuration file
&lt;promotedroot&gt;/etc/zopen-config with the given
[PERMISSIONS] string, specified in symbolic mode.

**-f**,
**--from**

[DIRECTORY] The zopen
environment to copy from; if not present, the default is
taken from ZOPEN_ROOTFS (the current zopen environment).

**-g**,
**--group** [GROUP]

Change group of promoted
environment files from default.

**-h**, -?,
**--help**

Display this help and exit.


**--keepzopentooling**

Install the zopen admin tools
into the promoted environment for zopen system
administration.

**-o**,
**--owner** [OWNER]

Change owner of promoted
environment files from current user.

**-v**,
**--verbose**

Run in verbose mode.


**--version**

Display version
information.

**-y**,
**--yes**

Automatically answer
&rsquo;yes&rsquo; to prompts; existing target filesystems
will be purged before promote occurs.

**-zp**,
**--zopenperms** [PERMISSIONS]

Update the permissions for all
files within the promoted zopen environment with the given
[PERMISSIONS] string, specified in symbolic mode.

EXAMPLES




zopen
promote

Interactively promote current
zopen environment.

zopen promote /prod

Promote current zopen
environment to &rsquo;/prod&rsquo;, setting file ownership
to current user and group to default.

zopen promote /prod
--owner FOO

Promote current zopen
environment to &rsquo;/prod&rsquo;, setting file ownership
to &rsquo;FOO&rsquo; and group to default.

zopen promote /prod
--group BAR

Promote current zopen
environment to &rsquo;/prod&rsquo;, setting file ownership
to current user and group to &rsquo;BAR&rsquo;.

zopen promote /mytest -cp
g-wx,o-rwx -zp g-rwx,o-rwx
--owner FOO

Promote current zopen
environment to &rsquo;/mytest&rsquo;, allowing only the
current user to source the zopen-config environment
file and only permit access to zopen environment files to
the user &rsquo;FOO&rsquo;.

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
