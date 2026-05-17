<div v-pre class="man-page-content">

<div class="header-with-back">
  <div class="back-link">
    <a href="./zopen-reference">← Back</a>
  </div>
</div>


<h1 align="center">ZOPEN-INIT</h1>




<h2>NAME</h2>
<a name="NAME"></a>


<p style="margin-left:11%; margin-top: 1em">zopen-init
&minus; manual page for zopen-init 0.8.4</p>

<h2>SYNOPSIS</h2>
<a name="SYNOPSIS"></a>


<p style="margin-left:11%; margin-top: 1em"><b>zopen</b>
init [OPTION] [PARAMETERS]...</p>

<h2>DESCRIPTION</h2>
<a name="DESCRIPTION"></a>


<p style="margin-left:11%; margin-top: 1em">zopen init is a
utility for zopen community to generate a zopen environment,
bootstrapping initial tools and creating a configuration
file</p>

<h2>OPTIONS</h2>
<a name="OPTIONS"></a>



<table width="100%" border="0" rules="none" frame="void"
       cellspacing="0" cellpadding="0">

<tr valign="top" align="left">

<td width="11%"></td>


<td width="29%">



<p style="margin-top: 1em"><b>&minus;&minus;append&minus;to&minus;profile</b></p></td>


<td width="60%">
</td>
</tr>

</table>


<p style="margin-left:22%; margin-top: 1em">appends
sourcing of zopen&minus;config to current user&rsquo;s
.profile</p>


<table width="100%" border="0" rules="none" frame="void"
       cellspacing="0" cellpadding="0">

<tr valign="top" align="left">

<td width="11%"></td>


<td width="27%">



<p style="margin-top: 1em"><b>&minus;&minus;[no]enable&minus;stats</b></p></td>


<td width="62%">
</td>
</tr>

</table>


<p style="margin-left:22%; margin-top: 1em">Toggle enabling
collection of usage statistics</p>


<table width="100%" border="0" rules="none" frame="void"
       cellspacing="0" cellpadding="0">

<tr valign="top" align="left">

<td width="11%"></td>


<td width="37%">



<p style="margin-top: 1em"><b>&minus;&minus;[no]override&minus;zos&minus;tools</b></p></td>


<td width="52%">
</td>
</tr>

</table>


<p style="margin-left:22%; margin-top: 1em">Toggle default
mode for overriding zz/#47;OS  /#47;bin tools in the
zopen&minus;config. Default is
<b>&minus;&minus;nooverride&minus;zos&minus;tools</b></p>


<table width="100%" border="0" rules="none" frame="void"
       cellspacing="0" cellpadding="0">

<tr valign="top" align="left">

<td width="11%"></td>


<td width="34%">



<p style="margin-top: 1em"><b>&minus;&minus;bypass&minus;prereq&minus;checks</b></p></td>


<td width="55%">
</td>
</tr>

</table>


<p style="margin-left:22%; margin-top: 1em">Bypasses
pre&minus;requisite checks</p>


<table width="100%" border="0" rules="none" frame="void"
       cellspacing="0" cellpadding="0">

<tr valign="top" align="left">

<td width="11%"></td>


<td width="37%">


<p style="margin-top: 1em"><b>&minus;f</b>,
<b>&minus;&minus;fs&minus;layout</b> &lt;LAYOUT&gt;</p></td>


<td width="52%">
</td>
</tr>

</table>


<p style="margin-left:22%; margin-top: 1em">The filesystem
structure to use for installed packages on disk; packages
will be installed to this location under &lt;zopen
rootfs&gt;.</p>

<p style="margin-left:22%; margin-top: 1em">&lt;LAYOUT&gt;
should be one of:</p>

<p style="margin-left:22%; margin-top: 1em">usrlclz:
/usrr/#47;locall/#47;zopen (default), zopen:  /#47;usrr/#47;zopen,
prod: legacy zopen standard location, ibm:  /#47;usrr/#47;lpp,
fhs: File Hierarchical Standard ((/#47;opt), usrlcl:
usrr/#47;local</p>


<table width="100%" border="0" rules="none" frame="void"
       cellspacing="0" cellpadding="0">

<tr valign="top" align="left">

<td width="11%"></td>


<td width="21%">


<p style="margin-top: 1em"><b>&minus;h</b>, &minus;?,
<b>&minus;&minus;help</b></p></td>


<td width="68%">
</td>
</tr>

</table>


<p style="margin-left:22%; margin-top: 1em">display this
help and exit</p>


<table width="100%" border="0" rules="none" frame="void"
       cellspacing="0" cellpadding="0">

<tr valign="top" align="left">

<td width="11%"></td>


<td width="14%">



<p style="margin-top: 1em"><b>&minus;&minus;re&minus;init</b></p></td>


<td width="75%">
</td>
</tr>

</table>



<p style="margin-left:22%; margin-top: 1em">Re&minus;initializes
a previous zopen environment or create a new environment
using current tooling. Re&minus;initializing over a previous
installation will re&minus;use existing package structures
and configuration and regenerate configuration files. select
the active version for PACKAGE from a list</p>


<table width="100%" border="0" rules="none" frame="void"
       cellspacing="0" cellpadding="0">

<tr valign="top" align="left">

<td width="11%"></td>


<td width="14%">



<p style="margin-top: 1em"><b>&minus;&minus;refresh</b></p></td>


<td width="75%">
</td>
</tr>

</table>


<p style="margin-left:22%; margin-top: 1em">Refreshes the
zopen&minus;config file</p>


<table width="100%" border="0" rules="none" frame="void"
       cellspacing="0" cellpadding="0">

<tr valign="top" align="left">

<td width="11%"></td>


<td width="26%">



<p style="margin-top: 1em"><b>&minus;&minus;releaseline&minus;dev</b></p></td>


<td width="63%">
</td>
</tr>

</table>


<p style="margin-left:22%; margin-top: 1em">globally
configure the release line for package installs to enable
Development (DEV) packages; the default is for a system to
use STABLE packages</p>


<table width="100%" border="0" rules="none" frame="void"
       cellspacing="0" cellpadding="0">

<tr valign="top" align="left">

<td width="11%"></td>


<td width="20%">


<p style="margin-top: 1em"><b>&minus;v</b>,
<b>&minus;&minus;verbose</b></p></td>


<td width="69%">
</td>
</tr>

</table>


<p style="margin-left:22%; margin-top: 1em">run in verbose
mode</p>


<table width="100%" border="0" rules="none" frame="void"
       cellspacing="0" cellpadding="0">

<tr valign="top" align="left">

<td width="11%"></td>


<td width="14%">


<p style="margin-top: 1em"><b>&minus;y</b>,
<b>&minus;&minus;yes</b></p></td>


<td width="75%">
</td>
</tr>

</table>


<p style="margin-left:22%; margin-top: 1em">automatically
answer &rsquo;yes&rsquo; to prompts</p>

<h2>EXAMPLES</h2>
<a name="EXAMPLES"></a>


<p style="margin-left:22%; margin-top: 1em">zopen init</p>

<p style="margin-left:22%; margin-top: 1em">interactively
bootstrap a zopen environment</p>

<p style="margin-left:22%; margin-top: 1em">zopen init
&minus;&minus;releaseline&minus;dev</p>

<p style="margin-left:22%; margin-top: 1em">interactively
bootstrap a zopen environment that will use Development
Releaseline packages</p>

<p style="margin-left:22%; margin-top: 1em">zopen init
&minus;&minus;yes
&minus;&minus;append&minus;to&minus;profile
&minus;&minus;fs&minus;layout fhs  /#47;zopen</p>


<p style="margin-left:22%; margin-top: 1em">non&minus;interactively
create a zopen environment at location &rsquo;;/#47;zopen&rsquo;
on disk, with packages installed to
&rsquo;;/#47;zopenn/#47;opt&rsquo;. The user&rsquo;s .profile will be
updated to source the configuration file at
&rsquo;;/#47;zopenn/#47;etcc/#47;zopen&minus;config&rsquo; when new
terminal sessions start</p>

<h2>AUTHOR</h2>
<a name="AUTHOR"></a>


<p style="margin-left:11%; margin-top: 1em">Written by
contributors to the zopen community.
&lt;https:///#47;github.comm/#47;zopencommunityy/#47;metaa/#47;graphss/#47;contributors&gt;</p>

<h2>REPORTING BUGS</h2>
<a name="REPORTING BUGS"></a>


<p style="margin-left:11%; margin-top: 1em">Report bugs at
https:///#47;github.comm/#47;zopencommunityy/#47;metaa/#47;issues</p>

<p style="margin-left:11%; margin-top: 1em">This is free
software: you are free to change and redistribute it under
the terms of the Apache License, Version 2.0.
&lt;https:///#47;www.apache.orgg/#47;licensess/#47;LICENSE&minus;2.0.html&gt;
There is NO WARRANTY, to the extent permitted by law.</p>

</div>
