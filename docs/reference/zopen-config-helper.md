<div v-pre class="man-page-content">

<div class="header-with-back"><div class="link"><a href="./zopen-compute-builddeps">← Previous</a></div><div class='link'><a href='./zopen-create-cicd-job'>Next →</a></div></div>

<h1 align="center">ZOPEN-CONFIG-HELPER</h1>













<h2>NAME</h2>



<table><tr><td style="width: 25%; vertical-align: top;"><b>zopen-config-helper
- manual page for zopen-config-helper 0.8.5

<h2>SYNOPSIS</h2>



<b>zopen-config-helper</b>
[<i>OPTION</i>] [<i>KEY</i>]

<h2>DESCRIPTION</h2>



zopen-config-helper
is a utility for zopen community to change the zopen runtime
environment.

<h2>OPTIONS</h2>



<b>--delete</b></td><td style="vertical-align: top;">unset and remove the named KEY
property from the store</td></tr>
<tr><td style="width: 25%; vertical-align: top;"><b>--get</b></td><td style="vertical-align: top;">display the current value for the named KEY property or
the empty string if the property is not found/set</td></tr>
<tr valign="top" align="left">
<td width="9%"></td></tr>
<tr valign="top" align="left">
<td width="9%"></td>
<td width="8%"><b>--list</b></td>
<td width="1%"></td>
<td width="82%">list all current configuration values</td></tr>
<tr><td style="width: 25%; vertical-align: top;"><b>-?,
<b>--help</b></td><td style="vertical-align: top;">display this help</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>-v</b>,
<b>--verbose</b></td><td style="vertical-align: top;">run in verbose mode.</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>--version</b></td><td style="vertical-align: top;">print version.</td></tr></table>

<h2>EXAMPLES</h2>


<table><tr><td style="width: 25%; vertical-align: top;"><b>zopen config
--get autocacheclean</b></td><td style="vertical-align: top;">get the value for the
autocacheclean setting</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>zopen config --set
is_collecting_stats false</b></td><td style="vertical-align: top;">disable the is_collecting_stats
functionality</td></tr></table>

<h3>Notes:</h3>


<p style="margin-left:18%; margin-top: 1em">Configuration
options are not validated such that any key/value pairs can
be added into the global configuration. 3rd-party
utilities can store their global configuration into the
zopen runtime environment store and use the zopen config
tooling to set/retrieve values. Key names for stored
properties must conform to the following rules
[0-9a-zA-Z_]:</p>

<p style="margin-left:18%; margin-top: 1em">-
uppercase letters, A-Z - lowercase letters,
a-z - numeric digits, 0-9 -
underscore, '_'</p>

<p style="margin-left:18%; margin-top: 1em">The
non-relocatable global configuration file,
config.json, can be found at:</p>


<p style="margin-left:18%; margin-top: 1em">&lt;$ZOPEN_ROOTFS&gt;/etc/zopen/config.json</p>

<p style="margin-left:18%; margin-top: 1em">Manual editing
of this configuration file is not recommended and might
cause issues with the zopen environment if
misconfigured.</p>

<h2>AUTHOR</h2>


<p style="margin-left:9%; margin-top: 1em">Written by
contributors to the zopen community.
<a href="https://github.com/zopencommunity/meta/graphs/contributors" target="_blank">https://github.com/zopencommunity/meta/graphs/contributors</a></p>

<h2>REPORTING BUGS</h2>


<p style="margin-left:9%; margin-top: 1em">Report bugs at
https://github.com/zopencommunity/meta/issues.</p>

<p style="margin-left:9%; margin-top: 1em">This is free
software: you are free to change and redistribute it under
the terms of the Apache License, Version 2.0.
<a href="https://www.apache.org/licenses/LICENSE-2.0.html" target="_blank">https://www.apache.org/licenses/LICENSE-2.0.html</a>
<br>
There is NO WARRANTY, to the extent permitted by law.</p>

</div>
