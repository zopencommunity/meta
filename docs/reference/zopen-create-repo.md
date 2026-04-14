# zopen-create-repo

# ZOPEN-CREATE-REPO

[NAME](#NAME)

[SYNOPSIS](#SYNOPSIS)

[DESCRIPTION](#DESCRIPTION)

[OPTIONS](#OPTIONS)

[AUTHOR](#AUTHOR)


---



NAME





zopen-create-repo
- manual page for zopen-create-repo 0.8.4

SYNOPSIS





**zopen-create-repo**
[*OPTION*] *-n PORT_NAME*

DESCRIPTION





zopen-create-repo
- Create a new port repository in zopencommunity.

NOTE: This
script is intended for use by core contributors only.

You must have
admin permissions in the zopencommunity organization.

OPTIONS





**-h**,
**--help**

print this help

**-v**,
**--verbose**

run in verbose mode.

**-n**,
**--name** PORT_NAME

Name of the port (required)
e.g., curl, openssl

**-d**,
**--description** TEXT

Repository description
(optional) Default: &rsquo;zopen port of
PORT_NAME&rsquo;

**-u**,
**--user** USERNAME

GitHub username to assign as
admin (optional)

**-o**,
**--github-org** ORG

GitHub Organization (default:
zopencommunity)

**-t**,
**--github-token** TOKEN

GitHub Personal Access Token
(required, or set GITHUB_TOKEN env var)


**--version**

print version

Environment
Variables: 

GITHUB_TOKEN

GitHub Personal Access Token
(alternative to **--github-token**)


**Example:**

zopen-create-repo
**-n** curl zopen-create-repo
**-v -n** pv **-d** &rsquo;Pipe
Viewer - monitor data through a pipeline&rsquo;
zopen-create-repo **-v -n**
openssl **-u** johndoe **-t**
&lt;your_github_token&gt;

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
