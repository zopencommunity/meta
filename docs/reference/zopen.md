# zopen

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
[*COMMAND*] [*OPTION*] [*PARAMETERS*]...

DESCRIPTION




zopen is a
utility for managing a zopen community environment.


**Command:**

<table width="100%" border="0" rules="none" frame="void"
       cellspacing="0" cellpadding="0">





alt




manage alternate versions of zopen community
packages 





audit




(beta) reports known vulnerabilities for the installed
packages 





build




builds the enclosing zopen community git-cloned
package 





clean




cleans up your zopen environment





config




change zopen runtime environment settings


diagnostics

collects system info for zopen
troubleshooting

generate

generates a new zopen
project

<table width="100%" border="0" rules="none" frame="void"
       cellspacing="0" cellpadding="0">





init




initializes a zopen environment at the specified
location 


refresh

refreshes your zopen
environment and zopen-config file

install

installs one or more zopen
community packages

<table width="100%" border="0" rules="none" frame="void"
       cellspacing="0" cellpadding="0">





info




displays detailed information about a package







list




lists information about zopen community packages




publish

publish zopen package release
to github

<table width="100%" border="0" rules="none" frame="void"
       cellspacing="0" cellpadding="0">





query




list local or remote info about zopen community
packages 





remove




removes installed zopen community packages


update-cacert

update the cacert.pem file used
by zopen community

upgrade

upgrades existing zopen
community packages

<table width="100%" border="0" rules="none" frame="void"
       cellspacing="0" cellpadding="0">





usage




output details about the file system usage for your
zopen environment


whichproject

determine the package a command
or library belongs to

OPTIONS





**-h**,
**--help**, -?

display this help and exit

**-v**,
**--verbose**

run in verbose mode

EXAMPLES




zopen
--help

displays zopen help

zopen --version

displays the installed zopen
version

zopen install
git install the latest version of the &rsquo;git&rsquo;
package zopen upgrade -y upgrade all installed
packages to the latest release,

without
prompting

zopen alt bash

list installed alternative bash
packages

zopen info vim

displays details information
about the installed vim package

zopen usage
--pie displays an ASCII-art chart showing
biggest space hogs

SEE
ALSO:

zopen-alt(1)
zopen-audit(1) zopen-build(1)
zopen-clean(1) zopen-config-helper(1)
zopen-generate(1) zopen-init(1)
zopen-install(1) zopen-info(1)
zopen-publish(1) zopen-query(1)
zopen-remove(1) zopen-update-cacert(1)
zopen-usage(1) zopen-whichproject(1)
zopen-version(1)

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
