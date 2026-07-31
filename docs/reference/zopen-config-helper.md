<div v-pre class="man-page-content">

<div class="header-with-back">
<div class="back-link">
<a href="./zopen-reference">← Back</a>
</div>
</div>

<h1 align="center">ZOPEN-CONFIG-HELPER</h1>

<hr />

<h2>
NAME
</h2>

<p style="margin-left: 11%; margin-top: 1em">
zopen-config-helper &minus; manual page for zopen-config-helper 0.8.4
</p>

<h2>
SYNOPSIS
</h2>

<p style="margin-left: 11%; margin-top: 1em">
zopen-config-helper [OPTION] [KEY]
</p>

<h2>
DESCRIPTION
</h2>

<p style="margin-left: 11%; margin-top: 1em">
zopen&minus;config&minus;helper is a utility for zopen community to change
the zopen runtime environment.
</p>

<h2>
OPTIONS
</h2>

<p style="margin-left: 11%; margin-top: 1em">&minus;&minus;delete</p>

<p style="margin-left: 22%">
unset and remove the named KEY property from the store
</p>

<table width="100%" border="0" rules="none" frame="void" cellspacing="0" cellpadding="0">

<tr valign="top" align="left">

<td width="9%"></td>

<td width="11%">
<p>&minus;&minus;get</p>
</td>

<td width="2%"></td>

<td width="78%">
<p>
display the current value for the named KEY property or the empty
string if the property is not found/set
</p>
</td>

</tr>

<tr valign="top" align="left">

<td width="9%"></td>

<td width="11%">
<p>&minus;&minus;set</p>
</td>

<td width="2%"></td>

<td width="78%">
<p>set the configuration value for the named KEY property</p>
</td>

</tr>

<tr valign="top" align="left">

<td width="9%"></td>

<td width="11%">
<p>&minus;&minus;list</p>
</td>

<td width="2%"></td>

<td width="78%">
<p>list all current configuration values</p>
</td>

</tr>

</table>

<p style="margin-left: 11%">&minus;?, &minus;&minus;help</p>

<p style="margin-left: 22%">display this help</p>

<p style="margin-left: 11%">
&minus;v, &minus;&minus;verbose
</p>

<p style="margin-left: 22%">run in verbose mode.</p>

<p style="margin-left: 11%">&minus;&minus;version</p>

<p style="margin-left: 22%">print version.</p>

<h2>
EXAMPLES
</h2>

<p style="margin-left: 11%; margin-top: 1em">
zopen config &minus;&minus;get autocacheclean
</p>

<p style="margin-left: 22%">get the value for the autocacheclean setting</p>

<p style="margin-left: 11%">
zopen config &minus;&minus;set is_collecting_stats false
</p>

<p style="margin-left: 22%">
disable the is_collecting_stats functionality
</p>

<p style="margin-left: 11%; margin-top: 1em">Notes:</p>

<p style="margin-left: 22%">
Configuration options are not validated such that any key/value pairs can
be added into the global configuration. 3rd&minus;party utilities can
store their global configuration into the zopen runtime environment store
and use the zopen config tooling to set/retrieve values. Key names for
stored properties must conform to the following rules
[0&minus;9a&minus;zA&minus;Z_]:
</p>

<p style="margin-left: 22%; margin-top: 1em">
&minus; uppercase letters, A&minus;Z &minus; lowercase letters, a&minus;z
&minus; numeric digits, 0&minus;9 &minus; underscore, &rsquo;_&rsquo;
</p>

<p style="margin-left: 22%; margin-top: 1em">
The non&minus;relocatable global configuration file, config.json, can be
found at:
</p>

<p style="margin-left: 22%; margin-top: 1em">
&lt;$ZOPEN_ROOTFS&gt;/etc/zopen/config.json
</p>

<p style="margin-left: 22%; margin-top: 1em">
Manual editing of this configuration file is not recommended and might
cause issues with the zopen environment if misconfigured.
</p>

<h2>
AUTHOR
</h2>

<p style="margin-left: 11%; margin-top: 1em">
Written by contributors to the zopen community.
<a href="https://github.com/zopencommunity/meta/graphs/contributors" target="_blank">https://github.com/zopencommunity/meta/graphs/contributors</a>
</p>

<h2>
REPORTING BUGS
</h2>

<p style="margin-left: 11%; margin-top: 1em">
Report bugs at <a href="https://github.com/zopencommunity/meta/issues." target="_blank">https://github.com/zopencommunity/meta/issues.</a>
</p>

<p style="margin-left: 11%; margin-top: 1em">
This is free software: you are free to change and redistribute it under
the terms of the Apache License, Version 2.0.
&lt;<a href="https://www.apache.org/licenses/LICENSE" target="_blank">https://www.apache.org/licenses/LICENSE</a>&minus;2.0.html&gt;
<br />
There is NO WARRANTY, to the extent permitted by law.
</p>
<hr />

</div>
