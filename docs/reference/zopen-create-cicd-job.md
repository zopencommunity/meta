# zopen-create-cicd-job

# ZOPEN-CREATE-CICD-JOB

[NAME](#NAME)

[SYNOPSIS](#SYNOPSIS)

[DESCRIPTION](#DESCRIPTION)

[OPTIONS](#OPTIONS)

[AUTHOR](#AUTHOR)


---



NAME





zopen-create-cicd-job
- manual page for zopen-create-cicd-job 0.8.4

SYNOPSIS





**zopen-create-cicd-job**
[*OPTION*] *-n PORT_NAME*

DESCRIPTION





zopen-create-cicd-job
- Create a Jenkins CI/CD job for a port.

NOTE: This
script is intended for use by core contributors only.

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
e.g., curl, openssl (without &rsquo;port&rsquo; suffix)

**-b**,
**--build-type** TYPE

Build type: stable or dev
(default: stable)

**-s**,
**--script** SCRIPT

Groovy script path in repo
(default: cicd-stable.groovy)

**-r**,
**--run-after** RUN

Trigger job after creation: yes
or no (default: yes)


**--version**

print version


**Example:**


zopen-create-cicd-job
**-n** curl zopen-create-cicd-job
**-v -n** pv **-b** dev
**-r** no zopen-create-cicd-job
**-n** openssl **-b** stable
**-s** cicd-stable.groovy

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
