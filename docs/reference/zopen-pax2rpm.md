<div v-pre class="man-page-content">

<div class="header-with-back"><div class="link"><a href="./zopen-migrate-groovy">← Previous</a></div><div class='link'><a href='./zopen-promote'>Next →</a></div></div>

<h1 align="center">ZOPEN-PAX2RPM</h1>












<h2>NAME</h2>


<table><tr><td style="width: 25%; vertical-align: top;"><b>zopen-pax2rpm
- manual page for zopen-pax2rpm 0.8.5

<h2>SYNOPSIS</h2>



<b>zopen-pax2rpm</b>
<i><code>&lt;pax_file&gt;</code></i> [<i>options</i>]

<h2>DESCRIPTION</h2>


Generate an RPM
spec file from a z/OS pax archive.

<h3>Arguments:</h3>


pax_file</b></td><td style="vertical-align: top;">Path to the pax file (e.g.,
<i>/path/to/file.pax</i> or file.pax.Z)</td></tr></table>

<h2>OPTIONS</h2>



<table><tr><td style="width: 25%; vertical-align: top;"><b>--name</b>
<code>&lt;name&gt;</code></td><td style="vertical-align: top;">Override package name (default:
extracted from filename)</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>--version</b>
<code>&lt;version&gt;</code></td><td style="vertical-align: top;">Override version (default:
extracted from filename)</td></tr>
<tr><td style="width: 25%; vertical-align: top;"><b>--pkg-version</b>
<code>&lt;version&gt;</code> Override version (alternative to
<b>--version</b>)</td><td style="vertical-align: top;"><b>--help</b></td></tr>
<tr><td style="width: 25%; vertical-align: top;"><b>--version</b></td><td style="vertical-align: top;">Display tool version</td></tr></table>

<h3>Example:</h3>



<p style="margin-left:18%; margin-top: 1em"><i>/u/tejas/new_zopen/zostools_dev/doc/meta/bin/zopen-pax2rpm</i>
/nfsmnts/bpidrivers/oefv1r1/os390/latest/HAMN110.runnable.pax.Z
\</p>

<table>
<tr><td style="width: 25%; vertical-align: top;"><b>--summary</b>
&quot;HAMN110 Runtime Package&quot; \</td><td style="vertical-align: top;"><b>--license</b>
&quot;IBM&quot; \</td></tr>
<tr valign="top" align="left">
<td width="9%"></td>
<td width="47%"><b>--url</b>
&quot;https://www.ibm.com&quot;</td>
<td width="44%">
</td></tr>
</table>

<p style="margin-left:9%; margin-top: 1em">This is free
software: you are free to change and redistribute it under
the terms of the Apache License, Version 2.0.
<a href="https://www.apache.org/licenses/LICENSE-2.0.html" target="_blank">https://www.apache.org/licenses/LICENSE-2.0.html</a>
There is NO WARRANTY, to the extent permitted by law.</p>

<h2>AUTHOR</h2>


<p style="margin-left:9%; margin-top: 1em">Written by
contributors to the zopen community.
<a href="https://github.com/zopencommunity/meta/graphs/contributors" target="_blank">https://github.com/zopencommunity/meta/graphs/contributors</a></p>

</div>
