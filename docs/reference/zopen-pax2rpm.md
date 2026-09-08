<div v-pre class="man-page-content">
<h1 align="center">ZOPEN-PAX2RPM</h1>

<h2>NAME</h2>

<p style="margin-left:11%; margin-top: 1em">zopen-pax2rpm
&minus; manual page for zopen-pax2rpm 0.8.4</p>

<h2>SYNOPSIS</h2>

<p style="margin-left:11%; margin-top: 1em"><b>zopen-pax2rpm</b>
&lt;pax_file&gt; [options]</p>

<h2>DESCRIPTION</h2>

<p style="margin-left:11%; margin-top: 1em">Generate an RPM spec file from a z/OS pax archive.</p>

<p style="margin-left:11%; margin-top: 1em"><b>Arguments:</b> pax_file &mdash; Path to the pax file (e.g., /path/to/file.pax or file.pax.Z)</p>

<h2>OPTIONS</h2>

<table border="1" cellpadding="10" cellspacing="0" style="width:100%; border-collapse:collapse;">
<tr style="background-color:#f0f0f0;">
<th style="text-align:left; border: 1px solid #ccc;">Option</th>
<th style="text-align:left; border: 1px solid #ccc;">Description</th>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code><b>&minus;&minus;name</b> &lt;name&gt;</code></td>
<td style="border: 1px solid #ccc;">override package name (default: extracted from filename)</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code><b>&minus;&minus;version</b> &lt;version&gt;</code></td>
<td style="border: 1px solid #ccc;">override version (default: extracted from filename)</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code><b>&minus;&minus;pkg&minus;version</b> &lt;version&gt;</code></td>
<td style="border: 1px solid #ccc;">override version (alternative to <b>&minus;&minus;version</b>)</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code><b>&minus;&minus;release</b> &lt;release&gt;</code></td>
<td style="border: 1px solid #ccc;">override release number (default: 1)</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code><b>&minus;&minus;license</b> &lt;license&gt;</code></td>
<td style="border: 1px solid #ccc;">specify license (default: Proprietary)</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code><b>&minus;&minus;summary</b> &lt;summary&gt;</code></td>
<td style="border: 1px solid #ccc;">package summary (required)</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code><b>&minus;&minus;description</b> &lt;desc&gt;</code></td>
<td style="border: 1px solid #ccc;">package description (default: same as summary)</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code><b>&minus;&minus;url</b> &lt;url&gt;</code></td>
<td style="border: 1px solid #ccc;">project URL (default: none)</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code><b>&minus;&minus;requires</b> &lt;deps&gt;</code></td>
<td style="border: 1px solid #ccc;">package dependencies (e.g., &quot;oef &gt;= 1.1.0&quot;)</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code><b>&minus;&minus;output</b> &lt;file&gt;</code></td>
<td style="border: 1px solid #ccc;">output spec file (default: &lt;name&gt;.spec)</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code><b>&minus;&minus;build</b></code></td>
<td style="border: 1px solid #ccc;">build the RPM after generating spec file</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code><b>&minus;&minus;buildroot</b> &lt;dir&gt;</code></td>
<td style="border: 1px solid #ccc;">RPM build root directory (default: ~/rpmbuild)</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code><b>&minus;&minus;validate</b></code></td>
<td style="border: 1px solid #ccc;">validate spec file after generation (checks syntax and runs rpmlint)</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code><b>&minus;&minus;dry&minus;run</b></code></td>
<td style="border: 1px solid #ccc;">show what would be done without actually doing it</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code><b>&minus;&minus;verbose</b></code></td>
<td style="border: 1px solid #ccc;">enable verbose debug output</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code><b>&minus;&minus;help</b></code></td>
<td style="border: 1px solid #ccc;">display this help message</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code><b>&minus;&minus;version</b></code></td>
<td style="border: 1px solid #ccc;">display tool version</td>
</tr>
</table>

<h2>EXAMPLES</h2>

<p style="margin-left:11%; margin-top: 1em">Generate an RPM spec from a pax file:</p>

<pre style="margin-left:11%;">zopen-pax2rpm /path/to/HAMN110.runnable.pax.Z \
  --summary "HAMN110 Runtime Package" \
  --license "IBM" \
  --url "https://www.ibm.com"</pre>

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
