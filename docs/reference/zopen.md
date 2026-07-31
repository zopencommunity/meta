<div v-pre class="man-page-content">

<div class="header-with-back">
  <div class="back-link">
    <a href="./zopen-reference">← Back</a>
  </div>
</div>

<h1 align="center">ZOPEN-VERSION</h1>

<h2>NAME</h2>
<a name="NAME"></a>

<p style="margin-left:11%; margin-top: 1em">zopen-version
&minus; manual page for zopen-version 0.8.4</p>

<h2>SYNOPSIS</h2>
<a name="SYNOPSIS"></a>

<p style="margin-left:11%; margin-top: 1em"><b>zopen</b>
[COMMAND] [OPTION] [PARAMETERS]...</p>

<h2>DESCRIPTION</h2>
<a name="DESCRIPTION"></a>

<p style="margin-left:11%; margin-top: 1em">zopen is a
utility for managing a zopen community environment.</p>

<p style="margin-left:11%; margin-top: 1em"><b>Command:</b></p>

<table width="100%" border="0" rules="none" frame="void" cellspacing="0" cellpadding="0">

<tr valign="top" align="left">

<td width="11%"></td>

<td width="9%">

<p>alt</p></td>

<td width="2%"></td>

<td width="78%">

<p>manage alternate versions of zopen community
packages</p></td>
</tr>

<tr valign="top" align="left">

<td width="11%"></td>

<td width="9%">

<p>audit</p></td>

<td width="2%"></td>

<td width="78%">

<p>(beta) reports known vulnerabilities for the installed
packages</p></td>
</tr>

<tr valign="top" align="left">

<td width="11%"></td>

<td width="9%">

<p>build</p></td>

<td width="2%"></td>

<td width="78%">

<p>builds the enclosing zopen community git&minus;cloned
package</p></td>
</tr>

<tr valign="top" align="left">

<td width="11%"></td>

<td width="9%">

<p>clean</p></td>

<td width="2%"></td>

<td width="78%">

<p>cleans up your zopen environment</p></td>
</tr>

<tr valign="top" align="left">

<td width="11%"></td>

<td width="9%">

<p>config</p></td>

<td width="2%"></td>

<td width="78%">

<p>change zopen runtime environment settings</p></td>
</tr>

<tr valign="top" align="left">

<td width="11%"></td>

<td width="9%">

<p>diagnostics</p></td>

<td width="2%"></td>

<td width="78%">

<p>collects system info for zopen troubleshooting</p></td>
</tr>

<tr valign="top" align="left">

<td width="11%"></td>

<td width="9%">

<p>generate</p></td>

<td width="2%"></td>

<td width="78%">

<p>generates a new zopen project</p></td>
</tr>

<tr valign="top" align="left">

<td width="11%"></td>

<td width="9%">

<p>init</p></td>

<td width="2%"></td>

<td width="78%">

<p>initializes a zopen environment at the specified
location</p></td>
</tr>

<tr valign="top" align="left">

<td width="11%"></td>

<td width="9%">

<p>refresh</p></td>

<td width="2%"></td>

<td width="78%">

<p>refreshes your zopen environment and zopen&minus;config file</p></td>
</tr>

<tr valign="top" align="left">

<td width="11%"></td>

<td width="9%">

<p>install</p></td>

<td width="2%"></td>

<td width="78%">

<p>installs one or more zopen community packages</p></td>
</tr>

<tr valign="top" align="left">

<td width="11%"></td>

<td width="9%">

<p>info</p></td>

<td width="2%"></td>

<td width="78%">

<p>displays detailed information about a package</p></td>
</tr>

<tr valign="top" align="left">

<td width="11%"></td>

<td width="9%">

<p>list</p></td>

<td width="2%"></td>

<td width="78%">

<p>lists information about zopen community packages</p></td>
</tr>

<tr valign="top" align="left">

<td width="11%"></td>

<td width="9%">

<p>publish</p></td>

<td width="2%"></td>

<td width="78%">

<p>publish zopen package release to github</p></td>
</tr>

<tr valign="top" align="left">

<td width="11%"></td>

<td width="9%">

<p>query</p></td>

<td width="2%"></td>

<td width="78%">

<p>list local or remote info about zopen community
packages</p></td>
</tr>

<tr valign="top" align="left">

<td width="11%"></td>

<td width="9%">

<p>remove</p></td>

<td width="2%"></td>

<td width="78%">

<p>removes installed zopen community packages</p></td>
</tr>

<tr valign="top" align="left">

<td width="11%"></td>

<td width="9%">

<p>update&minus;cacert</p></td>

<td width="2%"></td>

<td width="78%">

<p>update the cacert.pem file used by zopen community</p></td>
</tr>

<tr valign="top" align="left">

<td width="11%"></td>

<td width="9%">

<p>upgrade</p></td>

<td width="2%"></td>

<td width="78%">

<p>upgrades existing zopen community packages</p></td>
</tr>

<tr valign="top" align="left">

<td width="11%"></td>

<td width="9%">

<p>usage</p></td>

<td width="2%"></td>

<td width="78%">

<p>output details about the file system usage for your
zopen environment</p></td>
</tr>

<tr valign="top" align="left">

<td width="11%"></td>

<td width="9%">

<p>whichproject</p></td>

<td width="2%"></td>

<td width="78%">

<p>determine the package a command or library belongs to</p></td>
</tr>

</table>

<h2>OPTIONS</h2>
<a name="OPTIONS"></a>

<p style="margin-left:11%; margin-top: 1em"><b>&minus;h</b>,
<b>&minus;&minus;help</b>, &minus;?</p>

<p style="margin-left:22%;">display this help and exit</p>

<p style="margin-left:11%;"><b>&minus;v</b>,
<b>&minus;&minus;verbose</b></p>

<p style="margin-left:22%;">run in verbose mode</p>

<h2>EXAMPLES</h2>
<a name="EXAMPLES"></a>

<p style="margin-left:11%; margin-top: 1em">zopen
&minus;&minus;help</p>

<p style="margin-left:22%;">displays zopen help</p>

<p style="margin-left:11%;">zopen &minus;&minus;version</p>

<p style="margin-left:22%;">displays the installed zopen
version</p>

<p style="margin-left:22%; margin-top: 1em">zopen install
git install the latest version of the &rsquo;git&rsquo;
package zopen upgrade &minus;y upgrade all installed
packages to the latest release,</p>

<p style="margin-left:22%; margin-top: 1em">without
prompting</p>

<p style="margin-left:11%;">zopen alt bash</p>

<p style="margin-left:22%;">list installed alternative bash
packages</p>

<p style="margin-left:11%;">zopen info vim</p>

<p style="margin-left:22%;">displays details information
about the installed vim package</p>

<p style="margin-left:22%; margin-top: 1em">zopen usage
&minus;&minus;pie displays an ASCII&minus;art chart showing
biggest space hogs</p>

<p style="margin-left:11%; margin-top: 1em"><b>SEE
ALSO:</b></p>

<p style="margin-left:22%;">zopen&minus;alt(1)
zopen&minus;audit(1) zopen&minus;build(1)
zopen&minus;clean(1) zopen&minus;config&minus;helper(1)
zopen&minus;generate(1) zopen&minus;init(1)
zopen&minus;install(1) zopen&minus;info(1)
zopen&minus;publish(1) zopen&minus;query(1)
zopen&minus;remove(1) zopen&minus;update&minus;cacert(1)
zopen&minus;usage(1) zopen&minus;whichproject(1)
zopen&minus;version(1)</p>

<h2>AUTHOR</h2>
<a name="AUTHOR"></a>

<p style="margin-left:11%; margin-top: 1em">Written by
contributors to the zopen community.
<a href="https://github.com/zopencommunity/meta/graphs/contributors" target="_blank">https://github.com/zopencommunity/meta/graphs/contributors</a></p>

<h2>REPORTING BUGS</h2>
<a name="REPORTING BUGS"></a>

<p style="margin-left:11%; margin-top: 1em">Report bugs at
<a href="https://github.com/zopencommunity/meta/issues" target="_blank">https://github.com/zopencommunity/meta/issues</a></p>

<p style="margin-left:11%; margin-top: 1em">This is free
software: you are free to change and redistribute it under
the terms of the Apache License, Version 2.0.
<a href="https://www.apache.org/licenses/LICENSE-2.0.html" target="_blank">https://www.apache.org/licenses/LICENSE-2.0.html</a>
There is NO WARRANTY, to the extent permitted by law.</p>

</div>
