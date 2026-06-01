<div v-pre class="man-page-content">

<div class="header-with-back"><div class="link"><a href="./zopen-pax2rpm">← Previous</a></div><div class='link'><a href='./zopen-publish'>Next →</a></div></div>

<h1 align="center">ZOPEN-VERSION</h1>












<h2>NAME</h2>


<table><tr><td style="width: 25%; vertical-align: top;"><b>zopen-version
- manual page for zopen-version 0.8.5

<h2>SYNOPSIS</h2>


<b>zopen</b>
<i>promote</i> [<i>OPTION</i>] [<i>DESTINATION</i>]...

<h2>DESCRIPTION</h2>



zopen-promote
is a utility for zopen community to generate a clone of an
existing zopen environment. For example, a user can install
to a test area, validate the behavior, and promote to a
production area.

<h2>OPTIONS</h2>



<b>-cp</b>,
<b>--configperms</b> [PERMISSIONS]</b></td><td style="vertical-align: top;">Update the permissions for the
configuration file
<code>&lt;promotedroot&gt;</code>/etc/zopen-config with the given
[PERMISSIONS] string, specified in symbolic mode.</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>-f</b>,
<b>--from</b></td><td style="vertical-align: top;">[DIRECTORY] The zopen
environment to copy from; if not present, the default is
taken from ZOPEN_ROOTFS (the current zopen environment).</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>-g</b>,
<b>--group</b> [GROUP]</td><td style="vertical-align: top;">Change group of promoted
environment files from default.</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>-h</b>, -?,
<b>--help</b></td><td style="vertical-align: top;">Display this help and exit.</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>--keepzopentooling</b></td><td style="vertical-align: top;">Install the zopen admin tools
into the promoted environment for zopen system
administration.</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>-o</b>,
<b>--owner</b> [OWNER]</td><td style="vertical-align: top;">Change owner of promoted
environment files from current user.</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>-v</b>,
<b>--verbose</b></td><td style="vertical-align: top;">Run in verbose mode.</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>--version</b></td><td style="vertical-align: top;">Display version
information.</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>-y</b>,
<b>--yes</b></td><td style="vertical-align: top;">Automatically answer
'yes' to prompts; existing target filesystems
will be purged before promote occurs.</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>-zp</b>,
<b>--zopenperms</b> [PERMISSIONS]</td><td style="vertical-align: top;">Update the permissions for all
files within the promoted zopen environment with the given
[PERMISSIONS] string, specified in symbolic mode.</td></tr></table>

<h2>EXAMPLES</h2>


<table><tr><td style="width: 25%; vertical-align: top;"><b>zopen
promote</b></td><td style="vertical-align: top;">Interactively promote current
zopen environment.</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>zopen promote /prod</b></td><td style="vertical-align: top;">Promote current zopen
environment to '/prod', setting file ownership
to current user and group to default.</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>zopen promote /prod
--owner FOO</b></td><td style="vertical-align: top;">Promote current zopen
environment to '/prod', setting file ownership
to 'FOO' and group to default.</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>zopen promote /prod
--group BAR</b></td><td style="vertical-align: top;">Promote current zopen
environment to '/prod', setting file ownership
to current user and group to 'BAR'.</td></tr><tr><td style="width: 25%; vertical-align: top;"><b>zopen promote /mytest -cp
g-wx,o-rwx -zp g-rwx,o-rwx
--owner FOO</b></td><td style="vertical-align: top;">Promote current zopen
environment to '/mytest', allowing only the
current user to source the zopen-config environment
file and only permit access to zopen environment files to
the user 'FOO'.</td></tr></table>

<h2>AUTHOR</h2>


<p style="margin-left:9%; margin-top: 1em">Written by
contributors to the zopen community.
<a href="https://github.com/zopencommunity/meta/graphs/contributors" target="_blank">https://github.com/zopencommunity/meta/graphs/contributors</a></p>

<h2>REPORTING BUGS</h2>


<p style="margin-left:9%; margin-top: 1em">Report bugs at
https://github.com/zopencommunity/meta/issues</p>

<p style="margin-left:9%; margin-top: 1em">This is free
software: you are free to change and redistribute it under
the terms of the Apache License, Version 2.0.
<a href="https://www.apache.org/licenses/LICENSE-2.0.html" target="_blank">https://www.apache.org/licenses/LICENSE-2.0.html</a>
<br>
There is NO WARRANTY, to the extent permitted by law.</p>

</div>
