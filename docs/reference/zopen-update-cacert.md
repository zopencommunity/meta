# zopen-update-cacert

# ZOPEN-UPDATE-CACERT

[NAME](#NAME)

[DESCRIPTION](#DESCRIPTION)

[OPTIONS](#OPTIONS)

[AUTHOR](#AUTHOR)


---



NAME





zopen-update-cacert
- manual page for zopen-update-cacert 0.8.4

DESCRIPTION





zopen-update-cacert:
Update your cacert.pem file to the latest CA certificates
extracted from Mozilla.


**Syntax:**


zopen-update-cacert
[-fhv] [&lt;directory&gt;]

OPTIONS





**-f**,
**--force**

update cacert.pem file even if
up to date.

**-h**,
**--help**

print this help.

**-i**,
**--insecure-fallback**

(UNSAFE) Skip certificate
validation during download.

**-v**,
**--verbose**

print verbose messages.


**--version**

print version.


**Parameters:**

&lt;directory&gt;: the
directory where the cacert.pem will be updated.

The default
directory location is:
*/var/lib/jenkins/workspace/Port-Update-Nightly/meta_update*

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
