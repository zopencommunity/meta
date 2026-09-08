<div v-pre class="man-page-content">
<h1 align="center">ZOPEN-CONFIG-HELPER</h1>

<h2>NAME</h2>

<p style="margin-left:11%; margin-top: 1em">zopen-config-helper
&minus; manual page for zopen-config-helper 0.8.4</p>

<h2>SYNOPSIS</h2>

<p style="margin-left:11%; margin-top: 1em">zopen-config-helper
[OPTION] [KEY]</p>

<h2>DESCRIPTION</h2>

<p style="margin-left:11%; margin-top: 1em">zopen&minus;config&minus;helper
is a utility for zopen community to change the zopen runtime environment.</p>

<h2>OPTIONS</h2>

<table border="1" cellpadding="10" cellspacing="0" style="width:100%; border-collapse:collapse;">
<tr style="background-color:#f0f0f0;">
<th style="text-align:left; border: 1px solid #ccc;">Option</th>
<th style="text-align:left; border: 1px solid #ccc;">Description</th>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>&minus;&minus;delete</code></td>
<td style="border: 1px solid #ccc;">unset and remove the named KEY property from the store.</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>&minus;&minus;get</code></td>
<td style="border: 1px solid #ccc;">display the current value for the named KEY property or the empty string if the property is not found/set.</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>&minus;&minus;set</code></td>
<td style="border: 1px solid #ccc;">set the configuration value for the named KEY property.</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>&minus;&minus;list</code></td>
<td style="border: 1px solid #ccc;">list all current configuration values.</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>&minus;?, &minus;&minus;help</code></td>
<td style="border: 1px solid #ccc;">display this help.</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>&minus;v, &minus;&minus;verbose</code></td>
<td style="border: 1px solid #ccc;">run in verbose mode.</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>&minus;&minus;version</code></td>
<td style="border: 1px solid #ccc;">print version.</td>
</tr>
</table>

<h2>EXAMPLES</h2>

<table border="1" cellpadding="10" cellspacing="0" style="width:100%; border-collapse:collapse;">
<tr style="background-color:#f0f0f0;">
<th style="text-align:left; border: 1px solid #ccc;">Command</th>
<th style="text-align:left; border: 1px solid #ccc;">Description</th>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>zopen config &minus;&minus;get autocacheclean</code></td>
<td style="border: 1px solid #ccc;">get the value for the autocacheclean setting</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>zopen config &minus;&minus;set is_collecting_stats false</code></td>
<td style="border: 1px solid #ccc;">disable the is_collecting_stats functionality</td>
</tr>
</table>

<p style="margin-left:11%; margin-top: 1em">Notes: Configuration options are not validated such that any key/value pairs can be added into the global configuration. 3rd&minus;party utilities can store their global configuration into the zopen runtime environment store and use the zopen config tooling to set/retrieve values. Key names for stored properties must conform to the following rules [0&minus;9a&minus;zA&minus;Z_]: uppercase letters A&minus;Z, lowercase letters a&minus;z, numeric digits 0&minus;9, underscore &rsquo;_&rsquo;.</p>

<p style="margin-left:11%; margin-top: 1em">The non&minus;relocatable global configuration file, config.json, can be found at: <code>&lt;$ZOPEN_ROOTFS&gt;/etc/zopen/config.json</code>. Manual editing of this configuration file is not recommended and might cause issues with the zopen environment if misconfigured.</p>

<h2>AUTHOR</h2>

<p style="margin-left:11%; margin-top: 1em">Written by
contributors to the zopen community.
<a href="https://github.com/zopencommunity/meta/graphs/contributors" target="_blank">https://github.com/zopencommunity/meta/graphs/contributors</a></p>

<h2>REPORTING BUGS</h2>

<p style="margin-left:11%; margin-top: 1em">Report bugs at
<a href="https://github.com/zopencommunity/meta/issues." target="_blank">https://github.com/zopencommunity/meta/issues.</a></p>

<p style="margin-left:11%; margin-top: 1em">This is free
software: you are free to change and redistribute it under
the terms of the Apache License, Version 2.0.
<a href="https://www.apache.org/licenses/LICENSE-2.0.html" target="_blank">https://www.apache.org/licenses/LICENSE-2.0.html</a>
There is NO WARRANTY, to the extent permitted by law.</p>

</div>
