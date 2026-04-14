# zopen-config-helper

# ZOPEN-CONFIG-HELPER

[NAME](#NAME)

[SYNOPSIS](#SYNOPSIS)

[DESCRIPTION](#DESCRIPTION)

[OPTIONS](#OPTIONS)

[EXAMPLES](#EXAMPLES)

[AUTHOR](#AUTHOR)

[REPORTING BUGS](#REPORTING BUGS)


---



NAME





zopen-config-helper
- manual page for zopen-config-helper 0.8.4

SYNOPSIS





**zopen-config-helper**
[*OPTION*] [*KEY*]

DESCRIPTION





zopen-config-helper
is a utility for zopen community to change the zopen runtime
environment.

OPTIONS





**--delete**

unset and remove the named KEY
property from the store






**--get**




display the current value for the named KEY property or
the empty string if the property is not found/set





**--set**




set the configuration value for the named KEY
property 





**--list**




list all current configuration values


-?,
**--help**

display this help

**-v**,
**--verbose**

run in verbose mode.


**--version**

print version.

EXAMPLES




zopen config
--get autocacheclean

get the value for the
autocacheclean setting

zopen config --set
is_collecting_stats false

disable the is_collecting_stats
functionality


**Notes:**

Configuration options are not
validated such that any key/value pairs can be added into
the global configuration. 3rd-party utilities can
store their global configuration into the zopen runtime
environment store and use the zopen config tooling to
set/retrieve values. Key names for stored properties must
conform to the following rules
[0-9a-zA-Z_]:

-
uppercase letters, A-Z - lowercase letters,
a-z - numeric digits, 0-9 -
underscore, '_'

The
non-relocatable global configuration file,
config.json, can be found at:


&lt;$ZOPEN_ROOTFS&gt;/etc/zopen/config.json

Manual editing
of this configuration file is not recommended and might
cause issues with the zopen environment if
misconfigured.

AUTHOR




Written by
contributors to the zopen community.
&lt;https://github.com/zopencommunity/meta/graphs/contributors&gt;

REPORTING BUGS




Report bugs at
https://github.com/zopencommunity/meta/issues.

This is free
software: you are free to change and redistribute it under
the terms of the Apache License, Version 2.0.
&lt;https://www.apache.org/licenses/LICENSE-2.0.html&gt;


There is NO WARRANTY, to the extent permitted by law.
---
