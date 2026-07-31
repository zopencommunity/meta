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

<p style="margin-left:11%; margin-top: 1em">Generate an RPM
spec file from a z/OS pax archive.</p>

<p style="margin-left:11%; margin-top: 1em"><b>Arguments:</b>
pax_file</p>

<p style="margin-left:22%;">Path to the pax file (e.g.,
/path/to/file.pax or file.pax.Z)</p>

<h2>OPTIONS</h2>
<a name="OPTIONS"></a>

<p style="margin-left:11%; margin-top: 1em"><b>&minus;&minus;name</b>
&lt;name&gt;</p>

<p style="margin-left:22%;">Override package name (default:
extracted from filename)</p>

<p style="margin-left:11%;"><b>&minus;&minus;version</b>
&lt;version&gt;</p>

<p style="margin-left:22%;">Override version (default:
extracted from filename)</p>

<table width="100%" border="0" rules="none" frame="void"
       cellspacing="0" cellpadding="0">

<tr valign="top" align="left">

<td width="11%"></td>

<td width="89%">

<p style="margin-top: 1em"><b>&minus;&minus;pkg&minus;version</b>
&lt;version&gt; Override version (alternative to
<b>&minus;&minus;version</b>)</p></td>
</tr>

</table>

<p style="margin-left:11%;"><b>&minus;&minus;release</b> &lt;release&gt;</p>

<p style="margin-left:22%;">Override release number
(default: 1)</p>

<p style="margin-left:11%;"><b>&minus;&minus;license</b>
&lt;license&gt;</p>

<p style="margin-left:22%;">Specify license (default:
Proprietary)</p>

<p style="margin-left:11%;"><b>&minus;&minus;summary</b>
&lt;summary&gt;</p>

<p style="margin-left:22%;">Package summary (required)</p>

<p style="margin-left:11%;"><b>&minus;&minus;description</b>
&lt;desc&gt;</p>

<p style="margin-left:22%;">Package description (default:
same as summary)</p>

<p style="margin-left:11%;"><b>&minus;&minus;url</b>
&lt;url&gt;</p>

<p style="margin-left:22%;">Project URL (default: none)</p>

<p style="margin-left:11%;"><b>&minus;&minus;requires</b>
&lt;deps&gt;</p>

<p style="margin-left:22%;">Package dependencies (e.g.,
&quot;oef &gt;= 1.1.0&quot;)</p>

<p style="margin-left:11%;"><b>&minus;&minus;output</b>
&lt;file&gt;</p>

<p style="margin-left:22%;">Output spec file (default:
&lt;name&gt;.spec)</p>

<p style="margin-left:11%;"><b>&minus;&minus;build</b></p>

<p style="margin-left:22%;">Build the RPM after generating
spec file</p>

<p style="margin-left:11%;"><b>&minus;&minus;buildroot</b>
&lt;dir&gt;</p>

<p style="margin-left:22%;">RPM build root directory
(default: ~/rpmbuild)</p>

<p style="margin-left:11%;"><b>&minus;&minus;validate</b></p>

<p style="margin-left:22%;">Validate spec file after
generation (checks syntax and runs rpmlint)</p>

<p style="margin-left:11%;"><b>&minus;&minus;dry&minus;run</b></p>

<p style="margin-left:22%;">Show what would be done without
actually doing it</p>

<p style="margin-left:11%;"><b>&minus;&minus;verbose</b></p>

<p style="margin-left:22%;">Enable verbose debug output</p>

<table width="100%" border="0" rules="none" frame="void"
       cellspacing="0" cellpadding="0">

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

</table>

<p style="margin-left:11%;"><b>&minus;&minus;version</b></p>

<p style="margin-left:22%;">Display tool version</p>

<p style="margin-left:11%; margin-top: 1em"><b>Example:</b></p>

<p style="margin-left:22%;">>/var/lib/jenkins/workspace/Port&minus;Update&minus;Nightlyy/meta_update/bin/zopen&minus;pax2rpm
/nfsmounts/bpidrivers/oefv1r1/os3900/latest/HAMN110.runnable.pax.Z
\</p>

<table width="100%" border="0" rules="none" frame="void"
       cellspacing="0" cellpadding="0">

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
&lt;<a href="https://www.apache.org/licenses/LICENSE" target="_blank">https://www.apache.org/licenses/LICENSE</a>&minus;2.0.html&gt;
There is NO WARRANTY, to the extent permitted by law.</p>

<h2>AUTHOR</h2>
<a name="AUTHOR"></a>

<p style="margin-left:11%; margin-top: 1em">Written by
contributors to the zopen community.
<a href="https://github.com/zopencommunity/meta/graphs/contributors" target="_blank">https://github.com/zopencommunity/meta/graphs/contributors</a></p>

</div>
