<div v-pre class="man-page-content">

<div class="header-with-back"><div class="link" style="float: left;"><a href="./zopen-whichproject">← Previous</a></div><div style="clear: both;"></div></div>


<h1 align="center">ZOPEN-VERSION</h1>




<h2>NAME</h2>


<p style="margin-left:6%; margin-top: 1em">zopen-version -
manual page for zopen-version 0.8.5</p>

<h2>SYNOPSIS</h2>


<p style="margin-left:6%; margin-top: 1em">zopen
[COMMAND] [OPTION] [PARAMETERS]...</p>

<h2>DESCRIPTION</h2>


<p style="margin-left:6%; margin-top: 1em">zopen is a
utility for managing a zopen community environment.</p>

<h3>Command:</h3>



<table width="100%" border="0" rules="none" frame="void"
       cellspacing="0" cellpadding="0">

<tr valign="top" align="left">

<td width="6%"></td>


<td width="7%">


<p style="margin-top: 1em">alt</p></td>


<td width="2%"></td>


<td width="79%">


<p style="margin-top: 1em">manage alternate versions of
zopen community packages</p></td>


<td width="6%">
</td>
</tr>


<tr valign="top" align="left">

<td width="6%"></td>


<td width="7%">


<p style="margin-top: 1em">audit</p></td>


<td width="2%"></td>


<td width="79%">


<p style="margin-top: 1em">(beta) reports known
vulnerabilities for the installed packages</p></td>


<td width="6%">
</td>
</tr>


<tr valign="top" align="left">

<td width="6%"></td>


<td width="7%">


<p style="margin-top: 1em">build</p></td>


<td width="2%"></td>


<td width="79%">


<p style="margin-top: 1em">builds the enclosing zopen
community git-cloned package</p></td>


<td width="6%">
</td>
</tr>


<tr valign="top" align="left">

<td width="6%"></td>


<td width="7%">


<p style="margin-top: 1em">clean</p></td>


<td width="2%"></td>


<td width="79%">


<p style="margin-top: 1em">cleans up your zopen
environment</p></td>


<td width="6%">
</td>
</tr>

</table>


<p style="margin-left:6%;">config</p>

<p style="margin-left:15%;">change zopen runtime
environment settings</p>

<p style="margin-left:6%;">diagnostics</p>

<p style="margin-left:15%;">collects system info for zopen
troubleshooting</p>

<p style="margin-left:6%;">generate</p>

<p style="margin-left:15%;">generates a new zopen
project</p>


<table width="100%" border="0" rules="none" frame="void"
       cellspacing="0" cellpadding="0">

<tr valign="top" align="left">

<td width="6%"></td>


<td width="5%">


<p>init</p></td>


<td width="4%"></td>


<td width="71%">


<p>initializes a zopen environment at the specified
location</p></td>


<td width="14%">
</td>
</tr>

</table>


<p style="margin-left:6%;">refresh</p>

<p style="margin-left:15%;">refreshes your zopen
environment and zopen-config file</p>

<p style="margin-left:6%;">install</p>

<p style="margin-left:15%;">installs one or more zopen
community packages</p>


<table width="100%" border="0" rules="none" frame="void"
       cellspacing="0" cellpadding="0">

<tr valign="top" align="left">

<td width="6%"></td>


<td width="5%">


<p>info</p></td>


<td width="4%"></td>


<td width="60%">


<p>displays detailed information about a package</p></td>


<td width="25%">
</td>
</tr>


<tr valign="top" align="left">

<td width="6%"></td>


<td width="5%">


<p style="margin-top: 1em">list</p></td>


<td width="4%"></td>


<td width="60%">


<p style="margin-top: 1em">lists information about zopen
community packages</p></td>


<td width="25%">
</td>
</tr>

</table>


<p style="margin-left:6%;">publish</p>

<p style="margin-left:15%;">publish zopen package release
to github</p>


<table width="100%" border="0" rules="none" frame="void"
       cellspacing="0" cellpadding="0">

<tr valign="top" align="left">

<td width="6%"></td>


<td width="7%">


<p>query</p></td>


<td width="2%"></td>


<td width="70%">


<p>list local or remote info about zopen community
packages</p></td>


<td width="15%">
</td>
</tr>

</table>


<p style="margin-left:6%;">remove</p>

<p style="margin-left:15%;">removes installed zopen
community packages</p>

<p style="margin-left:6%;">update-cacert</p>

<p style="margin-left:15%;">update the cacert.pem file used
by zopen community</p>

<p style="margin-left:6%;">upgrade</p>

<p style="margin-left:15%;">upgrades existing zopen
community packages</p>


<table width="100%" border="0" rules="none" frame="void"
       cellspacing="0" cellpadding="0">

<tr valign="top" align="left">

<td width="6%"></td>


<td width="7%">


<p>usage</p></td>


<td width="2%"></td>


<td width="85%">


<p>output details about the file system usage for your
zopen environment</p></td>
</tr>

</table>


<p style="margin-left:6%;">whichproject</p>

<p style="margin-left:15%;">determine the package a command
or library belongs to</p>

<h2>OPTIONS</h2>


<p style="margin-left:6%; margin-top: 1em">-h,
--help, -?</p>

<p style="margin-left:15%;">display this help and exit</p>

<p style="margin-left:6%;">-v, --verbose</p>

<p style="margin-left:15%;">run in verbose mode</p>

<h2>EXAMPLES</h2>


<p style="margin-left:6%; margin-top: 1em">zopen --help</p>

<p style="margin-left:15%;">displays zopen help</p>

<p style="margin-left:6%;">zopen --version</p>

<p style="margin-left:15%;">displays the installed zopen
version</p>

<p style="margin-left:15%; margin-top: 1em">zopen install
git install the latest version of the 'git'
package zopen upgrade -y upgrade all installed packages to
the latest release,</p>

<p style="margin-left:15%; margin-top: 1em">without
prompting</p>

<p style="margin-left:6%;">zopen alt bash</p>

<p style="margin-left:15%;">list installed alternative bash
packages</p>

<p style="margin-left:6%;">zopen info vim</p>

<p style="margin-left:15%;">displays details information
about the installed vim package</p>

<p style="margin-left:15%; margin-top: 1em">zopen usage
--pie displays an ASCII-art chart showing biggest space
hogs</p>

<h3>SEE ALSO:</h3>


<p style="margin-left:15%; margin-top: 1em">zopen-alt(1)
zopen-audit(1) zopen-build(1) zopen-clean(1)
zopen-config-helper(1) zopen-generate(1) zopen-init(1)
zopen-install(1) zopen-info(1) zopen-publish(1)
zopen-query(1) zopen-remove(1) zopen-update-cacert(1)
zopen-usage(1) zopen-whichproject(1) zopen-version(1)</p>

<h2>AUTHOR</h2>


<p style="margin-left:6%; margin-top: 1em">Written by
contributors to the zopen community.
<a href="https://github.com/zopencommunity/meta/graphs/contributors" target="_blank">https://github.com/zopencommunity/meta/graphs/contributors</a></p>

<h2>REPORTING BUGS</h2>


<p style="margin-left:6%; margin-top: 1em">Report bugs at
https://github.com/zopencommunity/meta/issues</p>

<p style="margin-left:6%; margin-top: 1em">This is free
software: you are free to change and redistribute it under
the terms of the Apache License, Version 2.0.
<a href="https://www.apache.org/licenses/LICENSE-2.0.html" target="_blank">https://www.apache.org/licenses/LICENSE-2.0.html</a>
There is NO WARRANTY, to the extent permitted by law.</p>

</div>
