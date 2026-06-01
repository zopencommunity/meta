<div v-pre class="man-page-content">

<div class="header-with-back"><div class="link" style="float: left;"><a href="./zopen-info">← Previous</a></div><div class='link' style='float: right;'><a href='./zopen-install'>Next →</a></div><div style="clear: both;"></div></div>


<h1 align="center">ZOPEN-INIT</h1>




<h2>NAME</h2>


<p style="margin-left:6%; margin-top: 1em">zopen-init -
manual page for zopen-init 0.8.5</p>

<h2>SYNOPSIS</h2>


<p style="margin-left:6%; margin-top: 1em">zopen
init [OPTION] [PARAMETERS]...</p>

<h2>DESCRIPTION</h2>


<p style="margin-left:6%; margin-top: 1em">zopen init is a
utility for zopen community to generate a zopen environment,
bootstrapping initial tools and creating a configuration
file</p>

<h2>OPTIONS</h2>



<table width="100%" border="0" rules="none" frame="void"
       cellspacing="0" cellpadding="0">

<tr valign="top" align="left">

<td width="6%"></td>


<td width="24%">


<p style="margin-top: 1em">--append-to-profile</p></td>


<td width="70%">
</td>
</tr>

</table>


<p style="margin-left:15%; margin-top: 1em">appends
sourcing of zopen-config to current user's
.profile</p>


<table width="100%" border="0" rules="none" frame="void"
       cellspacing="0" cellpadding="0">

<tr valign="top" align="left">

<td width="6%"></td>


<td width="23%">


<p style="margin-top: 1em">--[no]enable-stats</p></td>


<td width="71%">
</td>
</tr>

</table>


<p style="margin-left:15%; margin-top: 1em">Toggle enabling
collection of usage statistics</p>


<table width="100%" border="0" rules="none" frame="void"
       cellspacing="0" cellpadding="0">

<tr valign="top" align="left">

<td width="6%"></td>


<td width="30%">



<p style="margin-top: 1em">--[no]override-zos-tools</p></td>


<td width="64%">
</td>
</tr>

</table>


<p style="margin-left:15%; margin-top: 1em">Toggle default
mode for overriding z/OS /bin tools in the
zopen-config. Default is --nooverride-zos-tools</p>


<table width="100%" border="0" rules="none" frame="void"
       cellspacing="0" cellpadding="0">

<tr valign="top" align="left">

<td width="6%"></td>


<td width="28%">



<p style="margin-top: 1em">--bypass-prereq-checks</p></td>


<td width="66%">
</td>
</tr>

</table>


<p style="margin-left:15%; margin-top: 1em">Bypasses
pre-requisite checks</p>


<table width="100%" border="0" rules="none" frame="void"
       cellspacing="0" cellpadding="0">

<tr valign="top" align="left">

<td width="6%"></td>


<td width="30%">


<p style="margin-top: 1em">-f, --fs-layout
&lt;LAYOUT&gt;</p></td>


<td width="64%">
</td>
</tr>

</table>


<p style="margin-left:15%; margin-top: 1em">The filesystem
structure to use for installed packages on disk; packages
will be installed to this location under &lt;zopen
rootfs&gt;.</p>

<p style="margin-left:15%; margin-top: 1em">&lt;LAYOUT&gt;
should be one of:</p>

<p style="margin-left:15%; margin-top: 1em">usrlclz:
/usr/local/zopen (default), zopen: /usr/zopen,
prod: legacy zopen standard location, ibm: /usr/lpp,
fhs: File Hierarchical Standard (/opt), usrlcl:
usr/local</p>


<table width="100%" border="0" rules="none" frame="void"
       cellspacing="0" cellpadding="0">

<tr valign="top" align="left">

<td width="6%"></td>


<td width="18%">


<p style="margin-top: 1em">-h, -?, --help</p></td>


<td width="76%">
</td>
</tr>

</table>


<p style="margin-left:15%; margin-top: 1em">display this
help and exit</p>


<table width="100%" border="0" rules="none" frame="void"
       cellspacing="0" cellpadding="0">

<tr valign="top" align="left">

<td width="6%"></td>


<td width="12%">


<p style="margin-top: 1em">--re-init</p></td>


<td width="82%">
</td>
</tr>

</table>


<p style="margin-left:15%; margin-top: 1em">Re-initializes
a previous zopen environment or create a new environment
using current tooling. Re-initializing over a previous
installation will re-use existing package structures and
configuration and regenerate configuration files. select the
active version for PACKAGE from a list</p>


<table width="100%" border="0" rules="none" frame="void"
       cellspacing="0" cellpadding="0">

<tr valign="top" align="left">

<td width="6%"></td>


<td width="12%">


<p style="margin-top: 1em">--refresh</p></td>


<td width="82%">
</td>
</tr>

</table>


<p style="margin-left:15%; margin-top: 1em">Refreshes the
zopen-config file</p>


<table width="100%" border="0" rules="none" frame="void"
       cellspacing="0" cellpadding="0">

<tr valign="top" align="left">

<td width="6%"></td>


<td width="22%">


<p style="margin-top: 1em">--releaseline-dev</p></td>


<td width="72%">
</td>
</tr>

</table>


<p style="margin-left:15%; margin-top: 1em">globally
configure the release line for package installs to enable
Development (DEV) packages; the default is for a system to
use STABLE packages</p>


<table width="100%" border="0" rules="none" frame="void"
       cellspacing="0" cellpadding="0">

<tr valign="top" align="left">

<td width="6%"></td>


<td width="17%">


<p style="margin-top: 1em">-v, --verbose</p></td>


<td width="77%">
</td>
</tr>

</table>


<p style="margin-left:15%; margin-top: 1em">run in verbose
mode</p>


<table width="100%" border="0" rules="none" frame="void"
       cellspacing="0" cellpadding="0">

<tr valign="top" align="left">

<td width="6%"></td>


<td width="12%">


<p style="margin-top: 1em">-y, --yes</p></td>


<td width="82%">
</td>
</tr>

</table>


<p style="margin-left:15%; margin-top: 1em">automatically
answer 'yes' to prompts</p>

<h2>EXAMPLES</h2>


<p style="margin-left:15%; margin-top: 1em">zopen init</p>

<p style="margin-left:15%; margin-top: 1em">interactively
bootstrap a zopen environment</p>

<p style="margin-left:15%; margin-top: 1em">zopen init
--releaseline-dev</p>

<p style="margin-left:15%; margin-top: 1em">interactively
bootstrap a zopen environment that will use Development
Releaseline packages</p>

<p style="margin-left:15%; margin-top: 1em">zopen init
--yes --append-to-profile --fs-layout fhs /zopen</p>


<p style="margin-left:15%; margin-top: 1em">non-interactively
create a zopen environment at location '/zopen'
on disk, with packages installed to
'/zopen/opt'. The user's .profile will be
updated to source the configuration file at
'/zopen/etc/zopen-config' when new terminal
sessions start</p>

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
