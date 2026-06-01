<div v-pre class="man-page-content">

<div class="header-with-back"><div class="link" style="float: left;"><a href="./zopen-clean">← Previous</a></div><div class='link' style='float: right;'><a href='./zopen-create-cicd-job'>Next →</a></div><div style="clear: both;"></div></div>


<h1 align="center">ZOPEN-CONFIG-HELPER</h1>




<h2>NAME</h2>



<p style="margin-left:6%; margin-top: 1em">zopen-config-helper
- manual page for zopen-config-helper 0.8.5</p>

<h2>SYNOPSIS</h2>



<p style="margin-left:6%; margin-top: 1em">zopen-config-helper
[OPTION] [KEY]</p>

<h2>DESCRIPTION</h2>



<p style="margin-left:6%; margin-top: 1em">zopen-config-helper
is a utility for zopen community to change the zopen runtime
environment.</p>

<h2>OPTIONS</h2>



<p style="margin-left:6%; margin-top: 1em">--delete</p>

<p style="margin-left:15%;">unset and remove the named KEY
property from the store</p>


<table width="100%" border="0" rules="none" frame="void"
       cellspacing="0" cellpadding="0">

<tr valign="top" align="left">

<td width="6%"></td>


<td width="7%">


<p>--get</p></td>


<td width="2%"></td>


<td width="85%">


<p>display the current value for the named KEY property or
the empty string if the property is not found/set</p></td>
</tr>


<tr valign="top" align="left">

<td width="6%"></td>


<td width="7%">


<p style="margin-top: 1em">--set</p></td>


<td width="2%"></td>


<td width="85%">


<p style="margin-top: 1em">set the configuration value for
the named KEY property</p></td>
</tr>

</table>


<p style="margin-left:6%;">--list</p>

<p style="margin-left:15%;">list all current configuration
values</p>

<p style="margin-left:6%;">-?, --help</p>

<p style="margin-left:15%;">display this help</p>

<p style="margin-left:6%;">-v, --verbose</p>

<p style="margin-left:15%;">run in verbose mode.</p>

<p style="margin-left:6%;">--version</p>

<p style="margin-left:15%;">print version.</p>

<h2>EXAMPLES</h2>


<p style="margin-left:6%; margin-top: 1em">zopen config
--get autocacheclean</p>

<p style="margin-left:15%;">get the value for the
autocacheclean setting</p>

<p style="margin-left:6%;">zopen config --set
is_collecting_stats false</p>

<p style="margin-left:15%;">disable the is_collecting_stats
functionality</p>

<h3>Notes:</h3>


<p style="margin-left:15%; margin-top: 1em">Configuration
options are not validated such that any key/value pairs can
be added into the global configuration. 3rd-party utilities
can store their global configuration into the zopen runtime
environment store and use the zopen config tooling to
set/retrieve values. Key names for stored properties must
conform to the following rules [0-9a-zA-Z_]:</p>

<p style="margin-left:15%; margin-top: 1em">- uppercase
letters, A-Z - lowercase letters, a-z - numeric digits, 0-9
- underscore, '_'</p>

<p style="margin-left:15%; margin-top: 1em">The
non-relocatable global configuration file, config.json, can
be found at:</p>


<p style="margin-left:15%; margin-top: 1em">&lt;$ZOPEN_ROOTFS&gt;/etc/zopen/config.json</p>

<p style="margin-left:15%; margin-top: 1em">Manual editing
of this configuration file is not recommended and might
cause issues with the zopen environment if
misconfigured.</p>

<h2>AUTHOR</h2>


<p style="margin-left:6%; margin-top: 1em">Written by
contributors to the zopen community.
<a href="https://github.com/zopencommunity/meta/graphs/contributors" target="_blank">https://github.com/zopencommunity/meta/graphs/contributors</a></p>

<h2>REPORTING BUGS</h2>


<p style="margin-left:6%; margin-top: 1em">Report bugs at
https://github.com/zopencommunity/meta/issues.</p>

<p style="margin-left:6%; margin-top: 1em">This is free
software: you are free to change and redistribute it under
the terms of the Apache License, Version 2.0.
<a href="https://www.apache.org/licenses/LICENSE-2.0.html" target="_blank">https://www.apache.org/licenses/LICENSE-2.0.html</a>
There is NO WARRANTY, to the extent permitted by law.</p>

</div>
