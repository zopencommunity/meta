# zopen-generate

# ZOPEN-GENERATE

[NAME](#NAME)

[DESCRIPTION](#DESCRIPTION)

[OPTIONS](#OPTIONS)

[AUTHOR](#AUTHOR)


---



NAME




zopen-generate
- manual page for zopen-generate 0.8.4

DESCRIPTION





zopen-generate
will generate a zopen compatible project Syntax:
zopen-generate [options]

OPTIONS




<table width="100%" border="0" rules="none" frame="void"
       cellspacing="0" cellpadding="0">





**--help**




Display this help message





**--version**

Display version information


**--list-licenses**

List available licenses


**--list-categories**

List available categories


**--list-build-systems**

List supported build
systems

**--name**
NAME

Project name


**--description**
DESC

Project description


**--categories**
CATS

Project categories
(space-delimited)

**--license**
LICENSE

License name

**--type**
TYPE

Port type: &rsquo;BUILD&rsquo;
(from source) or &rsquo;BARE&rsquo; (binary download)


**--build-system**
SYSTEM

Build system if type is BUILD
(GNU Make, CMake, Gradle, Maven, etc.)


**--stable-url**
URL

Stable release source URL


**--stable-deps**
DEPS

Stable build dependencies
(space-delimited)


**--dev-url**
URL

Dev-line source URL


**--dev-deps**
DEPS

Dev build dependencies
(space-delimited)


**--build-line**
LINE

Default build line (stable or
dev)


**--runtime-deps**
DEPS

Runtime dependencies
(space-delimited)

**--force**

Force update if project
directory exists


**--non-interactive**

Run in non-interactive
mode (requires all necessary options)

<table width="100%" border="0" rules="none" frame="void"
       cellspacing="0" cellpadding="0">





**--json**




Display list output in JSON format




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
