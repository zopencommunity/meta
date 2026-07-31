<div v-pre class="man-page-content">

<div class="header-with-back">
  <div class="back-link">
    <a href="./zopen-reference">← Back</a>
  </div>
</div>

<h1 align="center">ZOPEN-PAX2RPM</h1>

<h2>NAME</h2>
<a name="NAME"></a>

<p style="margin-left:11%; margin-top: 1em">zopen-pax2rpm
&minus; manual page for zopen-pax2rpm 0.8.4</p>

<h2>SYNOPSIS</h2>
<a name="SYNOPSIS"></a>

<p style="margin-left:11%; margin-top: 1em"><b>zopen-pax2rpm</b>
&lt;pax_file&gt; [options]</p>

<h2>DESCRIPTION</h2>
<a name="DESCRIPTION"></a>

<table border="1" cellpadding="10" cellspacing="0" style="width:100%; border-collapse:collapse;">
<tr style="background-color:#f0f0f0;">
<th style="text-align:left; border: 1px solid #ccc;">Option</th>
<th style="text-align:left; border: 1px solid #ccc;">Description</th>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code>Generate an RPM spec file from a z/OS pax archive.</p>  <p style="margin-left:11%; margin-top: 1em"><b>Arguments:</b> pax_file</code></td>
<td style="border: 1px solid #ccc;">Path to the pax file (e.g., /path/to/file.pax or file.pax.Z)</td>
</tr>
</table>


<h2>OPTIONS</h2>
<a name="OPTIONS"></a>



<table border="1" cellpadding="10" cellspacing="0" style="width:100%; border-collapse:collapse;">
<tr style="background-color:#f0f0f0;">
<th style="text-align:left; border: 1px solid #ccc;">Option</th>
<th style="text-align:left; border: 1px solid #ccc;">Description</th>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code><b>&minus;&minus;name</b> &lt;name&gt;</code></td>
<td style="border: 1px solid #ccc;">Override package name (default: extracted from filename)</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code><b>&minus;&minus;version</b> &lt;version&gt;</code></td>
<td style="border: 1px solid #ccc;">Override version (default: extracted from filename)</td>
</tr>
</table>


<table width="100%" border="0" rules="none" frame="void" cellspacing="0" cellpadding="0">

<tr valign="top" align="left">

<td width="11%"></td>

<td width="89%">

<p style="margin-top: 1em"><b>&minus;&minus;pkg&minus;version</b>
&lt;version&gt; Override version (alternative to
<b>&minus;&minus;version</b>)</p></td>
</tr>


<tr>
<td style="border: 1px solid #ccc;"><code><b>&minus;&minus;release</b> &lt;release&gt;</code></td>
<td style="border: 1px solid #ccc;">Override release number (default: 1)</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code><b>&minus;&minus;license</b> &lt;license&gt;</code></td>
<td style="border: 1px solid #ccc;">Specify license (default: Proprietary)</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code><b>&minus;&minus;summary</b> &lt;summary&gt;</code></td>
<td style="border: 1px solid #ccc;">Package summary (required)</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code><b>&minus;&minus;description</b> &lt;desc&gt;</code></td>
<td style="border: 1px solid #ccc;">Package description (default: same as summary)</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code><b>&minus;&minus;url</b> &lt;url&gt;</code></td>
<td style="border: 1px solid #ccc;">Project URL (default: none)</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code><b>&minus;&minus;requires</b> &lt;deps&gt;</code></td>
<td style="border: 1px solid #ccc;">Package dependencies (e.g., &quot;oef &gt;= 1.1.0&quot;)</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code><b>&minus;&minus;output</b> &lt;file&gt;</code></td>
<td style="border: 1px solid #ccc;">Output spec file (default: &lt;name&gt;.spec)</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code><b>&minus;&minus;build</b></code></td>
<td style="border: 1px solid #ccc;">Build the RPM after generating spec file</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code><b>&minus;&minus;buildroot</b> &lt;dir&gt;</code></td>
<td style="border: 1px solid #ccc;">RPM build root directory (default: ~/rpmbuild)</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code><b>&minus;&minus;validate</b></code></td>
<td style="border: 1px solid #ccc;">Validate spec file after generation (checks syntax and runs rpmlint)</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code><b>&minus;&minus;dry&minus;run</b></code></td>
<td style="border: 1px solid #ccc;">Show what would be done without actually doing it</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code><b>&minus;&minus;verbose</b></code></td>
<td style="border: 1px solid #ccc;">Enable verbose debug output</td>
</tr>
</table>


























<table width="100%" border="0" rules="none" frame="void" cellspacing="0" cellpadding="0">

<tr valign="top" align="left">

<td width="11%"></td>

<td width="9%">

<p><b>&minus;&minus;help</b></p></td>

<td width="2%"></td>

<td width="38%">

<p>Display this help message</p></td>

<td width="40%">
</td>
</tr>


<tr>
<td style="border: 1px solid #ccc;"><code><b>&minus;&minus;version</b></code></td>
<td style="border: 1px solid #ccc;">Display tool version</td>
</tr>
<tr>
<td style="border: 1px solid #ccc;"><code><b>Example:</b></code></td>
<td style="border: 1px solid #ccc;">>/var/lib/jenkins/workspace/Port&minus;Update&minus;Nightlyy/meta_update/bin/zopen&minus;pax2rpm /nfsmounts/bpidrivers/oefv1r1/os3900/latest/HAMN110.runnable.pax.Z \</td>
</tr>
</table>






<table width="100%" border="0" rules="none" frame="void" cellspacing="0" cellpadding="0">

<tr valign="top" align="left">

<td width="11%"></td>

<td width="57%">

<p style="margin-top: 1em"><b>&minus;&minus;summary</b>
&quot;HAMN110 Runtime Package&quot; \</p></td>

<td width="32%">
</td>
</tr>

<tr valign="top" align="left">

<td width="11%"></td>

<td width="57%">

<p style="margin-top: 1em"><b>&minus;&minus;license</b>
&quot;IBM&quot; \</p></td>

<td width="32%">
</td>
</tr>

<tr valign="top" align="left">

<td width="11%"></td>

<td width="57%">

<p style="margin-top: 1em"><b>&minus;&minus;url</b>
&quot;<a href="https://www.ibm.com" target="_blank">https://www.ibm.com</a>&quot;</p></td>

<td width="32%">
</td>
</tr>

</table>

<p style="margin-left:11%; margin-top: 1em">This is free
software: you are free to change and redistribute it under
the terms of the Apache License, Version 2.0.
<a href="https://www.apache.org/licenses/LICENSE-2.0.html" target="_blank">https://www.apache.org/licenses/LICENSE-2.0.html</a>
There is NO WARRANTY, to the extent permitted by law.</p>

<h2>AUTHOR</h2>
<a name="AUTHOR"></a>

<p style="margin-left:11%; margin-top: 1em">Written by
contributors to the zopen community.
<a href="https://github.com/zopencommunity/meta/graphs/contributors" target="_blank">https://github.com/zopencommunity/meta/graphs/contributors</a></p>

</div>
