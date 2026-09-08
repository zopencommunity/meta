<div v-pre class="man-page-content">
<h1 align="center">ZOPEN-VERSION</h1>

<h2>NAME</h2>

<p style="margin-left:11%; margin-top: 1em">zopen-version
&minus; manual page for zopen-version 0.8.4</p>

<h2>SYNOPSIS</h2>

<p style="margin-left:11%; margin-top: 1em">zopen
promote [OPTION] [DESTINATION]...</p>

<h2>DESCRIPTION</h2>

<p style="margin-left:11%; margin-top: 1em">zopen&minus;promote
is a utility for zopen community to generate a clone of an
existing zopen environment. For example, a user can install
to a test area, validate the behavior, and promote to a
production area.</p>

<h2>OPTIONS</h2>

<table border="1" cellpadding="10" cellspacing="0" style="width:100%; border-collapse:collapse;">
<tr style="background-color:#f0f0f0;">
<th style="text-align:left; border: 1px solid #ccc;">Option</th>
<th style="text-align:left; border: 1px solid #ccc;">Description</th>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>&minus;cp, &minus;&minus;configperms [PERMISSIONS]</code></td>
<td style="border: 1px solid #ccc;">Update the permissions for the configuration file &lt;promotedroot&gt;/etc/zopen&minus;config with the given [PERMISSIONS] string, specified in symbolic mode.</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>&minus;f, &minus;&minus;from</code></td>
<td style="border: 1px solid #ccc;">[DIRECTORY] The zopen environment to copy from; if not present, the default is taken from ZOPEN_ROOTFS (the current zopen environment).</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>&minus;g, &minus;&minus;group [GROUP]</code></td>
<td style="border: 1px solid #ccc;">Change group of promoted environment files from default.</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>&minus;h, &minus;?, &minus;&minus;help</code></td>
<td style="border: 1px solid #ccc;">Display this help and exit.</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>&minus;&minus;keepzopentooling</code></td>
<td style="border: 1px solid #ccc;">Install the zopen admin tools into the promoted environment for zopen system administration.</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>&minus;o, &minus;&minus;owner [OWNER]</code></td>
<td style="border: 1px solid #ccc;">Change owner of promoted environment files from current user.</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>&minus;v, &minus;&minus;verbose</code></td>
<td style="border: 1px solid #ccc;">Run in verbose mode.</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>&minus;&minus;version</code></td>
<td style="border: 1px solid #ccc;">Display version information.</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>&minus;y, &minus;&minus;yes</code></td>
<td style="border: 1px solid #ccc;">Automatically answer &rsquo;yes&rsquo; to prompts; existing target filesystems will be purged before promote occurs.</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>&minus;zp, &minus;&minus;zopenperms [PERMISSIONS]</code></td>
<td style="border: 1px solid #ccc;">Update the permissions for all files within the promoted zopen environment with the given [PERMISSIONS] string, specified in symbolic mode.</td>
</tr>
</table>

<h2>EXAMPLES</h2>

<table border="1" cellpadding="10" cellspacing="0" style="width:100%; border-collapse:collapse;">
<tr style="background-color:#f0f0f0;">
<th style="text-align:left; border: 1px solid #ccc;">Variable</th>
<th style="text-align:left; border: 1px solid #ccc;">Description</th>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>zopen promote</code></td>
<td style="border: 1px solid #ccc;">Interactively promote current zopen environment.</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>zopen promote /prod</code></td>
<td style="border: 1px solid #ccc;">Promote current zopen environment to &rsquo;/prod&rsquo;, setting file ownership to current user and group to default.</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>zopen promote /prod &minus;&minus;owner FOO</code></td>
<td style="border: 1px solid #ccc;">Promote current zopen environment to &rsquo;/prod&rsquo;, setting file ownership to &rsquo;FOO&rsquo; and group to default.</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>zopen promote /prod &minus;&minus;group BAR</code></td>
<td style="border: 1px solid #ccc;">Promote current zopen environment to &rsquo;/prod&rsquo;, setting file ownership to current user and group to &rsquo;BAR&rsquo;.</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>zopen promote /mytest &minus;cp g&minus;wx,o&minus;rwx &minus;zp g&minus;rwx,o&minus;rwx &minus;&minus;owner FOO</code></td>
<td style="border: 1px solid #ccc;">Promote current zopen environment to &rsquo;/mytest&rsquo;, allowing only the current user to source the zopen&minus;config environment file and only permit access to zopen environment files to the user &rsquo;FOO&rsquo;.</td>
</tr>
</table>

<h2>AUTHOR</h2>

<p style="margin-left:11%; margin-top: 1em">Written by
contributors to the zopen community.
<a href="https://github.com/zopencommunity/meta/graphs/contributors" target="_blank">https://github.com/zopencommunity/meta/graphs/contributors</a></p>

<h2>REPORTING BUGS</h2>

<p style="margin-left:11%; margin-top: 1em">Report bugs at
<a href="https://github.com/zopencommunity/meta/issues" target="_blank">https://github.com/zopencommunity/meta/issues</a></p>

<p style="margin-left:11%; margin-top: 1em">This is free
software: you are free to change and redistribute it under
the terms of the Apache License, Version 2.0.
<a href="https://www.apache.org/licenses/LICENSE-2.0.html" target="_blank">https://www.apache.org/licenses/LICENSE-2.0.html</a>
There is NO WARRANTY, to the extent permitted by law.</p>

</div>
